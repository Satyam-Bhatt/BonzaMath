Shader "Unlit/AspectRatioCorrectedShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Speed ("Animation Speed", Range(0.05, 2.0)) = 0.2
        _Scale ("Pattern Scale", Range(1.0, 30.0)) = 10.0
        _BlendSmoothing ("Blend Smoothing", Range(0.0, 1.0)) = 0.2
        _AspectRatioCorrection ("Aspect Ratio Correction", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        ZTest[unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _Speed;
            float _Scale;
            float _BlendSmoothing;
            float _AspectRatioCorrection;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }
            
            float3 palette( in float t)
            {
                float3 a = float3(0.6, 0.5, 0.6);
                float3 b = float3(0.2, 0.2, 0.3);
                float3 c = float3(0.8, 0.8, 0.8);
                float3 d = float3(0.0, 0.1, 0.2);

                return a + b*cos( 6.28318*(c*t+d) );
            }

            float3 palette_blue_peach_gradient(in float t)
            {
                // Convert hex colors to float3 (RGB in 0-1 range)
                float3 color1 = float3(0.5019, 0.5647, 0.7372); // #8090BC
                float3 color2 = float3(1.0, 0.9215, 0.7960);   // #FFEBCB
    
                // Create a smooth transition between colors
                float3 a = (color1 + color2) * 0.5;            // Average as base
                float3 b = (color2 - color1) * 0.5;            // Half the difference as amplitude
                float3 c = float3(1.0, 1.0, 1.0);              // Uniform frequency
                float3 d = float3(0.0, 0.0, 0.0);              // No phase shift
    
                return a + b*cos(6.28318*(c*t+d));
            }

            
            float Random(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
            }
            
            float RandomWithMovement(float2 uv)
            {
                // Adding more interesting movement pattern
                float baseNoise = Random(uv);
                float wave1 = sin(_Time.y * 0.4 + baseNoise * 6.28318);
                float wave2 = sin(_Time.y * 0.3 + baseNoise * 3.14159);
                return (wave1 * wave2 * 0.5 + 0.5);
            }
            
            float4 frag (v2f i) : SV_Target
            {
                // Get screen dimensions for aspect ratio calculation
                float2 screenSize = _ScreenParams.xy;
                float aspectRatio = screenSize.x / screenSize.y;
                
                // Apply aspect ratio correction to UVs
                float2 uv = i.uv;
                if (aspectRatio > 1.0)
                {
                    // Landscape orientation
                    uv.x = uv.x * aspectRatio * _AspectRatioCorrection ;
                }
                else
                {
                    // Portrait orientation
                    uv.y = uv.y / aspectRatio * _AspectRatioCorrection ;
                }
                
                // Create a continuous version for smooth animations
                float2 continuous_uv = _Scale * uv;
                
                // Create a quantized version for the grid effect
                float2 grid_uv = floor(continuous_uv);
                
                //return float4(palette_oceanic_depth(uv.x),1);

                // Get palette colors with improved animation
                float time = _Time.y * _Speed;
                float3 col1 = palette(grid_uv.y * 0.05 + time * 0.2);
                float3 col2 = palette_blue_peach_gradient(grid_uv.x * 0.05 + time * 0.15);
                
                // Get random value with smoother animation
                float ran = RandomWithMovement(grid_uv);
                
                // Smooth the transition between colors
                float blend = smoothstep(0.0, _BlendSmoothing, ran) * 
                             smoothstep(1.0, 1.0 - _BlendSmoothing, ran);

                float lerpFactor = lerp(ran, blend, 0.7);
                
                // Create final color with improved blending
                float3 colMain = lerp(col1, col2, lerpFactor);
                
                return float4(colMain, 1);
            }
            ENDCG
        }
    }
}