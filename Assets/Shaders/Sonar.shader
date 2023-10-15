Shader "Custom/Sonar"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Origin("Orgin", Vector) = (0,0,0,0)
        _Frequency("Frequency", Float) = 1.
        [HDR]_WaveColor("Wave Color", Color) = (0,0,0,0)
        _Width("Thickness", Float) = 0.2
        _Speed("Speed", Float) = 1.

        [Space]
        [Space]

        _FresnelPower("Fresnel Power", Float) = 1
        [HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        [Toggle(ENABLE_FRESNEL)] _Enable_Fresnel ("Enable Fresnel", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float3 _Origin;
        float _Frequency;
        float _Speed;
        float _Width;
        float3 _WaveColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float invLerp(float from, float to, float value)
        {
            return clamp((value - from) / (to - from),0,1);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 pos = IN.worldPos;
            float sinValue = sin(length(_Origin - IN.worldPos) * _Frequency - _Time.z * _Speed);
            float smoothWave = lerp(0,1,smoothstep(1-(_Width*_Frequency), 1.0, sinValue));
            //Add noise to smoothWave value here

            float4 col = float4(smoothWave*_WaveColor, 1)+_Color;
            //fixed4 c = float4(col,1);
            o.Emission = col.rgb;
            o.Albedo = col.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
        }
        ENDCG
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZTest Greater
            CGPROGRAM
            #pragma multi_compile __ ENABLE_FRESNEL
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct fragmentInput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 normal : TEXCOORD3;
            };

            float _FresnelPower;
            float4 _FresnelColor;

            float3 _Origin;
            float _Frequency;
            float _Speed;
            float _Width;
            
            fragmentInput vert(appdata data)
            {
                fragmentInput fragIn;
                fragIn.vertex = UnityObjectToClipPos(data.vertex);
            #ifdef ENABLE_FRESNEL
                fragIn.uv =  data.uv;
                fragIn.worldPos = mul(unity_ObjectToWorld, data.vertex);
                fragIn.viewDir = normalize(UnityWorldSpaceViewDir(fragIn.worldPos));
                fragIn.normal = UnityObjectToWorldNormal(data.normal);
                return fragIn;
            #else
                return fragIn;
            #endif
            }

            fixed4 frag (fragmentInput i) : SV_TARGET
            {
            #ifdef ENABLE_FRESNEL
                float3 pos = i.worldPos;
                float sinValue = sin(length(_Origin - i.worldPos) * _Frequency - _Time.z * _Speed);
                float smoothWave = lerp(0,1,smoothstep(1-(_Width*_Frequency), 1.0, sinValue));
                float fresnelVal = pow(1 - saturate(dot(i.normal, i.viewDir)), _FresnelPower);
                float4 col = fresnelVal*_FresnelColor*smoothWave;
                return col;
            #else
                return 1;
            #endif
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
