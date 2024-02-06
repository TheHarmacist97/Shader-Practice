Shader "Unlit/StencilWrite"
{
    Properties
    {
        [IntRange]_StencilRef("Write value", Range(0,255)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend Zero One
            ZWrite Off
            Stencil
            {
                Ref [_StencilRef]
                Comp Always
                Pass Replace
            }
        }
    }
}
