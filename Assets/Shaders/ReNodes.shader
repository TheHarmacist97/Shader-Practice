Shader "Hidden/ReNodes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _uvSize("Size", float) = 5.0
        _dotSpeed("Star movement speed", float) = 1.

        _secondaryUVSize("Back layer UV size", float) = 2.0
        _secondaryUVBrightness("Back layer brightness", Range(0.1, 1.0)) = 1.

        _LineBrightness("Line Brightness", Range(0.1, 3.0)) = 1.
        _maxThreshold("Max line connection threshold", float) = 0.
        _minThreshold("Min line connection threshold", float) = 0.

        _sparkleStrength("Strength of star sparkle", float) = 200.
        _yCutoff("Sky Cutoff", float) = 0.0
        _aspect("Aspect fix", float) =1.0
        [HDR]_baseColor("Base color", Color) = (0.2,0.3,0.8)

        _starSharpness("Sharpness of stars", float) = 5
        _starBrightness("Brightness of stars", Range(0.5,0)) = 0.0375
        _starSize("Size of stars", Range(0.075, 0.5)) = 0.15

        [HDR]_backFill("backFill color", Color) = (0.2,0.3,0.8)
        _fillMultiplier("fill value", Range(0,1)) = 0.

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
            #define TAU 6.28318

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

                        
            sampler2D _MainTex;
            float3 _baseColor;
            float _uvSize;
            float _aspect;
            
            float _secondaryUVSize;
            float _secondaryUVBrightness;
            
            float _LineBrightness;
            float _maxThreshold;
            float _minThreshold;
            float _dotSpeed;

            float _sparkleStrength;
            float _starSize;
            float _starBrightness;
            float _starSharpness;

            float _yCutoff;
            float3 _backFill;
            float _fillMultiplier;


            //distance to a line defined by point a and b
            //float2 p is the current fragment we're checking the distance against

            float GetRandomFloat(float2 x)
            {
                float2 p = frac(x*float2(41.31, 58.942)); //maths fuckery, leave it
                p += dot(p, p+41.89);
                return frac(p.x*p.y);
            }

            float2 GetRandom2D(float2 x)
            {
                float n = GetRandomFloat(x);
                return float2(n,GetRandomFloat(x+n));
            }
            
            //remember here, rather than using boids we can use a bigger gridValue and offset time value a bit
            float2 GetRandomPointInGrid(float2 id)
            {
                float2 noise = GetRandom2D(id);
                return sin(_Time.y*_dotSpeed*noise)*0.3;
            }

            float invLerp(float from, float to, float value)
            {
                return clamp((value - from) / (to - from),0,1);
            }

            float DistanceToLine(float2 p,  float2 a, float2 b)
            {
                float2 pa = p-a; //direction to point from point A
                float2 ba = b-a; //direction defining line
                float t = saturate(dot(pa,ba)/dot(ba,ba))*1;
                return length(pa -ba*t);
            }

            float Line(float2 p, float2 a, float2 b)
            {
                float dist = DistanceToLine(p,a,b);
                float m = smoothstep(0.015, 0.005, dist);
                m *= smoothstep(_maxThreshold, _minThreshold, length(a-b))*_LineBrightness;
                return m;
            }

            float2 RotateVec2D(float2 inVector, float time)
            {
               float s = sin(time);
               float c = cos(time);
               float2 rotVec = float2(0,0);
               rotVec.x = -s*inVector.x + c*inVector.y;
               rotVec.y = c*inVector.x + s*inVector.y;
               return rotVec;
            }

            float2 GetCorrectedUV(float3 worldPos)
            {
                worldPos = normalize(worldPos);
                float yAsin = asin(worldPos.y);
                float xzAtan = atan2(worldPos.x, worldPos.z);
                xzAtan/=TAU;
                float2 boxUV = float2(xzAtan, yAsin);
                return boxUV;
            }

            float Layer(float2 boxUV)
            {
                float2 gridUV = frac(boxUV)-0.5; //subdivide space
                float2 gridID = floor(boxUV); //get id of each subdivided cell

                float2 p[9];
                int index = 0;
                for(float y = -1.0; y<=1.0; y++)
                {
                    for(float x = -1; x<=1.0; x++)
                    {
                        float2 current = float2(x,y);
                        float2 vectorOffset = gridID + current; 
                        p[index++] = current + GetRandomPointInGrid(vectorOffset);
                    }
                }

                float lineVal =0.;

                float2 starVec = float2(gridUV.x-p[4].x, gridUV.y-p[4].y);
                starVec = RotateVec2D(starVec, _Time.y*(GetRandomFloat(gridID)*4.0-2.0));
                float starShape = saturate(_starBrightness*(GetRandomFloat(gridID)*0.5+0.7)-(abs(starVec.x*_starSharpness)*abs(starVec.y*_starSharpness)));
                starShape = pow(starShape, 3.75);


                for(int id = 0;id<9;id++)
                {
                    lineVal += Line(gridUV, p[4], p[id]);
                    float2 j = (p[id] - gridUV);

                    float lengthOfPointFromUV = length(j); 
                    float sparkle = starShape*_sparkleStrength*smoothstep(_starSize-(sin(_Time.w+GetRandomFloat(gridID+3141.59)*20)*0.05+0.02), 0.0, length(starVec));
                    lineVal+= sparkle; 
                }

                //return float4(gridUV,0,0);

                lineVal += Line(gridUV, p[1], p[3]);
                lineVal += Line(gridUV, p[1], p[5]);
                lineVal += Line(gridUV, p[7], p[3]);
                lineVal += Line(gridUV, p[7], p[5]);

                return lineVal;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fix UV according to screen params
                float2 uv = (i.uv-0.5)*2.; //also make it span (-1,-1) to (1,1)
                float aspect = _ScreenParams.x/_ScreenParams.y; //aspect fix
                uv.x*=aspect; 
                uv*=_uvSize;
                //uv.x+=_Time.x;
                float2 boxUV = GetCorrectedUV(i.worldPos);
                boxUV.x*=_aspect;
                boxUV*=_uvSize;
                boxUV.x+=_Time.x*5.;
               
                float lineVal = Layer(boxUV);
                lineVal+= Layer(boxUV*_secondaryUVSize)*_secondaryUVBrightness;

                //float grid = step(0.48, gridUV.x) + step(0.48,gridUV.y);
                float4 col = lineVal*float4(_baseColor, 0);
                col+= float4(_backFill, 0)*_fillMultiplier;
                col*= smoothstep(_yCutoff*_uvSize, _uvSize,boxUV.y)-smoothstep(0, _uvSize*0.85, uv.y);
                return col;

            }
            ENDCG
        }
    }
}
