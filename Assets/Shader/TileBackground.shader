Shader "Unlit/TileBackground"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define  PI 3.14159265359

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float x = i.uv.x;
                x = 2 * x;
                x = frac(x);
                x = sin(x * PI);
                x = 1 - x;
                x = pow(x, 10);
                x = x - 0.2;
                float y = i.uv.y;
                y = 2 * y;
                y = frac(y);
                y = sin(y * PI);
                y = 1 - y;
                y = pow(y, 10);
                y = y - 0.2;

                //return float4(x,x,x,1);

                //float l = min(x,y);
                float l = lerp(x, y, 0.5);
                l = 4 * l;
                l = 1 - l;

                //return float4(l,l,l,1);
                
                float4 color = float4(1,1,1,1);
                if (i.uv.x <= 0.5 && i.uv.y <= 0.5)
                {
                    color = color * float4(1, 0, 0, 1);
                }
                else if (i.uv.x >= 0.5 && i.uv.y <= 0.5)
                {
                    color = color * float4(0, 1, 0, 1);
                }
                else if (i.uv.x <= 0.5 && i.uv.y >= 0.5)
                {
                    color = color * float4(0, 0, 1, 1);
                }
                l = saturate(l);
                color = lerp(float4(l,l,l,1), color, l);

                float4 colored = lerp(float4(0,0,0,1), float4(1,0,0,1), l);
                
                return color;
            }
            ENDCG
        }
    }
}