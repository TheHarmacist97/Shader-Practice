Shader "Unlit/SR-Circles"
{
    Properties
    {
        MainTex ("Texture", 2D) = "white" {}
        _Aspect("Aspect", Vector) = (1,1,1,1)
        [IntRange]_Ref("Stencil Read value", Range(1,255)) = 1
        col("Color 1", Color) = (1,0,0,1)
        col2("Color 2", Color) = (0.2, 0.4, 0.6, 1)
        col3("Color 3", Color) = (0.2, 0.4, 0.6, 1)
        _FinalSpeed("Time Rate", float) = 1.
        _TimeScrub("Scrub", float) = 0.
        _Scale("Scale", float) = 1.

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Front
        LOD 100

        Stencil
        {
            Ref [_Ref]
            Comp Equal
        }

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

           

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _Aspect;
            float3 col, col2, col3;
            float _FinalSpeed, _TimeScrub, _Scale;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 palette(float t, float3 a, float3 b, float3 c, float3 d)
            {
                return a + b*cos(6.28318*(c*t+d));
            }

            float3 circles(float3 col, float2 uv, float n, float speed, float width)
            {
                float t = _Time.y*_FinalSpeed + _TimeScrub;
                float d = length(uv);
                d = sin(d*n + (t*speed))/width;
                d = abs(d);
                d = 0.02/d;
                return saturate(col*d);
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float2 uv = (i.uv-.5)*_Aspect.yx;
               float2 uv0 = uv*_Scale;

               float3 finalColor = 0;

               finalColor += circles(lerp(col, col2, sin(6.2831853*length(uv0))), uv*_Scale, 3, -0.45, 1);
               finalColor += circles(lerp(col, col2, sin(6.2831853*length(uv0))), frac(1.75*uv*_Scale)-0.5, 3, 0.45, 1);
               finalColor += circles(lerp(col3, col, sin(6.2831853*length(uv0))), frac(2*uv*_Scale)-0.5, 2, 0.9, 2);


               //finalColor = pow(finalColor, 1.2);

               return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
