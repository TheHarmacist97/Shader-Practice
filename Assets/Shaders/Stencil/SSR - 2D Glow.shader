Shader "Custom/SSR-2D Glow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [IntRange] _StencilRef("Read Value", Range(0,255)) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _CompareFunction("_CompareFunction", int) = 1
        _Width("Width", float) = 0.0
        
    }
    SubShader
    {
        Stencil
        {
            Ref [_StencilRef]
            Comp [_CompareFunction]
        }

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
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Width;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 scaledUV = (IN.uv_MainTex+_Width*0.5)/((1+_Width));
            float4 scaledRead = tex2D(_MainTex, scaledUV);
            float4 normalRead = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 c = normalRead + (step(0.01, scaledRead.a-normalRead.a)*2.5) * _Color;
            clip(c.a - 0.01);
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
