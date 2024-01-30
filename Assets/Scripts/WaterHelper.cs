using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class WaterHelper : MonoBehaviour
{
    public Waves[] waves;
    [SerializeField] private Material mat;
    [SerializeField] private ComputeBuffer buffer;

    private int stride;
    void Start()
    {
        stride = Marshal.SizeOf(typeof(Waves));
        buffer = new ComputeBuffer(waves.Length, stride, ComputeBufferType.Default);
        buffer.SetData(waves);
        mat.SetInt("_NumberOfWaves", waves.Length);
        mat.SetBuffer("_Waves", buffer);
    }

    private void OnDestroy()
    {
        buffer.Release();
    }
    [ContextMenu("Send Values To Material")]
    private void SendValues()
    {
        //if(buffer!=null) 
        //{
        //    buffer.Release();
        //}
        stride = Marshal.SizeOf(typeof(Waves));
        buffer = new ComputeBuffer(waves.Length, stride, ComputeBufferType.Default);  
        mat.SetInt("_NumberOfWaves", waves.Length);
        mat.SetBuffer("_Waves", buffer);
    }

}
[Serializable]
public struct Waves
{ 
    [SerializeField, Range(0.01f, 2f)]public float waveLength;
    public float amplitude;
    public float speed;
    //public float sharpness;
    public Vector2 direction;
}
