Shader "Unlit/CuteSister"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _value1("Value1" , Float) = 0
        _value2("Value2" , Float) = 0
        _value3("Value3" , Float) = 0
        _FogStr("Fog Strength" , Range(0.01, 0.1)) = 0.03
        _FogColor("Fog Color", Color) = (0.5, 0.6, 0.7, 1.0)
        _LightColor("Light Color", Color) = (1.0, 0.9, 0.8, 1.0)
        _CellSize("Cell Size", Range(1.0, 10.0)) = 4.0
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
            #define MINDIST 0.0001
            #define SURF_DIST 1
            #define PI 3.141592653589793
            #define OBJ_NONE 0
            #define OBJ_SPHERE 1
			#define OBJ_TORUS 2
			#define OBJ_PLANE 3
            #define OBJ_SPHERE_SINGLE 4

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
            float4 _FogColor, _LightColor, tex;
            float _CellSize;

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

            float hash(float n) 
            {
                return frac(sin(n) * 43758.5453);
            }

            float ease(float x) {
                return smoothstep(0.0, 1.0, x);
            }

            float ease_step(float x, float k) {
                return floor(x) + (fmod(x, 1.0) < k ? smoothstep(0.0, 1.0, smoothstep(0.0, 1.0, (x - floor(x)) / k)) : 1.0);
            }

            float length2(float3 p) { p=p*p; return sqrt(p.x+p.y+p.z); }
            float length6(float3 p) { p=p*p*p; p=p*p; return pow(p.x+p.y+p.z,1.0/6.0); }
            float length8(float3 p) { p=p*p; p=p*p; p=p*p; return pow(p.x+p.y+p.z,1.0/8.0); }
            float length8(float2 p) { p=p*p; p=p*p; p=p*p; return pow(p.x+p.y,1.0/8.0); }
            float length2(float2 p) { return sqrt(p.x*p.x+p.y*p.y); }

            float sdTorus82(float3 p, float2 t)
            {
                float2 q = float2(length8(p.xz)-t.x,p.y);
                return length2(q)-t.y;
            }

            float sdRoundBox(float3 p, float3 b, float r)
            {
                float3 q = abs(p) - b + r;
                return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
            }

            float sdTorus(float3 p, float2 t)
            {
                float2 q = float2(length(p.xz)-t.x,p.y);
                return length(q)-t.y;
            }

            float sdSphere( float3 p, float s )
            {
              return length(p)-s;
            }

            float sdBoxFrame(float3 p, float3 b, float e)
            {
                p = abs(p)-b;
                float3 q = abs(p+e)-e;
                return min(min(
                    length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
                    length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
                    length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
            }

            
            float opSmoothUnion( float d1, float d2, float k )
            {
                float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
                return lerp( d2, d1, h ) - k*h*(1.0-h);
            }

            float opSmoothSubtraction( float d1, float d2, float k )
            {
                float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
                return lerp( d2, -d1, h ) + k*h*(1.0-h);
            }

            float opSmoothIntersection( float d1, float d2, float k )
            {
                float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
                return lerp( d2, d1, h ) + k*h*(1.0-h);
            }

            float GetDist(float3 position , out int objectID)
            {
                objectID = OBJ_NONE;

                position.z = position.z + _Time.y;
                position.x = position.x + _Time.y * 0.5;
                float originalZ = position.z;
				float originalX = position.x;

                float distanceToPlane = position.y + sin(originalZ * 1 + _Time.y * 4) * 0.1 + sin(originalX * 1 + _Time.y * 4) * 0.1;
                float minDist = distanceToPlane;
				objectID = OBJ_PLANE;

                // Define orbit center and radius
                float3 orbitCenter = float3(0, 0, 0); // Change this to your desired center point

                // Calculate orbit position
                float orbitX = orbitCenter.x + 4 * sin(_Time.y * 1) + _Time.y * 0.5;
                float orbitZ = orbitCenter.z + 5 * cos(_Time.y * 2);

                float v = 6;
                v += _Time.y;
                float3 positionForTorus = position.xzy - float3(orbitX,v,orbitZ);
                positionForTorus.xy = mul(positionForTorus.xy, Rotation(_Time.y * 2));
                float torus = sdTorus(positionForTorus, float2(0.8, 0.08));

                float3 positionForTorus2 = position.xzy - float3(orbitX,v,orbitZ);
                positionForTorus2.yz = mul(positionForTorus2.yz, Rotation(-_Time.y * 3));
				float torus2 = sdTorus(positionForTorus2, float2(0.569, 0.05));

                float3 positionForTorus3 = position.xzy - float3(orbitX,v,orbitZ);
                positionForTorus3.xy = mul(positionForTorus3.xy, Rotation(-_Time.y * 4));
				float torus3 = sdTorus(positionForTorus3, float2(0.36, 0.06));

                float3 positionForSphere = position.xyz - float3(orbitX,orbitZ,v);
				float sphere_Center = sdSphere(positionForSphere, 0.2);

                float3 spherePosition = float3(0,0,1);
                float radius = 0.4;

                position.y += (smoothstep(0,2,sin(originalZ * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,1) * 2);
                position.y += (smoothstep(0,2,sin(originalX * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,1) * 2);

                float3 repeat  = position;
                //Comment one out to repeat in specific plane
                repeat.x = ModOperator(position.x, _value1) - 1;
                repeat.z = ModOperator(position.z, _value2) - 1;
                //repeat.y = ModOperator(position.y, _value3) - 1;

                float sphereDistance = length(repeat - spherePosition) - radius;

                if(sphere_Center < minDist)
                {
					objectID = OBJ_SPHERE_SINGLE;
					minDist = sphere_Center;
				}

                if(torus < minDist || torus2 < minDist || torus3 < minDist)
                {
					objectID = OBJ_TORUS;
					minDist = torus3;
                }

                if(sphereDistance < minDist)
                {
                    objectID = OBJ_SPHERE;
                    minDist = sphereDistance;
                }

                float ground = opSmoothUnion(distanceToPlane, sphereDistance, 0.6);
                float rotatingSpheres = opSmoothUnion(torus2, torus, 0.2);
				rotatingSpheres = opSmoothUnion(rotatingSpheres, torus3, 0.2);
                rotatingSpheres = opSmoothUnion(rotatingSpheres, sphere_Center, 0.2);

                float finalDist = opSmoothUnion(ground, rotatingSpheres, 0.8);

                return finalDist;
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection, out int hitObjectID)
            {
                float distanceOrigin = 0;
                hitObjectID = OBJ_NONE;
                int objectID = OBJ_NONE;

                for(int i = 0; i < STEPS; i++)
                {
                    float3 firstPointOfContact = rayOrigin + distanceOrigin * rayDirection;
                    float distanceToTheObject = GetDist(firstPointOfContact, objectID);
                    distanceOrigin += distanceToTheObject * 0.95;
                    
                    if(distanceOrigin > MAXDIST || distanceToTheObject < MINDIST)
                    {
                        hitObjectID = objectID;
                        break;
                    }
                }
                return distanceOrigin;
            }

            float3 GetNormal(float3 position)
            {
                float2 smallMarginShift = float2(0.0001, 0);
                int objectID = OBJ_NONE;
                float distanceToPoint = GetDist(position, objectID);

                float3 normal = float3(
                    distanceToPoint - GetDist(position - smallMarginShift.xyy, objectID),
                    distanceToPoint - GetDist(position - smallMarginShift.yxy, objectID),
                    distanceToPoint - GetDist(position - smallMarginShift.yyx, objectID)
                );

                return normalize(normal);
            }

            float3 GetLight(float3 position)
            {
                // Multiple light sources for more interesting lighting
                float3 lightPosition1 = float3(2 * sin(_Time.y * 0.5), 4, -5);
                float3 lightPosition2 = float3(-3, 2, -1);
                lightPosition2.xz = mul(lightPosition2.xz, Rotation(ease_step(_Time.y * 0.25, 0.25) * (PI/2)));
                lightPosition2.xy = mul(lightPosition2.xy, Rotation(ease_step(_Time.y * 0.25 + 0.5, 0.25) * (PI/2)));
                
                float3 normal = GetNormal(position);
                
                // Light 1 (moving)
                float3 lightVector1 = normalize(lightPosition1 - position);
                float diffuse1 = max(dot(normal, lightVector1), 0.0);
                
                // Light 2 (static)
                float3 lightVector2 = normalize(lightPosition2 - position);
                float diffuse2 = max(dot(normal, lightVector2), 0.0);
                
                // Combine lights with colors
                float3 light = _LightColor.rgb * diffuse1 * 0.7 + float3(0.5, 0.7, 1.0) * diffuse2 * 0.5;
                
                // Add ambient light
                light += float3(0.1, 0.1, 0.15);
                
                return light;
            }

            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float Dither(float2 uv)
            {
                return Random(uv) * 0.03 - 0.015; // Small random offset for dithering
            }

            float3 palette( in float t)
            {
                float3 a = float3(0.6, 0.5, 0.6);
                float3 b = float3(0.2, 0.2, 0.3);
                float3 c = float3(0.8, 0.8, 0.8);
                float3 d = float3(0.0, 0.1, 0.2);

                return a + b*cos( 6.28318*(c*t+d) );
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; // Center the scene
                uv.x *= 0.8; // Adjust aspect ratio
                
                float3 rayOrigin = float3(0,1,0);
                
                // Ray direction with proper camera orientation
                float3 rayDirection = normalize(float3(uv.x, uv.y,1));

                // Ray march
                int objectID = OBJ_NONE;
                float dist = RayMarch(rayOrigin, rayDirection, objectID);
                
                // Calculate fog based on distance and steps
                float fogAmount = 1 - exp2(-dist * _FogStr);

                // Initial color (black)
                float3 color = float3(0, 0, 0);
                
                // If we hit something
                if(dist < MAXDIST) {
                    float3 hitPos = rayOrigin + dist * rayDirection;
                    float3 lighting = GetLight(hitPos);
                    
                    // Add some color variation based on position and normal
                    float3 normal = GetNormal(hitPos);
                    float3 objectColor = float3(0,0,0);

                    if(objectID == OBJ_TORUS)
                    {
                        float3 upColor = float3(3, 1, 0.2);
    
                        float3 downColor = float3(0.9, 0.4, 0.6);
    
                        float3 normalColor = float3(0.8, 0.3, 0.2) * (normal.y * 0.5 + 0.5) +
                                             float3(0.2, 0.5, 0.8) * (normal.x * 0.5 + 0.5) +
                                             float3(0.3, 0.6, 0.3) * (normal.z * 0.5 + 0.5);
    
                        float3 paletteColor = normalColor + palette(dist * 0.5 + _Time.y * 1);

                        float blendFactor = 1 * cos(_Time.y * 2);
    
                        objectColor = lerp(paletteColor, upColor , blendFactor);
                    }
                    else if(objectID == OBJ_SPHERE_SINGLE)
                    {
                        float3 upColor = float3(4, 4, 0.2);
    
                        float3 downColor = float3(0.9, 0.4, 0.6);
    
                        float3 normalColor = float3(0.8, 0.3, 0.2) * (normal.y * 0.5 + 0.5) +
                                             float3(0.2, 0.5, 0.8) * (normal.x * 0.5 + 0.5) +
                                             float3(0.3, 0.6, 0.3) * (normal.z * 0.5 + 0.5);
    
                        float3 paletteColor = normalColor + palette(dist * 0.5 + _Time.y * 1);

                        float blendFactor = 0.4 * cos(_Time.y * 2);
    
                        objectColor = lerp(paletteColor, upColor , blendFactor);
                    }
                    else
                    {
                        objectColor = float3(0.8, 0.3, 0.2) * (normal.y * 0.5 + 0.5) +
                                      float3(0.2, 0.5, 0.8) * (normal.x * 0.5 + 0.5) +
                                      float3(0.3, 0.6, 0.3) * (normal.z * 0.5 + 0.5);

                        objectColor += palette(dist * 0.5 + _Time.y * 1);
                    }
                    
                    // Apply lighting to object color
                    color = objectColor * lighting;
                    
                    // Add rim lighting
                    float rim = 1.0 - max(dot(normal, -rayDirection), 0.0);
                    rim = pow(rim, 4.0);
                    color += float3(0.5, 0.7, 1.0) * rim * 0.5;
                }
                
                // Apply fog
                color = lerp(color, _FogColor.rgb, fogAmount);
                
                // Add dithering to reduce banding
                //color += Dither(i.uv);
                
                // Add some subtle vignette
                float vignette = length(i.uv - 0.5) * 0.5;
                color *= 1.0 - vignette;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
