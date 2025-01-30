Shader "Unlit/StationaryBlock"
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2x2 Rotation(float angle)
            {
                float s = sin(angle);
				float c = cos(angle);
				return float2x2(c, s, -s, c);
            }

            float SDF_Box(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);
                //return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);
            }

            float SDF_Box2(float2 p, float2 r)
            {
                p = abs(p) - r;
                float d = length(max(p,0) + min(p, 0));
                //d = saturate(d);
                return d;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float box = SDF_Box(mul(Rotation(_Time.y), (i.uv * 2 - 1)) , float2(0.5, 0.5));
                float annular = abs(box);
                return annular;
            }
            ENDCG
        }
    }
}
