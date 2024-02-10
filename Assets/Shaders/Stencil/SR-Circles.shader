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

            float3 aces_tonemap(float3 color)
            {	
	            float3x3 m1 = float3x3(
                    0.59719, 0.07600, 0.02840,
                    0.35458, 0.90834, 0.13383,
                    0.04823, 0.01566, 0.83777
	            );
	            float3x3 m2 = float3x3(
                    1.60475, -0.10208, -0.00327,
                    -0.53108,  1.10813, -0.07276,
                    -0.07367, -0.00605,  1.07602
	            );
	            float3 v = mul(m1 , color);    
	            float3 a = v * (v + 0.0245786) - 0.000090537;
	            float3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
	            return pow(clamp(mul(m2 , (a / b)), 0.0, 1.0), float3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2));	
            }

            float3 palette(float t, float3 a, float3 b, float3 c, float3 d)
            {
                return a + b*cos(6.28318*(c*t+d));
            }

            float circles(float2 uv, float n, float speed, float width)
            {
                float t = _Time.y*_FinalSpeed + _TimeScrub;
                float d = length(uv);
                d = sin(d*n + (t*speed))/width;
                d = abs(d);
                d = 0.02/d;
                return saturate(d);
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float2 uv = (i.uv-.5)*_Aspect.yx;
               uv.x+=_Time.x*0.5;
               float2 uv0 = uv*_Scale;


               float finalColor = 0;
               float tVal = sin(3.141592 * length(uv0));
               finalColor += circles(uv0, 3, -.5, 1);
               finalColor += circles(frac(1.5*uv0)-0.5, 3, 1, 1);
               finalColor += circles(frac(2.75*uv0-1.85)-0.5, 2, .5, 2);

               //finalColor = pow(finalColor, 1.2);
               finalColor += 0.08;

               return finalColor;
            }
            ENDCG
        }
    }
}
