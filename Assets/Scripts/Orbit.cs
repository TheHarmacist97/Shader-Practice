using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Orbit : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private Transform target;
    private float distance;

    void Start()
    {
        distance = Vector3.Distance(transform.position, target.position);
        distance /= 2f;
    }
    private void Update()
    {
        transform.LookAt(target.position);
    }
    // Update is called once per frame
    void LateUpdate()
    {
        transform.RotateAround(target.position, Vector3.up, speed);
    }
}
