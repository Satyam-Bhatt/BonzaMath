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

            float4 frag (v2f i) : SV_Target
            {
                float scaleFactor = sin(_Time.y * 0.5) * 0.5 + 1;
                // float box = abs(SDF_Box(mul(Rotation(-_Time.y * 0.3),i.uv * 2 - 1) , float2(scaleFactor, scaleFactor)));
                // float box2 = abs(SDF_Box2(mul(Rotation(-_Time.y * 0.3),i.uv * 2 - 1) * scaleFactor * scaleFactor , float2(scaleFactor/2, scaleFactor/2)));
                // float box3 = abs(SDF_Box(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) , float2(scaleFactor/4, scaleFactor/4)));
                // float box4 = abs(SDF_Box2(mul(Rotation(_Time.y * 0.3),i.uv * 2 - 1) * scaleFactor * scaleFactor * scaleFactor , float2(scaleFactor/6, scaleFactor/6)));

                float box = abs(SDF_Box(i.uv * 2 - 1 , float2(scaleFactor, scaleFactor)));
                float box2 = abs(SDF_Box2((i.uv * 2 - 1) * scaleFactor * scaleFactor , float2(scaleFactor/2, scaleFactor/2)));
                float box3 = abs(SDF_Box(i.uv * 2 - 1 , float2(scaleFactor/4, scaleFactor/4)));
                float box4 = abs(SDF_Box2((i.uv * 2 - 1) * scaleFactor * scaleFactor * scaleFactor , float2(scaleFactor/6, scaleFactor/6)));

                float bothBox = min(box, box2);
                bothBox = min(bothBox, box3);
				bothBox = min(bothBox, box4);
                return bothBox;
            }

            // float4 frag (v2f i) : SV_Target
            // {
            //     float2 uv = i.uv * 2.0 - 1.0; // Center UVs [-1, 1]
    
            //     float speed = 0.2;
            //     float period = 1.5;
            //     float minScale = 0.25;
            //     int numLayers = 10;
            //     float tunnelEffect = 1000.0; // Initialize with a large value
    
            //     for (int idx = 0; idx < numLayers; idx++)
            //     {
            //         // Offset each layer's time to stagger animations
            //         float layerTime = _Time.y * speed + idx * (period / numLayers);
            //         float scale = fmod(layerTime, period) + minScale;
        
            //         // Exponentially decrease scale per layer
            //         float currentScale = scale * pow(0.5, idx);
        
            //         // Calculate box SDF and take absolute value
            //         float box = abs(SDF_Box(uv, float2(currentScale, currentScale)));
        
            //         // Keep the smallest SDF value
            //         tunnelEffect = min(tunnelEffect, box);
            //     }
    
            //     return tunnelEffect;
            // }

            // float4 frag (v2f i) : SV_Target
            // {
            //     float scaleFactor = fmod(_Time.y * 0.2, 1.5) + 0.25;
            //     float box = SDF_Box(mul(Rotation(_Time.y),i.uv * 2 - 1) , float2(scaleFactor, scaleFactor));
            //     float box2 = SDF_Box2(mul(Rotation(-_Time.y),i.uv * 2 - 1) , float2(scaleFactor, scaleFactor));
            //     float annular = abs(box);
            //     float annular2 = abs(box2);
            //     float bothBox = min(annular, annular2);
            //     return bothBox;
            // }
            ENDCG
        }
    }
}
