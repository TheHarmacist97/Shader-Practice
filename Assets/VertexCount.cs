using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VertexCount : MonoBehaviour
{
    Material objectMat;
    void Start()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        objectMat = GetComponent<Renderer>().material;
        objectMat.SetFloat("_VertexCount", mesh.vertexCount);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
