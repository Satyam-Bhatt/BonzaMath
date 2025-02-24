Shader "Unlit/Infinite3DCubes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #define STEPS 100
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 ModOperator(float3 x, float y)
            {
                return x - y * floor(x/y);
            }

            float GetDist(float3 position)
            {
                float distanceToPlane = position.y;

                float3 spherePosition = float3(1,1,1);
                float radius = 0.5;

                float3 repeat = ModOperator(position, 2);

                float sphereDistance = length(repeat - spherePosition) - radius;

				return min(distanceToPlane, sphereDistance);
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceOrigin = 0;
                for(int i = 0; i < STEPS; i++)
                {
                    float3 firstPointOfContact = rayOrigin + distanceOrigin * rayDirection;

                    float distanceToTheObject = GetDist(firstPointOfContact);
                    distanceOrigin += distanceToTheObject;

                    if(distanceOrigin > MAXDIST || distanceToTheObject < MINDIST) break;
                }

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
                float3 lightPosition = float3(2,3,-2);
                float3 lightVector = normalize(lightPosition - position);
                float3 normal = GetNormal(position);
                float diffuseLight = saturate(dot(lightVector, normal));

                //Shadow
                float shadowToLight = RayMarch(position + normal * SURF_DIST, lightPosition);
                if(shadowToLight < length(lightPosition - position)) diffuseLight = diffuseLight * 0.2;

                return diffuseLight;
            }

            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float RandomWithMovement(float2 uv)
            {
                return sin(_Time.y * 0.5 + Random(uv) * 10) * 0.5 + 0.5;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; //Center the scene
                uv.x = uv.x * 0.8/1;

                float3 rayOrigin  = float3(0,1,-3);
                float3 rayDirection = normalize(float3(uv,1));

                float col = RayMarch(rayOrigin, rayDirection);

                float3 pointForLight = rayOrigin + col * rayDirection;
                float diffuseLight = GetLight(pointForLight);

                return diffuseLight;

                col  = col/8;
                
                return col;
            }
            ENDCG
        }
    }
}
