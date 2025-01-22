Shader "Unlit/SquareShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float SDF_Box(float2 p, float2 r)
            {
                p = abs(p);
                float d = sqrt(max(p.x - r.x, 0) * max(p.x - r.x, 0) + max(p.y - r.y, 0) * max(p.y - r.y, 0));
                d = saturate(d);
                return d;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 originalUV = i.uv;
                float4 col = tex2D(_MainTex, originalUV);
                i.uv = i.uv * 5;
                i.uv = frac(i.uv);
                i.uv = 2 * i.uv - 1;
                float varyingValue = 0.5 - cos(_Time.y) * 0.5;
                float box = SDF_Box(i.uv , float2(varyingValue,varyingValue));
                box = step(box, 0);
                if(box == 0) discard;
                float4 finalCol = lerp(float4(0,0,0,1), col, box);
                return  finalCol;
            }
            ENDCG
        }
    }
}
