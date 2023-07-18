Shader "Hidden/Circles"
{
       Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Aspect("Aspect", Vector) = (1,1,1,1)
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

            sampler2D _MainTex;
            float2 _Aspect;

            float3 palette(float t, float3 a, float3 b, float3 c, float3 d)
            {
                return a + b*cos(6.28318*(c*t+d));
            }

            float3 circles(float3 col, float2 uv, float n, float speed, float width)
            {
                float d = length(uv);
                d = sin(d*n + (_Time.y*speed))/width;
                d = abs(d);
                d = 0.02/d;
                return col*d;
            }

            float2 RotateOverTime(float2 uv)
            {
                float2 newVec = float2(0,0);
                float c = cos(_Time.z);
                float s = sin(_Time.z);
                newVec.x = c*uv.x - s*uv.y;
                newVec.y = s*uv.x + c*uv.y;
                return newVec;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float2 uv = (i.uv-.5)*_Aspect.yx;
               float2 uv0 = uv;
               float3 col = float3(0.381, 0.254, 0.889001); 
               float3 col2 = float3(0.722897, 0.562254, 0.40161);
               float3 col3 = float3(0.85, 0.22, 0.22);
               float3 col4 = float3(0.35, 0.64, 0.89);

               float3 finalColor = float3(0,0,0);

               finalColor += circles(lerp(col, col3, sin(6.2831853*length(uv0))), uv, 3, -0.45, 4);
               finalColor += circles(lerp(col2, col4, sin(6.2831853*length(uv0))), frac(2.5*uv)-0.5, 4, -0.45,3);
               finalColor += circles(lerp(col3, col, sin(6.2831853*length(uv0))), frac(5*uv)-0.5, 3, 0.45, 2);
               finalColor += circles(lerp(col4, col2, sin(6.2831853*length(uv0))), frac(5*uv)-0.5, 2, -0.45, 0.5);


               finalColor = pow(finalColor, 1.2);

               return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
