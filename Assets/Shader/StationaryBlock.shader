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

            float SDF_Box2(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d, float2(0,0))) + min(min(d.x, d.y), 0.0);
            }

            //Infinite Zoom
            // float4 frag (v2f frag) : SV_Target
            // {
            //     float effect = 1000;

            //     for(int i = 0; i < 13; i+=2)
            //     {
            //        float layerTime = _Time.y * 0.1 + i * (1.0 / 12);
            //        float scaleFactor = fmod(layerTime, 1.2) ;
            //        //float scaleFactor = fmod(layerTime * i/10, 1.2) ;
            //        float box = abs(SDF_Box(frag.uv * 2 - 1 , float2(scaleFactor, scaleFactor)));
            //        effect = min(effect, box);
            //     }

            //     return effect;
            // }

            float4 frag (v2f frag) : SV_Target
            {
    //             float scaleFactor = sin(_Time.y * 0.5) * 0.5 + 1;
    //             // float box = abs(SDF_Box(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) , float2(scaleFactor, scaleFactor)));
    //             // float box2 = abs(SDF_Box2(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) * scaleFactor * scaleFactor , float2(scaleFactor/2, scaleFactor/2)));
    //             // float box3 = abs(SDF_Box(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) , float2(scaleFactor/4, scaleFactor/4)));
    //             // float box4 = abs(SDF_Box2(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) * scaleFactor * scaleFactor * scaleFactor , float2(scaleFactor/6, scaleFactor/6)));

    //             float box = abs(SDF_Box(i.uv * 2 - 1 , float2(scaleFactor, scaleFactor)));
    //             float box2 = abs(SDF_Box2((i.uv * 2 - 1) * scaleFactor * scaleFactor , float2(scaleFactor/2, scaleFactor/2)));
    //             float box3 = abs(SDF_Box(i.uv * 2 - 1 , float2(scaleFactor/4, scaleFactor/4)));
    //             float box4 = abs(SDF_Box2((i.uv * 2 - 1) * scaleFactor * scaleFactor * scaleFactor , float2(scaleFactor/6, scaleFactor/6)));

    //             float bothBox = min(box, box2);
    //             bothBox = min(bothBox, box3);
				// bothBox = min(bothBox, box4);
    //             return bothBox;

                float effect = 1000;

                for(int i = 0; i <= 8; i++)
                {
                    float scaleFactor = sin(_Time.y * 0.5) * 0.5 + 0.7;

                    float layerTime = _Time.y * 0.1 + i * (1.0 / 8);
                    float scaleFactor2 = fmod(layerTime, 1.2) ;

                    if(i % 2 != 0)
					{
						float box = abs(SDF_Box(frag.uv * 2 - 1 , float2(scaleFactor2, scaleFactor2)));
						effect = min(effect, box);
					}
					else
					{
						float box = abs(SDF_Box2((frag.uv * 2 - 1) * pow(scaleFactor, i/2) , float2(scaleFactor/i/2, scaleFactor/i/2)));
						effect = min(effect, box);
					}
                }

                return effect;
            }

            ENDCG
        }
    }
}
