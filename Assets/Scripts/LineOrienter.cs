using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class LineOrienter : MonoBehaviour
{
    private LineRenderer lineRen;
    void Start()
    {
        lineRen = GetComponent<LineRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        lineRen.SetPosition(0, transform.position);
        lineRen.SetPosition(1, transform.position + transform.forward);
    }
}
