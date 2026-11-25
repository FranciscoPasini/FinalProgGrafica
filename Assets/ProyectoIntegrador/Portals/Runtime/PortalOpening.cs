using UnityEngine;

namespace Portals
{
    /// <summary>Abre y cierra un portal animando la propiedad _Opening del shader (sin tocar el material compartido).</summary>
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

        /// <summary>Apertura actual 0..1 (con suavizado).</summary>
        public float Current => Mathf.SmoothStep(0f, 1f, m_linear);
        public bool IsOpen => m_open;
        Renderer Surface => surface != null ? surface : (surface = GetComponent<Renderer>());

        public Transform Leaf => leaf;

        public void SetOpen(bool open) => m_open = open;

        /// <summary>Hace que la hoja de la puerta acompañe la apertura del portal.</summary>
        public void ConfigureLeaf(Transform doorLeaf, Quaternion closedRotation, Quaternion openRotation)
        {
            leaf = doorLeaf;
            leafClosedRotation = closedRotation;
            leafOpenRotation = openRotation;
        }

        public void Tick(float deltaTime)
        {
            m_linear = Mathf.MoveTowards(m_linear, m_open ? 1f : 0f, deltaTime / duration);
            Apply();
        }

        void Update() => Tick(Time.deltaTime);

        void Apply()
        {
            if (m_block == null) m_block = new MaterialPropertyBlock();
            var target = Surface;
            target.GetPropertyBlock(m_block);
            m_block.SetFloat(OpeningId, Current);
            target.SetPropertyBlock(m_block);
            if (leaf != null) leaf.localRotation = Quaternion.Slerp(leafClosedRotation, leafOpenRotation, Current);
        }
    }
}
