Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseWaterColor("Color of the water", color) = (1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
            float3 _BaseWaterColor;

            struct waveData
            {
                float wLength;
                float amplitude;
                float phi;
                float2 direction;
            };
            uniform StructuredBuffer<waveData> _Waves;
            int _NumberOfWaves;

            float GetHeight(waveData wave, float2 xz)
            {
                float height = wave.amplitude * sin(dot(wave.direction,xz)*wave.wLength + _Time.y+wave.phi);
                return height;
            }


            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul( unity_ObjectToWorld,v.vertex);
                float finalHeight = 0;
                for(int iter = 0; iter<_NumberOfWaves; iter++)
                {
                    finalHeight += GetHeight(_Waves[iter], worldPos.xz);
                }
                v.vertex.y += finalHeight;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(_BaseWaterColor, 1.0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
