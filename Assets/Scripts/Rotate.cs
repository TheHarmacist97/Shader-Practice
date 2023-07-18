using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    // Update is called once per frame

    private void Awake()
    {
        Application.targetFrameRate = 60;
    }
    void Update()
    {
        float time = Time.time;
        transform.Rotate(new Vector3(Mathf.Sin(time * 0.5f) * 0.5f + 0.5f, Mathf.Sin(time * 0.3f) * 0.5f + 0.5f, (Mathf.Sin(time * 0.2f) * 0.5f) + 0.5f) * 0.5f);
    }
}
