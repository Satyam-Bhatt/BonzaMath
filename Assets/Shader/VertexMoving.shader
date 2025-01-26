Shader "Unlit/VertexMoving"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PerlinNoise ("Noise", 2D) = "white" {}
        _a("a", float) = 0
        _b("b", float) = 0
		_c("c", float) = 0
        _DirectionX("DirectionX", float) = 0
		_DirectionY("DirectionY", float) = 0
        _Bend("Bend", float) = 0
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
            sampler2D _PerlinNoise;
            float _a, _b, _c, _DirectionX, _DirectionY, _Bend;

            v2f vert (appdata v)
            {
                v2f o;

                //Waves in X axis
                float offsetX = cos(v.uv.y * PI * _a) * _c + 0.5;
                float zX = cos((v.uv.x * _b + offsetX) * PI + _Time.y * 5) * 0.5 + 0.5;
				v.vertex.x +=  (0.001 * zX);

                //Waves in Y axis
                float offsetY = cos(v.uv.x * PI * _a) * _c + 0.5;
                float zY = cos((v.uv.y * _b + offsetY) * PI + _Time.y * 5) * 0.5 + 0.5;
                v.vertex.y +=  (0.001 * zY);

                //Bend in X axis
                float uvY = saturate(sin(v.uv.y * 2 * PI + PI * 1.5) * 0.5 + 0.5);
                uvY = 1 - uvY;
                v.vertex.x += _DirectionX * (_Bend * uvY);

                //Bend in Y axis
                float uvX = saturate(sin(v.uv.x * 2 * PI + PI * 1.5) * 0.5 + 0.5);
                uvX = 1 - uvX;
                v.vertex.y -= _DirectionY * (_Bend * uvX);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //Test Code for Waves
                float offset = cos(i.uv.y * PI * _a) * _c + 0.5;
                float z = cos((i.uv.x * _b + offset) * PI + _Time.y * 5) * 0.5 + 0.5;

                float uvY = saturate(sin(i.uv.y * 2 * PI + PI * 1.5) * 0.5 + 0.5);
                uvY = 1 - uvY;
                //Test Code End

                // sample the texture
                float2 noiseUV = i.uv * 0.5;
                if(abs(_DirectionX) > 0.01)
                {
                    noiseUV.x =  noiseUV.x + _DirectionX/abs(_DirectionX) * _Time.y * 0.5; //Moving UV in x direction
                }
                if(abs(_DirectionY) > 0.01)
                {
                    noiseUV.y =  noiseUV.y + _DirectionY/abs(_DirectionY) * _Time.y * 0.5; //Moving UV in y direction
                }
                float4 noise = tex2D(_PerlinNoise, noiseUV); //Sampling a B/W texture with moving UV
                //Creating a new UV with the moving noise texture. As the noise texture values are between 0 and 1 the new UV is moving back and forth
                float2 uvcheck = i.uv + 0.2 * noise; 
				float4 col = tex2D(_MainTex, uvcheck);//Sampling the main texture with this UV
                return col;
            }
            ENDCG
        }
    }
}
