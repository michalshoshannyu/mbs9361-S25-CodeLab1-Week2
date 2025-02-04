Shader "Custom/WoodblockPrint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _InkColor ("Ink Color", Color) = (0.1, 0.1, 0.1, 1)
        _PaperColor ("Paper Color", Color) = (0.95, 0.93, 0.88, 1)
        _PaperTexture ("Paper Texture", 2D) = "white" {}
        _GrainStrength ("Wood Grain Strength", Range(0, 1)) = 0.5
        _EdgeRoughness ("Edge Roughness", Range(0, 1)) = 0.3
        _InkAbsorption ("Ink Absorption", Range(0, 1)) = 0.5
        _PressureVariation ("Pressure Variation", Range(0, 1)) = 0.4
        _GrainScale ("Grain Scale", Range(1, 50)) = 20
        _GlobalAlpha ("Global Alpha", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _PaperTexture;
            float4 _MainTex_ST;
            float4 _InkColor;
            float4 _PaperColor;
            float _GrainStrength;
            float _EdgeRoughness;
            float _InkAbsorption;
            float _PressureVariation;
            float _GrainScale;
            float _GlobalAlpha;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                
                float a = rand(i);
                float b = rand(i + float2(1.0, 0.0));
                float c = rand(i + float2(0.0, 1.0));
                float d = rand(i + float2(1.0, 1.0));
                
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            float woodGrain(float2 uv)
            {
                float noise1 = noise(uv * _GrainScale);
                float noise2 = noise(uv * _GrainScale * 2.0);
                float grain = lerp(noise1, noise2, 0.5);
                return grain;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                // Generate wood grain pattern
                float grain = woodGrain(screenUV);
                
                // Create pressure variation
                float pressure = noise(screenUV * 5) * _PressureVariation;
                
                // Create edge roughness
                float edge = noise(screenUV * 30) * _EdgeRoughness;
                
                // Sample paper texture
                float4 paper = tex2D(_PaperTexture, screenUV * 10);
                
                // Create main mask from original texture
                float mask = step(0.5, col.r);
                
                // Apply grain and edge effects
                mask *= lerp(1, grain, _GrainStrength);
                mask += edge * mask;
                mask = saturate(mask - pressure);
                
                // Create ink absorption effect
                float absorption = lerp(1, paper.r, _InkAbsorption);
                
                // Final color
                float4 finalColor = lerp(_PaperColor, _InkColor * absorption, mask);
                finalColor.a = mask * _GlobalAlpha * col.a;
                
                return finalColor;
            }
            ENDCG
        }
    }
}