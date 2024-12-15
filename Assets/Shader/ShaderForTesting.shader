Shader "Unlit/ShaderForTesting"
{
    Properties
    {
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

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
            };
            

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float RandomWithMovement(float2 uv)
            {
                return sin(_Time.y * 0.5 + Random(uv) * 10) * 0.5 + 0.5;
            }

            float4 frag(v2f i) : SV_Target
            {
                int numberOfCells = 5;
                float2 newUV = i.uv * numberOfCells;
                float2 segments = frac(newUV);
                float2 floored = floor(newUV);
                float height = RandomWithMovement(floored);
                return float4(height,height,height,1);
            }
            ENDCG
        }
    }
}