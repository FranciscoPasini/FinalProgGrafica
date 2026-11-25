using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class FirstPersonMovement : MonoBehaviour
{
    [Header("Movimiento")]
    public float moveSpeed = 6f;
    public float gravity = -20f;

    [Header("Salto")]
    public float jumpHeight = 1.6f;
    public float coyoteTime = 0.15f; // Margen para saltar justo al salir de un borde

    [Header("Cámara en Primera Persona")]
    public Vector3 eyeLocalPosition = new Vector3(0f, 0.75f, 0f);
    public float nearClipPlane = 0.1f;
    public float mouseSensitivity = 2f;
    public float maxLookAngle = 85f;
    public bool lockCursor = true;

    private CharacterController controller;
    private Transform cameraTransform;
    private Vector3 velocity;
    private float xRotation = 0f;
    private float coyoteTimeCounter = 0f;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        AttachCameraToPlayer();

        if (lockCursor)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    private void AttachCameraToPlayer()
    {
        Camera targetCamera = Camera.main;

        if (targetCamera == null)
        {
            targetCamera = FindFirstObjectByType<Camera>();
        }

        if (targetCamera == null)
        {
            GameObject camObj = new GameObject("Main Camera");
            camObj.tag = "MainCamera";
            targetCamera = camObj.AddComponent<Camera>();
            camObj.AddComponent<AudioListener>();
        }

        cameraTransform = targetCamera.transform;
        cameraTransform.SetParent(transform);
        cameraTransform.localPosition = eyeLocalPosition;
        cameraTransform.localRotation = Quaternion.identity;

        targetCamera.nearClipPlane = nearClipPlane;
    }

    private void Update()
    {
        HandleMouseLook();
        HandleMovement();
        HandleGravityAndJump();
    }

    private void HandleMouseLook()
    {
        if (cameraTransform == null) return;

        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -maxLookAngle, maxLookAngle);
        cameraTransform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);

        transform.Rotate(Vector3.up * mouseX);
    }

    private void HandleMovement()
    {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");

        Vector3 moveDir = (transform.right * horizontal + transform.forward * vertical).normalized;
        controller.Move(moveDir * moveSpeed * Time.deltaTime);
    }

    private void HandleGravityAndJump()
    {
        // Actualiza el temporizador de suelo (coyote time)
        if (controller.isGrounded)
        {
            coyoteTimeCounter = coyoteTime;

            if (velocity.y < 0f)
            {
                velocity.y = -2f;
            }
        }
        else
        {
            coyoteTimeCounter -= Time.deltaTime;
        }

        // Salto con Espacio ("Jump")
        if (Input.GetButtonDown("Jump") && coyoteTimeCounter > 0f)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
            coyoteTimeCounter = 0f; // Evita doble salto accidental en el mismo margen
        }

        // Aplica gravedad y desplaza verticalmente
        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }
}