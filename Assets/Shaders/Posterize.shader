// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Posterize"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientLight("Ambient Light", color) = (0,0,0,0)
        _Gloss("Glossiness", Range(0,45)) = 1
        _Color("Albedo", Color) = (1,1,1,1)
        _SpecSteps("Specular Posterize Steps", Int) = 3
        _DiffSteps("Diffuse Posterize Steps", Int) = 8
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex);
                return o;
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

            float Posterize(int steps, float value)
            {
                return floor(value*steps)/steps;
            }

            float3 _AmbientLight;
            float4 _Color;
            float _Gloss;
            int _DiffSteps;
            int _SpecSteps;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0.xyz;

                //diffuse lighting
                float lightFalloff = max(0, dot(normal, _WorldSpaceLightPos0.xyz));
                lightFalloff = Posterize(_DiffSteps, lightFalloff);
                float3 directDiffuseLight = _LightColor0.rgb*lightFalloff;
                
                //ambient lighting
                float3 totalLight = _AmbientLight + directDiffuseLight;

                //specular Lighting
                float3 camPos  = _WorldSpaceCameraPos;
                float3 fragPos = i.worldPos;
                float3 fragToCamDir = camPos - fragPos;
                float3 viewDir = normalize(fragToCamDir); 
                float3 viewReflect = reflect(-viewDir, normal);

                float specularFallOff = max(0, dot(viewReflect, lightDir));
                specularFallOff  = pow(specularFallOff, _Gloss);
                specularFallOff = Posterize(_SpecSteps, specularFallOff);
  
                float3 directSpecular = specularFallOff*_LightColor0.rgb;

                //surface interaction 
                float3 albedoInteraction = totalLight*_Color.rgb;

                float3 finalSurfaceColor = albedoInteraction + directSpecular; 
                return float4(finalSurfaceColor ,0);            
            }
            ENDCG
        }
    }
}
