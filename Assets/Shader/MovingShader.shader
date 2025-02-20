Shader "Unlit/MovingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PerlinNoise ("Noise", 2D) = "white" {}

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

            sampler2D _MainTex;
            sampler2D _PerlinNoise;
            float4 _MainTex_ST;
            float4 _PerlinNoise_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR0;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;

            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 noiseUV = i.uv;
                noiseUV.x = noiseUV.x + sin(_Time.y ); //Moving UV in x direction
                noiseUV.y = noiseUV.y + cos(_Time.y * 0.5 ); //Moving UV in y direction
                float4 noise = tex2D(_PerlinNoise, noiseUV); //Sampling a B/W texture with moving UV
                //Creating a new UV with the moving noise texture. As the noise texture values are between 0 and 1 the new UV is moving back and forth
                float2 uvcheck = i.uv + 0.2 * noise; 
				float4 col = tex2D(_MainTex, uvcheck);//Sampling the main texture with this UV
                return col * i.color;
            }
            ENDCG
        }
    }
}
