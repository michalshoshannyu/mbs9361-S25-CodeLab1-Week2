Shader "Custom/ScreenPrintHalftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CyanColor ("Cyan", Color) = (0, 1, 1, 1)
        _MagentaColor ("Magenta", Color) = (1, 0, 1, 1)
        _YellowColor ("Yellow", Color) = (1, 1, 0, 1)
        _BlackColor ("Black", Color) = (0, 0, 0, 1)
        _DotScale ("Dot Scale", Range(100, 1000)) = 300
        _DotSize ("Dot Size", Range(0.1, 0.9)) = 0.5
        _Misalign ("Misalignment", Range(0, 0.01)) = 0.003
        _Rotation ("Rotation Offset", Range(0, 90)) = 15
        _Roughness ("Print Roughness", Range(0, 1)) = 0.2
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
            float4 _MainTex_ST;
            float4 _CyanColor;
            float4 _MagentaColor;
            float4 _YellowColor;
            float4 _BlackColor;
            float _DotScale;
            float _DotSize;
            float _Misalign;
            float _Rotation;
            float _Roughness;
            float _GlobalAlpha;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

            float2 rotate2D(float2 p, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float2(p.x * c - p.y * s, p.x * s + p.y * c);
            }

            float halftone(float2 uv, float angle, float scale)
            {
                float2 rotatedUV = rotate2D(uv, angle);
                float2 nearest = 2.0 * frac(rotatedUV * scale) - 1.0;
                float dist = length(nearest);
                float noise = (rand(rotatedUV * scale) - 0.5) * _Roughness;
                return smoothstep(_DotSize + noise, _DotSize - 0.1 + noise, dist);
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
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float4 col = tex2D(_MainTex, i.uv);
                
                // Convert to CMYK-like values
                float k = 1 - max(max(col.r, col.g), col.b);
                float c = (1 - col.r - k) / (1 - k);
                float m = (1 - col.g - k) / (1 - k);
                float y = (1 - col.b - k) / (1 - k);

                // Create offset UVs for each channel
                float2 uvC = screenUV + float2(_Misalign, _Misalign);
                float2 uvM = screenUV + float2(-_Misalign, _Misalign * 0.5);
                float2 uvY = screenUV + float2(_Misalign * 0.5, -_Misalign);
                float2 uvK = screenUV;

                // Generate halftone patterns at different angles
                float dotC = halftone(uvC, radians(15 + _Rotation), _DotScale);
                float dotM = halftone(uvM, radians(75 + _Rotation), _DotScale);
                float dotY = halftone(uvY, radians(0 + _Rotation), _DotScale);
                float dotK = halftone(uvK, radians(45 + _Rotation), _DotScale);

                // Combine layers
                float4 finalColor = float4(1,1,1,0);
                
                // Apply each color layer with halftone pattern
                float4 cyanLayer = _CyanColor * c * dotC;
                float4 magentaLayer = _MagentaColor * m * dotM;
                float4 yellowLayer = _YellowColor * y * dotY;
                float4 blackLayer = _BlackColor * k * dotK;

                // Blend layers
                finalColor.rgb = float3(1,1,1);
                if (dotC * c > -1) finalColor.rgb *= lerp(float3(1,1,1), _CyanColor.rgb, c * dotC);
                if (dotM * m > -1) finalColor.rgb *= lerp(float3(1,1,1), _MagentaColor.rgb, m * dotM);
                if (dotY * y > -1) finalColor.rgb *= lerp(float3(1,1,1), _YellowColor.rgb, y * dotY);
                if (dotK * k > -1) finalColor.rgb *= lerp(float3(1,1,1), _BlackColor.rgb, k * dotK);

                // Set alpha based on whether any color is present
                finalColor.a = max(max(max(c * dotC, m * dotM), y * dotY), k * dotK) * _GlobalAlpha * col.a;
                
                return finalColor;
            }
            ENDCG
        }
    }
}