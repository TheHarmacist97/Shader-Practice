Shader "Unlit/VertexSkew"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Animation Speed", float) = 1.0
        _Frequency("Skew Frequency", float) = 1.0
        _Scale("Skew Scale", float) = 1.0
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 col : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
           float _Speed, _Frequency, _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                float4 inVert = 0;
                inVert = UnityObjectToClipPos(v.vertex);
                inVert.x += sin(_Time.y * _Speed + inVert.y * _Frequency)*_Scale;
                o.vertex = inVert;
                o.col = float4(v.normal, 0.0)*0.5+0.5;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = i.col;
                return col;
            }
            ENDCG
        }
    }
}
