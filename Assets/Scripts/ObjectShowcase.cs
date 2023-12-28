using UnityEngine;

public class ObjectShowcase : MonoBehaviour
{
    [SerializeField] private float rotScale;
    [SerializeField] private float smoothingRotationDelta;

    private Vector2 initMousePos;
    private Vector2 currentMousePos;
    private Vector2 difference;
    private Quaternion targetRotation;
    private Quaternion initRotation;
    private Vector3 initVectorRotation;
    private Vector3 newRot;
    private float pitch, roll;
    
    private void Awake()
    {
        initRotation = transform.rotation;
        initVectorRotation = transform.rotation.eulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            initMousePos = Input.mousePosition;
        }
        if(Input.GetMouseButton(0))
        {
            currentMousePos = Input.mousePosition;
            difference = currentMousePos - initMousePos;
            pitch = Mathf.Clamp(difference.x * rotScale, -45, 45) + initVectorRotation.y;
            roll = Mathf.Clamp(difference.y * rotScale, -45, 45) + initVectorRotation.z;
            newRot = new Vector3(0, pitch, roll);
            targetRotation = Quaternion.Euler(newRot);
        }
        else
        {
            targetRotation = initRotation;
        }

        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, smoothingRotationDelta);
    }
}
