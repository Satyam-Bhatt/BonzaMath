Shader "Unlit/MovingShader"
{
    Properties
    {
        _MainTe ("Texture", 2D) = "white" {}
        _PerlinNoise ("Noise", 2D) = "white" {}

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

            sampler2D _MainTe;
            sampler2D _PerlinNoise;
            float4 _MainTe_ST;
            float4 _PerlinNoise_ST;

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
                float2 noiseUV = i.uv;
                noiseUV.x = noiseUV.x * 0.2 + _Time.y * 0.1;
                float4 col = tex2D(_MainTe, i.uv);
                float4 noise = tex2D(_PerlinNoise, noiseUV);
                float2 uvcheck = i.uv + 0.2 * noise;
                float4 lerppp = lerp(col, float4(0,0,0,1), noise);
                return float4(uvcheck, 0,1);
            }
            ENDCG
        }
    }
}
