Shader "Unlit/Confuse"
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

            float GetDist(float3 position)
            {
                position.z = position.z + _Time.y;
                float originalZ = position.z;
				float originalX = position.x;

                float distanceToPlane = position.y + sin(originalZ * 1 + _Time.y * 4) * 0.1 + sin(originalX * 1 + _Time.y * 4) * 0.1;

                // Define orbit center and radius
                float3 orbitCenter = float3(0, 0, 0); // Change this to your desired center point
                float orbitRadius = 4.0; // Change this to control how far it orbits
                float orbitSpeed = 1; // Controls orbit speed

                // Calculate orbit position
                float orbitAngle = _Time.y * orbitSpeed;
                float orbitX = orbitCenter.x + orbitRadius * sin(orbitAngle);
                float orbitZ = orbitCenter.z + orbitRadius * cos(orbitAngle);

                float v = 6;
                v += _Time.y;
                float3 positionForTorus = position.xzy - float3(orbitX,v,orbitZ);
                positionForTorus.xy = mul(positionForTorus.xy, Rotation(_Time.y));
                float torus = sdTorus(positionForTorus, float2(0.8, 0.2));

                float3 spherePosition = float3(0,0,1);
                float radius = 0.4;

                position.y += (smoothstep(0,2,sin(originalZ * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,1));
                position.y += (smoothstep(0,2,sin(originalX * 1 + _Time.y * 4)) * clamp(hash(floor(originalZ)),0,1));

                float3 repeat  = position;
                //Comment one out to repeat in specific plane
                repeat.x = ModOperator(position.x, _value1) - 1;
                repeat.z = ModOperator(position.z, _value2) - 1;
                //repeat.y = ModOperator(position.y, _value3) - 1;

                float sphereDistance = length(repeat - spherePosition) - radius;

                float output = opSmoothUnion(distanceToPlane, sphereDistance, 0.6);
                output = opSmoothUnion(output, torus, 0.5);

                return output;
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection, out int val)
            {
                float distanceOrigin = 0;
                int i;
                for(i = 0; i < STEPS; i++)
                {
                    float3 firstPointOfContact = rayOrigin + distanceOrigin * rayDirection;
                    float distanceToTheObject = GetDist(firstPointOfContact);
                    distanceOrigin += distanceToTheObject * 0.95; // Slightly reduce step size for better accuracy
                    
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

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1; // Center the scene
                uv.x *= 0.8; // Adjust aspect ratio
                
                float3 rayOrigin = float3(0,1,0);
                
                // Ray direction with proper camera orientation
                float3 rayDirection = normalize(float3(uv.x, uv.y,1));

                //rayDirection.xz = mul(rayDirection.xz, Rotation(ease_step(_Time.y * 0.25, 0.25) * (PI/2)));
                //rayDirection.xy = mul(rayDirection.xy, Rotation(ease_step(_Time.y * 0.25 + 0.5, 0.25) * (PI/2)));
                
                // Ray march
                int steps = 0;
                float dist = RayMarch(rayOrigin, rayDirection, steps);
                
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
                    float3 objectColor = float3(0.8, 0.3, 0.2) * (normal.y * 0.5 + 0.5) +
                                         float3(0.2, 0.5, 0.8) * (normal.x * 0.5 + 0.5) +
                                         float3(0.3, 0.6, 0.3) * (normal.z * 0.5 + 0.5);
                    
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