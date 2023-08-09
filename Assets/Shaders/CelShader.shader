Shader "Custom/CelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientLight("Ambient Light", color) = (0,0,0,0)
        [Range(0, 10)]_Gloss("Glossiness", float) = 1
        _Color("Albedo", Color) = (1,1,1,1)
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
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


            float3 _AmbientLight;
            float4 _Color;
            float _Gloss;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                //diffuse lighting 
                float lightFalloff = max(0, dot(normal, _WorldSpaceLightPos0.xyz));
                lightFalloff = step(0.5, lightFalloff);
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
                specularFallOff = step(0.92, specularFallOff);
                specularFallOff  = pow(specularFallOff, _Gloss);
                
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
