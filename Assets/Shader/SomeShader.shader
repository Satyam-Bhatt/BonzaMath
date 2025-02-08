Shader "Unlit/SomeShader"
{
    Properties
    {
        _MainTex1 ("Texture", 2D) = "white" {}
        _MainTex2 ("Texture2", 2D) = "white" {}
        _ScaleOnX ("ScaleOnX", float) = 1
		_ScaleOnY ("ScaleOnY", float) = 1
        _CircleMultiplier ("CircleMultiplier", float) = 1
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
                float4 color : COLOR0;
				float2 newuv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 newuv : TEXCOORD1;
                float4 color : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex1;
            float4 _MainTex1_ST;
            sampler2D _MainTex2;
			float4 _MainTex2_ST;
            float _ScaleOnX;
			float _ScaleOnY;
			float _CircleMultiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);
                o.newuv = TRANSFORM_TEX(v.newuv, _MainTex2);
                o.color = v.color;
                return o;
            }

            float SDF_Circle(float2 p, float2 c, float r)
			{
				return length(p - c) - r;
			}

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col1 = tex2D(_MainTex1, i.uv);
                float4 col2 = tex2D(_MainTex2, i.newuv);
                float2 uv = float2(0,0);
                uv.x = i.uv.x * _ScaleOnX * _CircleMultiplier;
				uv.y = i.uv.y * _ScaleOnY * _CircleMultiplier;
                float2 repeat = frac(uv) * 2 - 1;
                
                float dis = saturate(1 - length(repeat)) * saturate((length(repeat) + 1)); // White Circle
                dis = saturate(dis * 10);
                float dis2 =  saturate (pow(length(repeat), 10));
                //return float4(dis.xxx,1);
                float check = lerp(dis, dis2, sin(_Time.y) * 0.5 + 0.5);
                float4 check2 = lerp(col1, col2, check);
                return check2 * i.color;
                return float4(check.xxx,1);
            }
            ENDCG
        }
    }
}
