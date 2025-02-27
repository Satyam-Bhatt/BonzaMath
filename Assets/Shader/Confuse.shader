Shader "Unlit/Confuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _value1("Value1" , Float) = 0
        _value2("Value2" , Float) = 0
        _value3("Value3" , Float) = 0
        _FogStr("fogstr" , Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        ZTest[unity_GUIZTestMode]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define STEPS 200
            #define MAXDIST 100
            #define MINDIST 0.001
            #define SURF_DIST 1

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
            float _value1, _value2, _value3, _FogStr;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2x2 Rotation(float angle)
            {
				float s = sin(angle);
				float c = cos(angle);
				return float2x2(c, -s, s, c);
            }

            float3 ModOperator(float3 x, float y)
            {
                return x - y * floor(x/y);
            }

            float GetDist(float3 position)
            {
                float distanceToPlane = position.y;

                float3 spherePosition = float3(0,0,1);
                float radius = 0.4;

                float originalZ = position.z + (_Time.y);

                float testSphere = length(position - spherePosition) - radius;

                float3 repeat  = position;

                position.xy = mul(position.xy, Rotation(_Time.y + position.z * 0.1));

                repeat = ModOperator(position, 2) - 1;//Repeats in all planes

                float sphereDistance = length(repeat - spherePosition) - radius;

                return sphereDistance;

				//return min(distanceToPlane, sphereDistance);
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection, out int val)
            {
                float distanceOrigin = 0;
                int i;
                for(i = 0; i < STEPS; i++)
                {
                    float3 firstPointOfContact = rayOrigin + distanceOrigin * rayDirection;

                    float distanceToTheObject = GetDist(firstPointOfContact);
                    distanceOrigin += distanceToTheObject;

                    if(distanceOrigin > MAXDIST || distanceToTheObject < MINDIST) break;
                }
                val = i;
                return distanceOrigin;
            }

            float3 GetNormal(float3 position)
            {
                float2 smallMarginShift = float2(0.0001, 0);
                float distanceToPoint = GetDist(position);

                float3 normal = float3(
                    distanceToPoint - GetDist(position - smallMarginShift.xyy),
					distanceToPoint - GetDist(position - smallMarginShift.yxy),
					distanceToPoint - GetDist(position - smallMarginShift.yyx)
				);

                return normalize(normal);
            }

            float GetLight(float3 position)
            {
                float3 lightPosition = float3(0,0,-5);
                float3 lightVector = normalize(lightPosition - position);
                float3 normal = GetNormal(position);
                float diffuseLight = saturate(dot(lightVector, normal));

                return diffuseLight;
            }

            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float Dither(float3 color, float2 uv)
            {
                float dither = Random(uv) * 0.03 - 0.015; // Small random offset
                return dither;
            }

            float RandomWithMovement(float2 uv)
            {
                return sin(_Time.y * 0.5 + Random(uv) * 10) * 0.5 + 0.5;
            }

            float InverseLerp(float a, float b , float v)
            {
                return clamp((v - a) / (b - a), 0, 1);
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; //Center the scene
                uv.x = uv.x * 0.8/1;

               //float3 rayOrigin  = float3(0,1,-3 + _Time.y); //Camera Movemenet
               float3 rayOrigin  = float3(0,0,-3); //Camera Movemenet
               float3 rayDirection = normalize(float3(uv,1));

               int val = 0;
               float col = RayMarch(rayOrigin, rayDirection, val);

               float3 pointForLight = rayOrigin + col * rayDirection;
               float diffuseLight = GetLight(pointForLight);//Sphere with black background

               return diffuseLight;

            }
            ENDCG
        }
    }
    //https://www.shadertoy.com/view/3sfczH
}
