Shader "Unlit/Clouds"
{
    Properties
    {
        //[Header("Time Variables")]
        _MainTex("Texture", 2D) = "white" {} 
        _TRate("Time Rate", float) = 1.0
        _TScrub("Time Scrub", float) = 1.0
        _CloudScale("Cloud Scale", float) = 1.0
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            static const float2x2 m = {1.6,1.2,-1.2,1.6};
            static const float K1 = 0.366025404;
            static const float K2 = 0.211324865;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //time stuff
            float _TRate, _TScrub;

            float _CloudScale;

            float2 hash( float2 uv )
            {
	            uv = float2(dot(uv,float2(127.1,311.7)), dot(uv,float2(269.5,183.3)));
	            return -1.0 + 2.0*frac(sin(uv)*43758.5453123);
                //float2 o = (a.x>a.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
                //float2 b = a - o + K2;
                //float2 c = a - o + K2;
                //float3 h = max(0.5-float3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	            //float3 n = h*h*h*h*float3( dot(a,hash(id+0.0)), dot(b,hash(id+o)), dot(c,hash(id+1.0)));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = (i.uv-0.5)*2.0;
                float t = _Time.y * _TRate + _TScrub;
                float2 id = floor(uv + (uv.x+uv.y)*K1);
                float2 a = uv - id + (id.x+id.y)*K2;
                fixed4 col = float4(a, 0, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
