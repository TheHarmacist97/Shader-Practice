Shader "Unlit/Clouds"
{
    Properties
    {
        //[Header("Time Variables")]
        _MainTex ("Texture", 2D) = "white" {}
        _TRate("Time Rate", float) = 1.0
        _TScrub("Time Scrub", float) = 1.0
        _CloudScale("Cloud Scale", float) = 1.0
        skycolour1("Color 1", color) = (0.2, 0.4, 0.6)
        skycolour2("Color 2", color) = (0.4, 0.7, 1.0)
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
            static const float speed = 0.03;
            static const float clouddark = 0.5;
            static const float cloudlight = 0.3;
            static const float cloudcover = 0.2;
            static const float cloudalpha = 8.0;
            static const float skytint = 0.5;
            
            float3 skycolour1;
            float3 skycolour2;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //t stuff
            float _TRate, _TScrub;

            float _CloudScale;

            float2 hash( float2 p ) 
            {
	            p = float2(dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)));
	            return -1.0 + 2.0*frac(sin(p)*43758.5453123);
            }

            float noise( in float2 p )
            {
	            float2 i = floor(p + (p.x+p.y)*K1);	
                float2 a = p - i + (i.x+i.y)*K2;
                float2 o = (a.x>a.y) ? float2(1.0,0.0) : float2(0.0,1.0); //float2 of = 0.5 + 0.5*float2(sign(a.x-a.y), sign(a.y-a.x));
                float2 b = a - o + K2;
	            float2 c = a - 1.0 + 2.0*K2;
                float3 h = max(0.5-float3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	            float3 n = h*h*h*h*float3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
                return dot(n, 70.0);	
            }

            float fbm(float2 n) 
            {
	            float total = 0.0, amplitude = 0.1;
	            for (int iter = 0; iter < 7; iter++)
                {
		            total += noise(n) * amplitude;
		            n = mul(m , n);
		            amplitude *= 0.4;
	            }
	            return total;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.uv;
	            float2 uv = p;
                float time = _Time.y * _TRate + _TScrub;
                float q = fbm(uv * _CloudScale * 0.5);
    
                //ridged noise shape
	            float r = 0.0;
	            uv = uv * _CloudScale;
                uv -= q - time;
                float weight = 0.8;
                for (int iter=0; iter<8; iter++){
		            r += abs(weight*noise( uv ));
                    uv = mul(m,uv) + time;
		            weight *= 0.7;
                }
    
                //noise shape
	            float f = 0.0;
                uv = p;
	            uv *= _CloudScale;
                uv -= q - time;
                weight = 0.7;
                for (iter=0; iter<8; iter++){
		            f += weight*noise( uv );
                    uv = mul(m,uv) + time;
		            weight *= 0.6;
                }
    
                f *= r + f;
    
                //noise colour
                float c = 0.0;
                time = _Time.y * speed * 2.0;
                uv = p;
	            uv *= _CloudScale*2.0;
                uv -= q - time;
                weight = 0.4;
                for (iter=0; iter<7; iter++){
		            c += weight*noise( uv );
                    uv = mul(uv, m) + time;
		            weight *= 0.6;
                }
    
                //noise ridge colour
                float c1 = 0.0;
                time = _Time.y * speed * 3.0;
                uv = p;
	            uv *= _CloudScale*3.0;
                uv -= q - time;
                weight = 0.4;
                for (iter=0; iter<7; iter++){
		            c1 += abs(weight*noise( uv ));
                    uv = mul(m,uv) + time;
		            weight *= 0.6;
                }
	
                c += c1;
    
                float3 skycolour = lerp(skycolour2, skycolour1, p.y);
                float3 cloudcolour = float3(1.1, 1.1, 0.9) * clamp((clouddark + cloudlight*c), 0.0, 1.0);
   
                f = cloudcover + cloudalpha*f*r;
    
                float3 result = lerp(skycolour, clamp(skytint * skycolour + cloudcolour, 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    
	            return float4( result, 1.0 );
            }
            ENDCG
        }
    }
}
