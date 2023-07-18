using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetAspect : MonoBehaviour
{
    public Material mat;
    float aspect;
    void Start()
    {
        aspect = (float)Screen.width / (float)Screen.height;

        mat.SetVector("_Aspect", new Vector4(1, aspect));
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
