Shader "Unlit/SomeShader"
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

            #define PI 3.141592653589793
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float SDF_Circle(float2 p, float2 c, float r)
			{
				return length(p - c) - r;
			}

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                float2 uv = i.uv * 4;
                float2 repeat = frac(uv) * 2 - 1;
                
                float dis = saturate(1 - length(repeat)) * saturate((length(repeat) + 1));
                float dis2 = SDF_Circle(frac(i.uv * 4), float2(0.5, 0.5), 0.4);
                float check = lerp(dis, dis2, sin(_Time.y) * 0.5 + 0.5);
                return float4(check.xxx,1);
            }
            ENDCG
        }
    }
}
