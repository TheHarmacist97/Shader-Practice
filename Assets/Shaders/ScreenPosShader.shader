Shader "Custom/ScreenPos"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Texture Scale", float) = 1.0
        _FresnelPower("Fresnel Power", float) = 1.0
        [HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _UVOffset("Offset", Vector) = (0,0,0,0)
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD1;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _FresnelColor;
            float _Scale;
            float _FresnelPower;
            float2 _UVOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = i.screenPosition.xy/i.screenPosition.w*_Scale;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                screenUV.x*=aspect;

                float2 textureCoordinate = TRANSFORM_TEX(screenUV, _MainTex);
                textureCoordinate += _UVOffset;
                fixed4 col = tex2D(_MainTex, textureCoordinate);
                float fresnelVal = pow(1 - saturate(dot(i.normal, i.viewDir)), _FresnelPower);
                fresnelVal*= 1 + sin(_Time.y)*0.5;
                col += fresnelVal*_FresnelColor;
                return col;
            }
            ENDCG
        }
    }
}
