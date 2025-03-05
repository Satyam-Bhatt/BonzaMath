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
        _LightColor("Light Color", Color) = (1.0, 0.9, 0.8, 1.0)

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
            float4 _MainTex_ST, _FogColor, tex, _LightColor;
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

            //==================== Spiral Spheres =================
            float GetDist(float3 position)
            {
                float distanceToPlane = position.y;

                float3 spherePosition = float3(0,0,0);
                float radius = 0.4;

                float originalZ = position.z + (_Time.y);

                float testSphere = length(position - spherePosition) - radius;
                //return testSphere;

                //position.z += (_Time.y);//Movement but camera Movemenet is a bit better

                //Spiral Rotation
                position.xy = mul(position.xy, Rotation(_Time.y * 0.5 + originalZ * 0.1));
                 
				//tex /= 3;

                //Apply sin wave to the y component
				//position.y += 0.8 * sin(position.z * 0.5); // No Movemenet
                position.y += 0.2 * sin(originalZ * 0.5 + _Time.y * 1.5); //Serpent movement cool
                position.x += 0.2 * cos(originalZ * 0.5 + _Time.y * 1.5); //Spiral Movement xy

                tex = tex2D(_MainTex, position.xy);
                tex += tex2D(_MainTex, position.yz);
				tex += tex2D(_MainTex, position.zx);

                //-> Spiral and Zoom
                //-> Sin Wave + Zoom + Camera Offset from ShaderToy
                //-> Bouncing Spheres
                //-> Smoothstep Wave

                position  = position * float3(1,1,0.8);//Scaling

                float3 repeat  = position;
                //repeat = ModOperator(position, 2) - 1;//Repeats in all planes
                //Comment one out to repeat in specific plane
                repeat.x = ModOperator(position.x, _value1) - 1;
                repeat.z = ModOperator(position.z, _value2) - 0.5;
                repeat.y = ModOperator(position.y, _value3) - 1;

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

            float ease_step(float x, float k) {
                return floor(x) + (fmod(x, 1.0) < k ? smoothstep(0.0, 1.0, smoothstep(0.0, 1.0, (x - floor(x)) / k)) : 1.0);
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
                float3 light = _LightColor.rgb * diffuse1 * 0.7 + float3(0.5, 0.7, 1.0) * diffuse2 * 1;
                
                // Add ambient light
                light += float3(0.1, 0.1, 0.15);
                
                return light;
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

            float3 AnimateCamera(float3 ro, float3 rd)
{
    ro.y += sin(_Time.y * 0.5) * 0.1;
    ro.x += cos(_Time.y * 0.3) * 0.1;
    return ro;
}

float3 ApplyBloom(float3 color, float2 uv)
{
    float2 center = uv - 0.5;
    float vignette = 1.0 - dot(center, center);
    vignette = pow(vignette, 2.0);
    return color * vignette;
}

float3 ApplyColorGrading(float3 color)
{
    float3 gradedColor = pow(color, 2); // Gamma correction
    gradedColor = lerp(gradedColor, gradedColor * float3(1.1, 1.0, 0.9), 0.5); // Warm tint
    return gradedColor;
}

float3 GetObjectColor(float3 position, float3 normal)
{
    float3 baseColor = float3(0.8, 0.3, 0.2);
    float3 accentColor = float3(0.2, 0.5, 0.8);
    float3 gradientColor = lerp(baseColor, accentColor, smoothstep(-1.0, 1.0, position.y));
    return gradientColor * (normal.y * 0.5 + 0.5);
}

float AmbientOcclusion(float3 p, float3 n)
{
    float occlusion = 0.0;
    float weight = 1.0;
    for (int i = 0; i < 5; i++)
    {
        float len = 0.01 + 0.02 * float(i * i);
        float dist = GetDist(p + n * len);
        occlusion += (len - dist) * weight;
        weight *= 0.85;
    }
    return clamp(1.0 - occlusion, 0.0, 1.0);
}

            float4 frag(v2f i) : SV_Target
{
    float2 uv = i.uv * 2 - 1;
    uv.x *= 0.8;

    float3 rayOrigin = float3(0, 2, -3);
    float3 rayDirection = normalize(float3(uv.x, uv.y, 1));

    rayOrigin = AnimateCamera(rayOrigin, rayDirection);

    int steps = 0;
    float dist = RayMarch(rayOrigin, rayDirection, steps);

    float3 color = float3(0, 0, 0);

    if (dist < MAXDIST)
    {
        float3 hitPos = rayOrigin + dist * rayDirection;
        float3 normal = GetNormal(hitPos);

        // Lighting
        float3 light = GetLight(hitPos);
        float ao = AmbientOcclusion(hitPos, normal);

        // Object color
        float3 objectColor = GetObjectColor(hitPos, normal);

        // Combine lighting and color
        color = objectColor * light * ao;

        // Rim lighting
        float rim = 1.0 - max(dot(normal, -rayDirection), 0.0);
        rim = pow(rim, 2.0);
        color += float3(0.5, 0.7, 1.0) * rim * 1;
    }

    // Post-processing
    color = ApplyBloom(color, i.uv);
    color = ApplyColorGrading(color);
    float diffuseMask = saturate(dist/float(_FogStr));
    float3 finalCol = lerp( color * tex,_FogColor, diffuseMask);


    return float4(finalCol, 1.0);
}
            ENDCG
        }
    }
}
