Shader "Custom/ScreenPos"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 textureCoordinate = i.screenPosition.xy/i.screenPosition.w *0.5;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                textureCoordinate.x*=aspect;
                textureCoordinate = TRANSFORM_TEX(textureCoordinate, _MainTex);
                textureCoordinate.x+=_Time.x;
                fixed4 col = tex2D(_MainTex, textureCoordinate);
                return col;
            }
            ENDCG
        }
    }
}
