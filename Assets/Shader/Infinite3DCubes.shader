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
            #define MAXDIST 200
            #define MINDIST 0.01

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

            float GetDist(float3 position)
            {
                float distanceToPlane = position.y;

                float3 spherePosition = float3(0,1,0);
                float radius = 1;

                float sphereDistance = length(position - spherePosition) - radius;

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

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; //Center the scene
                uv.x = uv.x * 0.8/1;

                float3 rayOrigin  = float3(0,1,-3);
                float3 rayDirection = normalize(float3(uv,1));
                float col = RayMarch(rayOrigin, rayDirection);
                col  = col/8;
                return col;

                return float4(rayDirection,1);
            }
            ENDCG
        }
    }
}
