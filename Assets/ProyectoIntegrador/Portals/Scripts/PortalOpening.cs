using UnityEngine;

namespace Portals
{
    // Abre y cierra el portal animando _Opening (y la hoja de la puerta, si tiene).
    [DisallowMultipleComponent]
    public class PortalOpening : MonoBehaviour
    {
        static readonly int OpeningId = Shader.PropertyToID("_Opening");

        [Tooltip("Superficie del portal (si se deja vacío, usa el Renderer de este objeto).")]
        [SerializeField] Renderer surface;

        [Tooltip("Segundos que tarda en abrirse o cerrarse.")]
        [SerializeField, Min(0.01f)] float duration = 0.8f;

        [Tooltip("Hoja de la puerta: se cierra junto con el portal (opcional).")]
        [SerializeField] Transform leaf;
        [SerializeField] Quaternion leafClosedRotation = Quaternion.identity;
        [SerializeField] Quaternion leafOpenRotation = Quaternion.identity;

        float m_linear = 1f;
        bool m_open = true;
        MaterialPropertyBlock m_block;

        Renderer Surface => surface != null ? surface : (surface = GetComponent<Renderer>());

        public void SetOpen(bool open) => m_open = open;

        void Update()
        {
            m_linear = Mathf.MoveTowards(m_linear, m_open ? 1f : 0f, Time.deltaTime / duration);
            float current = Mathf.SmoothStep(0f, 1f, m_linear);

            // MaterialPropertyBlock: cambia el valor solo en este objeto, sin tocar el material.
            if (m_block == null) m_block = new MaterialPropertyBlock();
            Surface.GetPropertyBlock(m_block);
            m_block.SetFloat(OpeningId, current);
            Surface.SetPropertyBlock(m_block);
            if (leaf != null) leaf.localRotation = Quaternion.Slerp(leafClosedRotation, leafOpenRotation, current);
        }
    }
}
