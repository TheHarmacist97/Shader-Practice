using UnityEngine;

public enum RollDirection
{
    X,
    Y,
    Z
}

public class ObjectShowcase : MonoBehaviour
{
    [SerializeField] private float rotScale;
    [SerializeField] private float smoothingRotationDelta;
    [SerializeField] private RollDirection mouseXRollDirection;
    [SerializeField] private bool mouseXInverted;
    [SerializeField] private RollDirection mouseYRollDirection;
    [SerializeField] private bool mouseYInverted;
    [SerializeField] private float pitchMin, pitchMax;
    [SerializeField] private float rollMin, rollMax;

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
        if (Input.GetMouseButtonDown(0))
        {
            initMousePos = Input.mousePosition;
        }
        if (Input.GetMouseButton(0))
        {
            currentMousePos = Input.mousePosition;
            difference = currentMousePos - initMousePos;
            pitch = Mathf.Clamp(difference.x * rotScale, pitchMin, pitchMax);
            roll = Mathf.Clamp(difference.y * rotScale, rollMin, rollMax);
            newRot = GetRotationDirection(mouseXRollDirection, pitch) * GetModifier(mouseXInverted) +
                     GetRotationDirection(mouseYRollDirection, roll) * GetModifier(mouseYInverted);
            newRot += initVectorRotation;
            targetRotation = Quaternion.Euler(newRot);
        }
        else
        {
            targetRotation = initRotation;
        }

        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, smoothingRotationDelta);
    }

    private Vector3 GetRotationDirection(RollDirection rDirection, float value) => rDirection switch
    {
        RollDirection.X => Vector3.right * value,
        RollDirection.Y => Vector3.up * value,
        RollDirection.Z => Vector3.forward * value,
        _ => Vector3.zero,
    };

    private float GetModifier(bool value) => value ? -1 : 1;
}
