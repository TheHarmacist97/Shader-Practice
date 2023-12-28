using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Oscillate : MonoBehaviour
{
    [SerializeField] private Vector3 offset;
    [SerializeField] private float rate;
    private Vector3 initPos;
    private float tVal, sinVal;
    // Update is called once per frame
    void Update()
    {
        sinVal = Time.time * rate;
        tVal = Mathf.Pow(Mathf.Sin(sinVal), 11);
        transform.position = initPos + offset*tVal;
    }
}
