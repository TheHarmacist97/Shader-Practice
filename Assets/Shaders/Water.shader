Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseWaterColor("Color of the water", color) = (1,1,1)
        _Ambient("Ambient Lighting", color) = (1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _BaseWaterColor;
            float3 _Ambient; 

            struct waveData
            {
                float wLength;
                float amplitude;
                float phi;
                //float sharpness;
                float2 direction;
            };
            uniform StructuredBuffer<waveData> _Waves;
            int _NumberOfWaves;

            float GetHeight(waveData wave, float2 xz)
            {
                //float sinOut = sin(dot(wave.direction,xz)*wave.wLength+_Time.y+wave.phi)
                //float height = 2*wave.amplitude * pow()
                float height = wave.amplitude * sin(dot(wave.direction,xz)*wave.wLength + _Time.y*wave.phi);
                return height;
            }

            float GetSurfaceHeight(float3 worldPos)
            {
                float finalHeight = 0;
                for(int iter = 0; iter<_NumberOfWaves; iter++)
                {
                    finalHeight += GetHeight(_Waves[iter], worldPos.xz);
                }
                return finalHeight;
            }

            float GetWaveBinormal(waveData wave, float2 xz)
            {
                float mult = wave.wLength*wave.direction.y*wave.amplitude;
                float zComp = mult*cos(dot(wave.direction, xz)*wave.wLength +_Time.y*wave.phi);
                return zComp;
            }

            float GetWaveTangent(waveData wave, float2 xz)
            {
                float mult = wave.wLength * wave.direction.y * wave.amplitude;
                float zComp = mult * cos(dot(wave.direction, xz)*wave.wLength +_Time.y*wave.phi);
                return zComp;
            }

            float3 GetSurfaceNormals(float3 worldPos)
            {
                float x = 0, y = 0;
                for(int iter = 0; iter<_NumberOfWaves; iter++)
                {
                    x += GetWaveBinormal(_Waves[iter],worldPos);
                    y += GetWaveTangent(_Waves[iter],worldPos);
                }
                float3 finalNormal = normalize(float3(-x , 1.0, -y));
                return finalNormal;
            }


            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul( unity_ObjectToWorld,v.vertex);
                float finalHeight = GetSurfaceHeight(worldPos);
                v.vertex.y += finalHeight;
                o.worldPos = worldPos;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 normals = GetSurfaceNormals(i.worldPos); 
                float NdotL = dot(_WorldSpaceLightPos0.xyz, normals);
                float3 directLight = _LightColor0.rgb*NdotL;
                fixed4 col = NdotL;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
