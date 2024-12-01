Shader "Unlit/SDFExperimentation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color1", Color) = (1,1,1,1)
        _Color2("Color2", Color) = (1,1,1,1)
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
            #define PI 3.14159265359

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1;
            float4 _Color2;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float reverseStep(float color, float comparision)
            {
                return color <= comparision;
            }

            float SmoothMinimum(float a, float b, float k)
            {
                // float d1 = min(1, max(0, (e2-e1)/k + 0.5));
                // float m = e1*(1-e1)*k;
                // return ((1-d1)*e2+d1*e1)-m*0.5;

                float h = max(k - abs(a - b), 0.0) / k;
                return min(a, b) - h * h * h * k * (1.0 / 6.0);
            }

            float SDF_Circle(float2 p, float2 c, float r)
            {
                float d = distance(p, c);
                d = abs(d);
                return max(d - r, 0);
            }

            float SDF_Box(float2 p, float2 r)
            {
                p = abs(p);
                float d = sqrt(max(p.x - r.x, 0) * max(p.x - r.x, 0) + max(p.y - r.y, 0) * max(p.y - r.y, 0));
                d = saturate(d);
                return d;
                // Can be written as 
                // float2 d = abs(p)-r;
                // return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
            }

            float4 frag(v2f frag) : SV_Target
            {
                // 2 SDF Meeting Code
                // frag.uv = frag.uv * 2 - 1;
                // float d1 = SDF_Box(frag.uv - (sin(_Time.y) * 1.2 + 1.2) , float2(0.5,0.5));
                // float d2 = SDF_Circle(frag.uv + (sin(_Time.y) * 1.2 + 1.2),float2(0,-0.2), 0.4);
                // float minD = min(d1,d2);
                // minD = SmoothMinimum(d2,d1, 2);
                // float4 col = lerp(_Color1,_Color2, minD);
                // return col;

                //New Code
                int numberOfCells = 10;
                float2 newUV = frag.uv * numberOfCells;
                float2 segments = frac(newUV);
                float sqValue = 1;
                for (int i = 1; i <= numberOfCells; i++)
                {
                    for (int j = 1; j <= numberOfCells; j++)
                    {
                        float2 value = float2(i - 0.5, j - 0.5);
                        float squareFor = SDF_Box(newUV - value, float2(0.49, 0.49));
                        sqValue *= squareFor;
                    }
                }
                float2 blockedUV = floor(newUV);
                float maskGrid = 1 - reverseStep(sqValue, 0);
                float4 col_Mask = float4(sin(Random(blockedUV) * _Time.y * PI/2).xxx,1);
                float4 boxyColor = lerp(_Color1,_Color2, col_Mask);
                float4 ColorWithLines = lerp(boxyColor, float4(0,0,0,1), maskGrid);
                return ColorWithLines;
            }
            ENDCG
        }
    }
}