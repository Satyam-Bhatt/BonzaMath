Shader "Unlit/Infinite3DCubes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _value1("Value1" , Float) = 0
        _value2("Value2" , Float) = 0
        _value3("Value3" , Float) = 0
        _FogStr("fogstr" , Float) = 0
        _FogColor("FogColor", Color) = (0.5, 0.6, 0.7, 1)
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
            float4 _MainTex_ST, _FogColor, tex;
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

            float2 ModOperator(float2 x, float y)
            {
                return x - y * floor(x/y);
            }

            float ModOperator(float x, float y)
            {
                return x - y * floor(x/y);
            }

            float hash(float n) 
            {
                return frac(sin(n) * 43758.5453);
            }

            //==================== Bouncing Spheres =================
            float GetDist(float3 position)
            {
                float distanceToPlane = position.y;

                float3 spherePosition = float3(0,0,1);
                float radius = 0.4;

                float originalZ = position.z;
                float originalX = position.x;

                position.y += (smoothstep(0,2,sin(originalZ * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,2));
                position.y += (smoothstep(0,2,sin(originalX * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,2));
                 
                tex = tex2D(_MainTex, position.xy);
                tex += tex2D(_MainTex, position.yz);
				tex += tex2D(_MainTex, position.zx);
				//tex /= 3;

                float3 repeat  = position;
                //Comment one out to repeat in specific plane
                repeat.x = ModOperator(position.x, _value1) - 1;
                repeat.z = ModOperator(position.z, _value2) - 1;
                //repeat.y = ModOperator(position.y, _value3) - 1;

                float sphereDistance = length(repeat - spherePosition) - radius;

                return sphereDistance;
            }

            //==================== Spiral Spheres =================
    //         float GetDist(float3 position)
    //         {
    //             float distanceToPlane = position.y;

    //             float3 spherePosition = float3(0,0,0);
    //             float radius = 0.4;

    //             float originalZ = position.z + (_Time.y);

    //             float testSphere = length(position - spherePosition) - radius;
    //             //return testSphere;

    //             position.z += (_Time.y);//Movement but camera Movemenet is a bit better

    //             //Spiral Rotation
    //             position.xy = mul(position.xy, Rotation(_Time.y * 0.5 + originalZ * 0.1));
                 
    //             tex = tex2D(_MainTex, position.xy);
    //             tex += tex2D(_MainTex, position.yz);
				// tex += tex2D(_MainTex, position.zx);
				// //tex /= 3;

    //             //Apply sin wave to the y component
				// //position.y += 0.8 * sin(position.z * 0.5); // No Movemenet
    //             //position.y += 0.8 * sin(originalZ * 0.5 + _Time.y * 1); //Serpent movement cool
    //             //position.x += 0.5 * cos(originalZ * 0.5 + _Time.y * 1); //Spiral Movement xy

    //             //-> Spiral and Zoom
    //             //-> Sin Wave + Zoom + Camera Offset from ShaderToy
    //             //-> Bouncing Spheres
    //             //-> Smoothstep Wave

    //             position  = position * float3(1,1,0.8);//Scaling

    //             float3 repeat  = position;
    //             //repeat = ModOperator(position, 2) - 1;//Repeats in all planes
    //             //Comment one out to repeat in specific plane
    //             repeat.x = ModOperator(position.x, _value1) - 1;
    //             repeat.z = ModOperator(position.z, _value2) - 1;
    //             repeat.y = ModOperator(position.y, _value3) - 1;

    //             float sphereDistance = length(repeat - spherePosition) - radius;

    //             return sphereDistance;

				// //return min(distanceToPlane, sphereDistance);
    //         }

            float RayMarch(float3 rayOrigin, float3 rayDirection, out int val)
            {
                float distanceOrigin = 0;
                int i;
                for(i = 0; i < STEPS; i++)
                {
                    float3 firstPointOfContact = rayOrigin + distanceOrigin * rayDirection;

                    //firstPointOfContact.xy = mul(firstPointOfContact.xy, Rotation(_Time.y + distanceOrigin * 0.1));
        
                    //firstPointOfContact.y += sin(distanceOrigin * (_value3 + 1.0) * 0.5) * 0.35;

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
                float3 lightPosition = float3(0,5,-3);
                float3 lightVector = normalize(lightPosition - position);
                float3 normal = GetNormal(position);
                float diffuseLight = saturate(dot(lightVector, normal));

                //Shadow - Turned off becaue of artifacting
                // int val = 0;
                // float shadowToLight = RayMarch(position + normal * SURF_DIST, lightPosition, val);
                // if(shadowToLight < length(lightPosition - position)) diffuseLight = diffuseLight * 0.1;

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

            float InverseLerp(float a, float b , float v)
            {
                return clamp((v - a) / (b - a), 0, 1);
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; //Center the scene
                uv.x = uv.x * 0.8/1;

               //float3 rayOrigin  = float3(0,1,-3 + _Time.y); //Camera Movemenet
               float3 rayOrigin  = float3(0,2,-3); //Camera
               float3 rayDirection = normalize(float3(uv.x, uv.y,1));

               int val = 0;
               float col = RayMarch(rayOrigin, rayDirection, val);

               //if we don't covert to float then the int division result is truncated.
               float fogDepth = saturate(float(val)/float(60) * _FogStr) ; //Creates Halo but the background is banded
               float greyCol = float3(0.2,0.2,0.2);
               float removeBanding = max(fogDepth, greyCol); //Removed circular bands in the background also maintins the Halo
               float diffuseMask = saturate(col/float(MAXDIST/8)); //Giver perfect mask for sphere
               float inverseDiffuseMask = 1 - diffuseMask; //White sphere and rest is black
               float maskWithHalo = inverseDiffuseMask + removeBanding; //Center gradient white and grey rest
               float maskForDiffuseHalo = InverseLerp(0.2, 1, maskWithHalo); //Center gradient white and black rest
               float maskForHalo = step(0.1, diffuseMask) * maskForDiffuseHalo; //Sphere and background is black but halo is white. Can be used for halo color
                
               float3 pointForLight = rayOrigin + col * rayDirection;
               float diffuseLight = GetLight(pointForLight);
               //tex = tex2D(_MainTex, pointForLight.xy);
			   //tex += tex2D(_MainTex, pointForLight.yz);
			   //tex += tex2D(_MainTex, pointForLight.zx);

               float3 finalCol = lerp( diffuseLight * tex,_FogColor, diffuseMask);
               return float4 (finalCol, 1);
               
               float3 finalColWithHalo = lerp( finalCol + _FogColor/5,1, maskForHalo);

               float3 haloColor = maskForHalo * _FogColor * 5;

               //return float4(finalCol, 1.0);
               return float4(finalColWithHalo + haloColor, 1.0);

               //col  = col/8;
                
               //return col;
            }
            ENDCG
        }
    }
}
