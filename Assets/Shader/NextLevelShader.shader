Shader "Unlit/NextLevelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AspectRatioCorrection ("Aspect Ratio Correction", float) = 1.0
        _ScaleX ("Scale X", Float) = 1.0
        _ScaleY ("Scale Y", Float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)

    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        ZTest[unity_GUIZTestMode]
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define PI 3.141592653589793
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR0;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AspectRatioCorrection;
            float _ScaleX;
            float _ScaleY;
            float4 _Color;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
                return o;
            }

            float SDF_Box(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);
            }


float3 palette_sunset_green(in float t)
{
    float3 color1 = float3(0.4941, 0.7843, 0.4941); // #7EC87E
    float3 color2 = float3(0.8235, 0.9411, 0.8235); // #D2F0D2

    float3 a = (color1 + color2) * 0.5;
    float3 b = (color2 - color1) * 0.5;
    float3 c = float3(1.0, 1.0, 1.0);
    float3 d = float3(0.0, 0.0, 0.0);

    return a + b*cos(6.28318*(c*t+d));
}


            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                
                float screenAspect = _ScreenParams.x / _ScreenParams.y;
                
                if (screenAspect > 1.0) {
                    uv.x *= screenAspect;
                } else {
                    uv.y /= screenAspect;
                }
                
                // Apply custom scaling
                uv.x /= _ScaleX;
                uv.y /= _ScaleY;
                
                uv *= _AspectRatioCorrection;
                
                float center = SDF_Box(uv, float2(1.6, 0.2)) - 0.1;
                //return center;
                float repeat = cos(center * PI - _Time.y * 2) * 0.5 + 0.5;
                //return repeat;
                center = center;
                center = pow(center, 2);
                //return center;
                repeat = repeat * center;

                float3 colll = palette_sunset_green(repeat);
                   
                return float4(colll,1) * i.color;
                
                return float4(1 - repeat.xxx, 1);
            }
            ENDCG
        }
    }
}
