Shader "Unlit/TileBackground"
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                i.uv = 4 * i.uv;
                float2 x = frac(i.uv);
                
                x.r = sin(3.14 * x.r) ;
                x.r = pow(x.r, 1);
                x.g = sin(3.14 * x.g);
                x.g = pow(x.g, 1);
                float v = x.g * x.r;
                v = pow(v,0.7);
                //v = 1 - v;
                //x = 1 - x;
                float4 col = tex2D(_MainTex, i.uv);
                //return float4(x.r,x.r,x.r,1);
                //return float4(x.g,x.g,x.g,1);

                return float4(v,v,v,1);
            }
            ENDCG
        }
    }
}
