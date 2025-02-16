Shader "Unlit/WhyNotAnotherShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width ("Width", Float) = 1.0
        _Height ("Height", Float) = 1.0
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
            float _Width;
            float _Height;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float SDF_Box(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d, float2(0,0))) + min(max(d.x, d.y), 0.0);
            }

            float3 palette( in float t)
            {
                float3 a = float3(0.6, 0.5, 0.6);
                float3 b = float3(0.2, 0.2, 0.3);
                float3 c = float3(0.8, 0.8, 0.8);
                float3 d = float3(0.0, 0.1, 0.2);

                return a + b*cos( 6.28318*(c*t+d) );
            }


            float4 frag (v2f i) : SV_Target
            {
                float aspectRatio = _Width / _Height;
                
                float2 uv = i.uv * 2 - 1;

                float finalCreation = 10000;
                
                uv.x *= aspectRatio;
                uv.y /= aspectRatio;
                
                float square = SDF_Box(uv, float2(0.2, 0.1));
                finalCreation = 1- floor(15*square)/15;

                float3 col = palette(finalCreation + _Time.y * 0.2);

                float2 uv2 = i.uv * 2 - 1;
                
                // Adjust UV based on aspect ratio
                if (aspectRatio > 1.0) {
                    uv2.x *= aspectRatio;
                } else {
                    uv2.y /= aspectRatio;
                }
                float clip = SDF_Box(uv2, float2(1.5, 0.85)) - 0.2;
                clip = step(clip, 0);
                if(clip == 0) discard;
                //return clip;

                return float4(col,1);
            }
            ENDCG
        }
    }
}
