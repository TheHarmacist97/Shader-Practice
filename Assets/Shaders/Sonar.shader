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
        [HDR]_WaveColor("WColor", Color) = (0,0,0,0)
        _Width("Thickness", Float) = 0.2
        _Speed("Speed", Float) = 1.
    }
    SubShader
    {
        Tags { "RenderType"="Cutout" }
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
            float4 screenPos;
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
            float smoothWave = lerp(0,1,invLerp(1-(_Width*_Frequency), 1.0, sinValue));

            // Albedo comes from a texture tinted by color

            float2 textureCoordinate = IN.screenPos.xy / IN.screenPos.w;
            float aspect = _ScreenParams.x / _ScreenParams.y;
            textureCoordinate.x = textureCoordinate.x * aspect;

            float4 col = smoothWave*textureCoordinate.xyyy;
            //fixed4 c = float4(col,1);
            o.Emission = col.rgb;
            o.Albedo = col.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
