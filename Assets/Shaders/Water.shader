Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaxIter("Fractal level",Range(1,10)) = 2.0
        _BaseWaterColor("Color of the water", color) = (1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            float _MaxIter;
            float3 _BaseWaterColor;

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul( unity_ObjectToWorld,v.vertex);
                float yx = sin(worldPos.x*0.72 + _Time.y);
                float yz = sin(worldPos.z*0.85 - _Time.y*2.0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex.y += (yx+yz)*5.;

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
