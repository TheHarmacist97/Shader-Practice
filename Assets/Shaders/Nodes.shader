Shader "IMGEffect/BGMain"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Main Color", color) = (0,0.2,0.8)
        _Area("MouseInput", Vector) = (0,0,1,1)
        uvSize("UVSize", float) = 0
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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float DistLine(float2 p, float2 a, float2 b)
            {
                float2 pa = p-a;
                float2 ba = b-a;
                float t = clamp(dot(pa,ba)/dot(ba, ba),0.0, 1.0f); //projection on normalized line
                return length(pa-ba*t);
            }

            float N21(float2 p)
            {
                p = frac(p*float2(314.1, 133.7));
                p += dot(p, p+141.4);
                return frac(p.x*p.y);
            }

            float2 N22(float2 p)
            {
                float n = N21(p);
                return float2(n, N21(n));
            }

            float2 GetPos(float2 id, float2 offs)
            {
                float2 randomizer = N22(id+offs)*_Time.y;

                return  offs+sin(randomizer)*0.4f;
            }

            float Line(float2 p, float2 a, float2 b)
            {
                float d = DistLine(p,a,b);
                float m = smoothstep(0.02, 0.0001, d);
                float distance = length(a-b);
                m *= smoothstep(1.4, 0.8, distance)*0.15 + smoothstep(0.09,0.03, abs(distance-0.75))*0.5; 
                return m;
            }

            float Layer(float2 uv)
            {
                float2 gv = frac(uv)-0.5;
                float2 id = floor(uv)-0.5;


                float m = 0.0;
                float2 positions[9];
                int index = 0;
                for(int y = -1; y<=1; y++)
                {
                    for(int x = -1; x<=1; x++)
                    {
                        positions[index++] = GetPos(id,float2(x,y));
                    }
                }

                for(int i = 0; i<9; i++)
                {
                    m += Line(gv, positions[4], positions[i]);
                    float2 j = (positions[i] - gv)*35.0;
                    float sparkle = 1/length(dot(j,j));
                    m += (sin(_Time.y+frac(positions[i].x))*0.5+0.55) * sparkle;
                }
                m+= Line(gv, positions[1], positions[3]);
                m+= Line(gv, positions[1], positions[5]);
                m+= Line(gv, positions[5], positions[7]);
                m+= Line(gv, positions[7], positions[3]);


                return m;
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

            sampler2D _MainTex;
            float4 _Area;
            float2 mouseInput;
            float2 rotUV;
            float3 _Color;
            float uvSize = 5.0;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 boxUV = GetCorrectedUV(i.worldPos);
                boxUV = (boxUV-.5);
                float aspect = _Area.x/_Area.y;
                boxUV.x *= aspect;
                boxUV*=uvSize;

                float m = 0;
                fixed3 pixelColor;
                float rate = 0.15f;

                float z = 0.5;
                float size = lerp(.01,4,1-z);
                float fade = smoothstep(0, 0.4, z)*smoothstep(1.0,0.7,z);
                m += Layer(boxUV*size)*fade;
            

                //float3 base = sin(_Time.x*float3(0.415, 0.592, 0.314))*m;
                //float3 base = _MainTex ;
                //pixelColor = base;       
                m*=3;
                fixed4 col = float4(_Color, 0);
                col*=m;
                return col;
            }
            ENDCG
        }
    }
}