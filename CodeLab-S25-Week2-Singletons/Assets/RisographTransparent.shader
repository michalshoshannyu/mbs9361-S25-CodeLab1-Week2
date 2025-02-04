Shader "Custom/RisographTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color Layer 1", Color) = (0, 0.5, 0.2, 0.8)
        _Color2 ("Color Layer 2", Color) = (0, 0, 0.8, 0.8)
        _DotScale ("Dot Pattern Scale", Range(20, 200)) = 100
        _LineScale ("Line Pattern Scale", Range(20, 200)) = 100
        _Misalignment ("Color Misalignment", Range(0, 0.02)) = 0.005
        _NoiseIntensity ("Paper Grain", Range(0, 1)) = 0.1
        _PatternBlend ("Pattern Blend", Range(0, 1)) = 0.5
        _GlobalTransparency ("Global Transparency", Range(0, 1)) = 0.5
        [Toggle] _UseDots1 ("Use Dots for Layer 1", Float) = 1
        [Toggle] _UseDots2 ("Use Dots for Layer 2", Float) = 0
    }
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "PreviewType"="Plane"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1;
            float4 _Color2;
            float _DotScale;
            float _LineScale;
            float _Misalignment;
            float _NoiseIntensity;
            float _PatternBlend;
            float _GlobalTransparency;
            float _UseDots1;
            float _UseDots2;

            // Improved random function
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

            // Paper grain noise
            float paperGrain(float2 uv)
            {
                float noise1 = rand(uv * 1.5);
                float noise2 = rand(uv * 2.5 + float2(0.5, 0.5));
                return lerp(noise1, noise2, 0.5) * 0.5 + 0.5;
            }

            // Dot pattern
            float dotPattern(float2 uv, float angle, float scale)
            {
                float2 rotatedUV = float2(
                    cos(angle) * uv.x - sin(angle) * uv.y,
                    sin(angle) * uv.x + cos(angle) * uv.y
                );
                
                float2 nearest = 2.0 * frac(rotatedUV * scale) - 1.0;
                float dist = length(nearest);
                return smoothstep(0.3, 0.4, dist);
            }

            // Line pattern
            float linePattern(float2 uv, float angle, float scale)
            {
                float2 rotatedUV = float2(
                    cos(angle) * uv.x - sin(angle) * uv.y,
                    sin(angle) * uv.x + cos(angle) * uv.y
                );
                
                float lines = frac(rotatedUV.x * scale);
                return smoothstep(0.4, 0.6, lines);
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
                // Get screen UV for stable patterns
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                // Sample the texture
                float4 texColor = tex2D(_MainTex, i.uv);
                float gray = dot(texColor.rgb, float3(0.299, 0.587, 0.114));
                
                // Create offset UVs for color misalignment
                float2 uv1 = screenUV + float2(_Misalignment, _Misalignment * 0.5);
                float2 uv2 = screenUV - float2(_Misalignment * 0.7, _Misalignment * 0.3);
                
                // Generate patterns for each layer
                float pattern1, pattern2;
                
                if (_UseDots1 > 0.5)
                    pattern1 = dotPattern(uv1, 0.45, _DotScale);
                else
                    pattern1 = linePattern(uv1, 0.45, _LineScale);
                    
                if (_UseDots2 > 0.5)
                    pattern2 = dotPattern(uv2, 0.0, _DotScale);
                else
                    pattern2 = linePattern(uv2, 0.0, _LineScale);
                
                // Create masks with slight softness
                float mask1 = smoothstep(0.48, 0.52, gray - pattern1);
                float mask2 = smoothstep(0.48, 0.52, gray - pattern2);
                
                // Add paper grain
                float grain = paperGrain(screenUV * 500) * _NoiseIntensity;
                
                // Build final color with transparency
                float4 finalColor = float4(0, 0, 0, 0);
                
                // Layer 1
                finalColor = lerp(finalColor, 
                                float4(_Color1.rgb, _Color1.a * mask1), 
                                mask1);
                
                // Layer 2
                float4 color2Layer = float4(_Color2.rgb, _Color2.a * mask2);
                finalColor = lerp(finalColor, 
                                color2Layer, 
                                mask2 * (1 - mask1));
                
                // Color overlap
                float4 overlapColor = float4(
                    _Color1.rgb * _Color2.rgb,
                    max(_Color1.a, _Color2.a)
                );
                finalColor = lerp(finalColor, 
                                overlapColor, 
                                mask1 * mask2);
                
                // Apply paper grain
                finalColor.rgb = finalColor.rgb * (1 - grain * 0.5) + grain * 0.5;
                
                // Apply global transparency
                finalColor.a *= _GlobalTransparency * texColor.a;
                
                return finalColor;
            }
            ENDCG
        }
    }
}