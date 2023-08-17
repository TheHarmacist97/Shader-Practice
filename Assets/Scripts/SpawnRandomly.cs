using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class SpawnRandomly : MonoBehaviour
{
    [SerializeField] private float maxRadius;
    [SerializeField] private int count;
    void Start()
    {
        Transform t;
        for (int i = 0; i < count; i++)
        {
            Vector3 pos = Random.insideUnitSphere*maxRadius;
            pos.y = Mathf.Abs(pos.y);
            t = GameObject.CreatePrimitive(PrimitiveType.Cube).transform;
            t.SetPositionAndRotation(Random.insideUnitSphere*maxRadius, Random.rotation);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
