Shader "Unlit/ExpandingCircle"
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
            Cull off

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
            float4 _Color1;
            float4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;

                float2 newUV = v.uv * 2 - 1;
				float dis = saturate(length(newUV));

                float dis1 = 1 - dis;

                dis = sin(dis * PI * 5 - _Time.y * 3)* 0.5 + 0.5;

                dis = dis * dis1;

                v.vertex.z = dis * 0.002;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 newUV = i.uv * 2 - 1;
				float dis = saturate(length(newUV));

                float dis1 = 1 - dis;

                dis = sin(dis * PI * 6 - _Time.y * 3) * 0.5 + 0.5;

                dis = dis * dis1;

				float4 col = lerp(_Color1, _Color2, dis);

                return col;
            }
            ENDCG
        }
    }
}
