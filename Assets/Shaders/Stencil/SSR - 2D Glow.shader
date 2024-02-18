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
        [Space]
        [Space]
        [Space]
        _Width("Width", Range(0, 0.01)) = 0.0

        _ShineRot("Shine direction", Range(-3.141592, 3.141592)) = 0.0
        _ShineWidth("Shine Width", Range(0.02, 0.5)) = 0.05
        _ShinePeriod("Shine Repeat Time", float) = 1.0
        _ShineSpeed("Shine Speed", Range(0.0, 3.)) = 1.0
        _ShineStrength("Shine Strength", float) = 1.0
        _ShineSeparation("Shine Separation", Range(0.01, 0.5)) = 0.06
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
        ZWrite On
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

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

        float _ShineRot, _ShineWidth, _ShinePeriod,
        _ShineSpeed, _ShineStrength, _ShineSeparation;


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float2 Rotate(float2 uv, float radians)
        {
            float s = sin(radians);
            float c = cos(radians);
            float2x2 rotMat = float2x2(c,-s,s,c);
            float2 newUV = mul(uv, rotMat);
            return newUV;
        }

        float SweepingShine(float2 uv, float width, float t)
        { 
            float center = (t % _ShinePeriod)-1.0;
            float shine = smoothstep(width, 0.01, abs(uv.x - center))*_ShineStrength;
            return shine;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 PlusX = IN.uv_MainTex;
            PlusX.x += _Width;
            float2 PlusY = IN.uv_MainTex;
            PlusY.y += _Width;
            float2 MinusX = IN.uv_MainTex;
            MinusX.x -= _Width;
            float2 MinusY = IN.uv_MainTex;
            MinusY.y -= _Width;

            float offsetReads = saturate(tex2D(_MainTex, PlusX).a + tex2D(_MainTex, MinusX).a + tex2D(_MainTex, PlusY).a + tex2D(_MainTex, MinusY).a);
            float4 normalRead = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 c = normalRead + (step(0.9, offsetReads-normalRead.a)*1.5) * _Color;

            float2 shineUV = Rotate(IN.uv_MainTex, _ShineRot)*2.0 - 1.0;
            float shineTime = _Time.y * _ShineSpeed +1.5;
            float shines = SweepingShine(shineUV, _ShineWidth, shineTime);
            shines += SweepingShine(shineUV, _ShineWidth*0.4, shineTime-_ShineSeparation);
            shines += 1.0;

            c *= shines;
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
