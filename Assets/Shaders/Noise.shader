Shader "Hidden/Noise"
{
    Properties
    {
        [HDR]_Col1("Color 1",color) = (1,1,1,1)
        [HDR]_Col2("Color 2", color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float GetNoise(float2 uv)
            {
                float x = 0;
                x = (sin(uv.x) * cos(uv.y));
                x += (sin(uv.x*3.0) * cos(uv.y*1.5));
                x += (sin(uv.x*.3) * cos(uv.y*.6));
                x += (sin(uv.x*9.) * cos(uv.y*18));
                return x;
            }

            sampler2D _MainTex;
            float4 _Col1, _Col2;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv*=20;
                uv.x+=_Time.w;
                float4 col = GetNoise(uv);
                float2 uv2 = i.uv;
                uv2.y -=_Time.x;
                col *=  lerp(_Col1, _Col2, GetNoise(uv2));
                return col;
            }
            ENDCG
        }
    }
}
