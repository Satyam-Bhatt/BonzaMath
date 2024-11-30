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
        Tags { "RenderType"="Opaque" }

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color1;
            float4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float SDF_Box(float2 p , float2 r)
            {
                p = abs(p);
                float d = sqrt(max(p.x-r.x,0) * max(p.x-r.x,0) + max(p.y-r.y,0) * max(p.y-r.y,0));
                d = saturate(d);
                return d;
                // Can be written as 
                // float2 d = abs(p)-r;
                // return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
            }

            float SmoothMinimum(float a, float b, float k)
            {
                // float d1 = min(1, max(0, (e2-e1)/k + 0.5));
                // float m = e1*(1-e1)*k;
                // return ((1-d1)*e2+d1*e1)-m*0.5;
                
                float h = max(k - abs(a-b), 0.0)/k;
                return min(a,b) - h*h*h*k*(1.0/6.0);
            }

            float SDF_Circle(float2 p, float2 c, float r)
            {
                float d = distance(p,c);
                d = abs(d);
                return max(d - r, 0);
            }

            float4 frag (v2f i) : SV_Target
            {
                i.uv = i.uv * 2 - 1;
                //return float4(i.uv,0,1);
                float d1 = SDF_Box(i.uv - (sin(_Time.y) * 1.2 + 1.2) , float2(0.5,0.5));
                float d2 = SDF_Circle(i.uv + (sin(_Time.y) * 1.2 + 1.2),float2(0,-0.2), 0.4);
                float minD = min(d1,d2);
                minD = SmoothMinimum(d2,d1, 2);

                float4 col = lerp(_Color1,_Color2, minD);
                return  col;
                return float4(minD.xxx,1);
            }
            ENDCG
        }
    }
}
