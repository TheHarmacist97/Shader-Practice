using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class WaterCalculate : MonoBehaviour
{
    [SerializeField] Transform pointer;
    [SerializeField] private WaterHelper waterHelper;
    private Ray ray;
    private RaycastHit hit;
    private bool didHit;
    private Camera cam;
    private Waves[] _Waves;

    private void Start()
    {
        cam = Camera.main;
        _Waves = waterHelper.waves;
    }
    // Update is called once per frame
    void Update()
    {
        ray = cam.ScreenPointToRay(Input.mousePosition);
        didHit = Physics.Raycast(ray, out hit);
        float3 hitPoint = hit.point+Vector3.up*GetSurfaceHeight(hit.point);
        Vector3 rotationVector = GetSurfaceNormals(hitPoint);
        Debug.Log(rotationVector);

        pointer.SetPositionAndRotation(hitPoint, Quaternion.LookRotation(rotationVector));
    }

    float GetWaveBinormal(Waves wave, float2 xz)
    {
        float mult = wave.waveLength * wave.direction.x * wave.amplitude;
        float zComp = mult * math.sin(math.dot(wave.direction, xz) * wave.waveLength + Time.time * wave.speed);
        return zComp;
    }

    float GetWaveTangent(Waves wave, float2 xz)
    {
        float mult = wave.waveLength * wave.direction.y * wave.amplitude;
        float zComp = mult * math.sin(math.dot(wave.direction, xz) * wave.waveLength + Time.time * wave.speed);
        
        return zComp;
    }

    float3 GetSurfaceNormals(float3 worldPos)
    {
        float x = 0, y = 0;
        for (int iter = 0; iter < _Waves.Length; iter++)
        {
            x += GetWaveBinormal(_Waves[iter], worldPos.xz);
            y += GetWaveTangent(_Waves[iter], worldPos.xz);
        }
        float3 finalNormal = new(-x, 1f, -y);
        return finalNormal;
    }

    float GetHeight(Waves wave, float2 xz)
    {
        //float sinOut = sin(dot(wave.direction,xz)*wave.wLength+_Time.y+wave.phi)
        //float height = 2*wave.amplitude * pow()
        float height = wave.amplitude * math.sin(math.dot(wave.direction, xz) * wave.waveLength + Time.time * wave.speed);
        return height;
    }

    float GetSurfaceHeight(float3 worldPos)
    {
        float finalHeight = 0;
        for (int iter = 0; iter < _Waves.Length; iter++)
        {
            finalHeight += GetHeight(_Waves[iter], worldPos.xz);
        }
        return finalHeight;
    }
}
