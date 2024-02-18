Shader "Custom/SR-CardBG1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [IntRange] _Ref("Ref", Range(1,255)) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_Comp("Comparion Function", int) = 1

        _Rate("Rate", Float) = 0.01
        _Fill("Fill", Range(0.01, 1)) = 0.01
        _Scale("Scale", Float) = 10
        _RotSpeed("RotSpeed", Float) = 20
        _Color1("Color1", Color) = (1, 0.5377357, 0.5377357, 0)
        _Color2("Color2", Color) = (0.5861127, 1, 0.562893, 0)
        _Color3("Color3", Color) = (0.4056603, 0.6155475, 1, 0)
        _Scanlines("Scanlines", Float) = 5
        _ScanlineIntensity("ScanlineIntensity", Range(0.1, 10)) = 1
        _Boost("Boost", Float) = 3.51
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Front
        Stencil
        {
            Ref [_Ref]
            Comp [_Comp]
        }
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

        float _Rate, _Fill, _Scale, _RotSpeed;
        float4 _Color1, _Color2, _Color3;
        float _Scanlines, _ScanlineIntensity, _Boost;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        inline float unity_noise_randomValue (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float unity_noise_interpolate (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }

        inline float unity_valueNoise (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = unity_noise_randomValue(c0);
            float r1 = unity_noise_randomValue(c1);
            float r2 = unity_noise_randomValue(c2);
            float r3 = unity_noise_randomValue(c3);

            float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
            float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
            float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        float SimpleNoise(float2 UV, float Scale)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            return t;
        }

        float2 Rotate(float2 UV, float Rotation)
        {
            Rotation = Rotation * (3.1415926f/180.0f);
            float s = sin(Rotation);
            float c = cos(Rotation);
            float2x2 rMatrix = float2x2(c, -s, s, c);
            UV.xy = mul(UV.xy, rMatrix);
            return UV;
        }

        float Pulse(float raw)
        {
            float value = abs(raw - 0.45);
            value = smoothstep(0.25, 0.05, value)*1.45;
            value += .90;
            return value;
        }

        void Layer(float2 uv, out float4 outColor, out float scanlines)
        {
            float2 gridRotUV = Rotate(uv*_Scale, _Time.y*_RotSpeed);
            float2 gridID = floor(gridRotUV);

            float gridNoise = SimpleNoise(gridID, 500);

            float mult1 = frac(gridNoise*_Time.y*_Rate);
            float mult2 = frac(gridNoise*_Time.y*_Rate*1.2);
            float mult3 = frac(gridNoise*_Time.y*_Rate*0.8);

            mult1 = smoothstep(_Fill, 0, mult1);
            mult2 = smoothstep(_Fill, 0, mult2);
            mult3 = smoothstep(_Fill, 0, mult3);

            float4 gridCol1 = mult1*_Color1;
            float4 gridCol2 = mult2*_Color2;
            float4 gridCol3 = mult3*_Color3;

            float4 finalCol = gridCol1 + gridCol2 + gridCol3;
            float pulseRaw = mult1 + mult2 + mult3;
            float pulseValue = Pulse(pulseRaw);
            finalCol = saturate(finalCol*pulseValue);
          
            float2 gridUV = frac(gridRotUV)-0.5;
            gridUV = abs(gridUV);
            float gridX = pow(gridUV.x, 5);
            float gridY = pow(gridUV.y, 5);
            float squircleMask = 1.0-((gridX + gridY)*30);

            finalCol *= squircleMask;
            finalCol = saturate(finalCol);

            outColor = finalCol;

            float n = (uv.x) - 0.5;
            n *= _Scanlines*_Scale;
            n = abs(frac(n)-0.5)*_ScanlineIntensity;

            scanlines = n;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex.xy;
            float4 fc = .2;
            float scanlines = 0;
            Layer(IN.uv_MainTex, fc, scanlines);
            // Albedo comes from a texture tinted by color
            fixed4 c = fc*scanlines*_Boost;

            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Emission = pow(fc, 3);
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
