Shader "Unlit/MovingShader"
{
    Properties
    {
        _MainTe ("Texture", 2D) = "white" {}
        _PerlinNoise ("Texture", 2D) = "white" {}

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

            sampler2D _MainTe;
            sampler2D _PerlinNoise;
            float4 _MainTe_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTe);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTe, i.uv);
                float4 noise = tex2D(_PerlinNoise, i.uv);
                //noise = step(noise, 0);
                float lerppp = lerp(float4(0,0,0,1), col, noise);
                return lerppp;
            }
            ENDCG
        }
    }
}
