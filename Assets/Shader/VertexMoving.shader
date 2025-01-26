Shader "Unlit/VertexMoving"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _a("a", float) = 0
        _b("b", float) = 0
		_c("c", float) = 0
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
            float _a, _b, _c;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float offset = cos(i.uv.y * PI * _a) * _c + 0.5;
                float z = cos((i.uv.x * _b + offset) * PI) * 0.5 + 0.5;
                //return offset;
                return z;
            }
            ENDCG
        }
    }
}
