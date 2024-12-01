Shader "Unlit/Shadertoy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define H(p) sin(iTime*.5+fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)*10.)*.5+.5

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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv_ = i.uv * 2;
                uv_ = floor(uv_);
                float h = sin(_Time.y*2+frac(sin(dot(uv_, float2(12.9898, 78.233))) * 43758.5453)*10.)*.5+.5;
                float4 col = lerp(float4(.4,.5,.6,1), float4(1,.9,.6,1), h);
                return col;
            }
            ENDCG
        }
    }
}
