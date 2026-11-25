using UnityEngine;

namespace Portals
{
    // Cámara de presentación: va al foco elegido y se balancea para que se note la profundidad.
    public class ShowcaseCamera : MonoBehaviour
    {
        [Tooltip("Puntos de vista. 0 = vista general, luego uno por portal.")]
        [SerializeField] Transform[] focusPoints = new Transform[0];

        [Tooltip("Cuánto se balancea la cámara de lado a lado (metros).")]
        [SerializeField] float swayAmplitude = 0.6f;

        [Tooltip("Segundos que dura un balanceo completo.")]
        [SerializeField, Min(0.1f)] float swayPeriod = 8f;

        [Tooltip("Segundos aproximados para llegar a un foco nuevo.")]
        [SerializeField, Min(0.05f)] float transitionTime = 1.5f;

        int m_currentFocus;
        float m_swayTime;

        public void Focus(int index)
        {
            if (index < 0 || index >= focusPoints.Length || focusPoints[index] == null) return;
            m_currentFocus = index;
        }

        void Start()
        {
            if (focusPoints.Length == 0 || focusPoints[0] == null) return;
            transform.SetPositionAndRotation(focusPoints[0].position, focusPoints[0].rotation);
        }

        void Update()
        {
            if (focusPoints.Length == 0) return;
            Transform target = focusPoints[m_currentFocus];
            if (target == null) return;

            m_swayTime += Time.deltaTime;
            float sway = Mathf.Sin(m_swayTime * 2f * Mathf.PI / swayPeriod) * swayAmplitude;
            Vector3 goal = target.position + target.right * sway;

            // Suavizado exponencial: el movimiento no depende de los FPS.
            float k = 1f - Mathf.Exp(-Time.deltaTime * 4f / transitionTime);
            transform.position = Vector3.Lerp(transform.position, goal, k);
            transform.rotation = Quaternion.Slerp(transform.rotation, target.rotation, k);
        }
    }
}
