Shader "Unlit/WallRunShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (0,0,0,0)
        [HDR]_Color2("Color2", Color) = (0,0,0,0) 
        _Width ("Line Thickness", float) = 0.2
        _Pos("Point Position", vector) = (0,0,0)
        _Div("Line Divisions", float) = 5.0
        _Dampener("Dampener", float) = 5.0
        _Power("Power", Range(-100, 0)) = 5.0

       
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul( unity_ObjectToWorld, v.vertex);
                return o;
            }
            float4 _Color, _Color2;
            float _Width, _Div, _Area, _Dampener, _Power;
            float3 _Pos;
            fixed4 frag (v2f i) : SV_Target
            {
                float3 pos = _WorldSpaceCameraPos;
                float2 uv = (i.uv-0.5)*2;
                uv = frac(uv*_Div);
                float d = uv.y;
                d = smoothstep(0.5+_Width,0.5,d) - smoothstep(0.5,0.5-_Width,d);
                float l = length(i.worldPos - pos);
                float falloff = saturate(pow(l, _Power)/_Dampener);
                float4 finalCol = lerp(_Color2, _Color, falloff) * d * falloff;
                return finalCol;
            }
            ENDCG
        }
    }
}
