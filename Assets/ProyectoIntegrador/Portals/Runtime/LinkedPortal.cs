using UnityEngine;

namespace Portals
{
    /// <summary>
    /// Portal enlazado (efecto "Umbral"): una cámara virtual mira desde el portal de destino y lo que ve
    /// se dibuja en la superficie de este portal mediante la propiedad _PortalView del shader.
    /// El frente visible del portal es su -forward (como el Quad de Unity).
    /// </summary>
    [DisallowMultipleComponent]
    public class LinkedPortal : MonoBehaviour
    {
        public enum ViewMode
        {
            [Tooltip("Se ve lo que hay detrás del otro portal, como una ventana.")]
            Ventana,
            [Tooltip("Como en el juego Portal: se sale por el frente del otro portal, girado media vuelta.")]
            PortalClasico
        }

        public const string PortalLayerName = "Portal";
        static readonly int PortalViewId = Shader.PropertyToID("_PortalView");

        [Tooltip("Portal del otro lado. Lo que se ve a través de este portal es lo que hay frente a ese.")]
        [SerializeField] LinkedPortal linkedPortal;

        [Tooltip("Superficie que muestra la vista (si se deja vacío, usa el Renderer de este objeto).")]
        [SerializeField] Renderer surface;

        [Tooltip("Ventana: se ve lo que hay detrás del otro portal. Portal clásico: se sale por su frente.")]
        [SerializeField] ViewMode viewMode = ViewMode.Ventana;

        [Tooltip("Corre el plano de recorte unos centímetros hacia la cámara para evitar cortes en el borde del portal de destino.")]
        [SerializeField] float clipPlaneOffset = 0.05f;

        RenderTexture m_viewTexture;
        Camera m_virtualCamera;
        MaterialPropertyBlock m_block;

        public LinkedPortal LinkedTo => linkedPortal;
        public ViewMode Mode { get => viewMode; set => viewMode = value; }
        public RenderTexture ViewTexture => m_viewTexture;
        public int PortalLayer => LayerMask.NameToLayer(PortalLayerName);
        Renderer Surface => surface != null ? surface : (surface = GetComponent<Renderer>());

        public Camera VirtualCamera
        {
            get
            {
                if (m_virtualCamera == null) CreateVirtualCamera();
                return m_virtualCamera;
            }
        }

        /// <summary>Enlaza los dos portales entre sí.</summary>
        public void Link(LinkedPortal other)
        {
            linkedPortal = other;
            if (other != null) other.linkedPortal = this;
        }

        /// <summary>Crea (o recrea si cambió el tamaño de pantalla) la textura donde se renderiza la vista.</summary>
        public void EnsureTexture(int width, int height)
        {
            if (m_viewTexture != null && m_viewTexture.width == width && m_viewTexture.height == height) return;
            ReleaseTexture();
            m_viewTexture = new RenderTexture(width, height, 24, RenderTextureFormat.DefaultHDR)
            {
                name = name + " (vista del portal)"
            };
            VirtualCamera.targetTexture = m_viewTexture;
        }

        /// <summary>Pasa la textura al shader sin tocar el material compartido.</summary>
        public void ApplyToSurface()
        {
            if (m_block == null) m_block = new MaterialPropertyBlock();
            var target = Surface;
            target.GetPropertyBlock(m_block);
            if (m_viewTexture != null) m_block.SetTexture(PortalViewId, m_viewTexture);
            target.SetPropertyBlock(m_block);
        }

        void LateUpdate()
        {
            var viewer = Camera.main;
            if (viewer != null) RenderView(viewer);
        }

        /// <summary>La cámara virtual usa el mismo lente y fondo que la cámara que mira el portal.</summary>
        public void SyncCameraSettings(Camera viewer)
        {
            var cam = VirtualCamera;
            cam.fieldOfView = viewer.fieldOfView;
            cam.nearClipPlane = viewer.nearClipPlane;
            cam.farClipPlane = viewer.farClipPlane;
            cam.clearFlags = viewer.clearFlags;
            cam.backgroundColor = viewer.backgroundColor;
            cam.allowHDR = viewer.allowHDR;
            cam.cullingMask = viewer.cullingMask & ~(1 << PortalLayer);
        }

        /// <summary>Renderiza lo que se vería a través del portal desde la cámara dada.</summary>
        public void RenderView(Camera viewer)
        {
            if (linkedPortal == null) return;
            if (!PortalMath.IsViewerInFront(viewer.transform.position, transform.position, transform.forward)) return;
            if (!Surface.isVisible) return;

            EnsureTexture(Screen.width, Screen.height);
            var cam = VirtualCamera;
            SyncCameraSettings(viewer);

            // Solo posición y rotación: la escala del quad no debe deformar la cámara.
            Matrix4x4 m = PortalMath.VirtualCameraMatrix(
                viewer.transform.localToWorldMatrix,
                Matrix4x4.TRS(transform.position, transform.rotation, Vector3.one),
                Matrix4x4.TRS(linkedPortal.transform.position, linkedPortal.transform.rotation, Vector3.one),
                halfTurn: viewMode == ViewMode.PortalClasico);
            cam.transform.SetPositionAndRotation(m.GetPosition(), m.rotation);

            // Plano de recorte oblicuo en el portal de destino: lo que está detrás de él no tapa la vista.
            Transform destination = linkedPortal.transform;
            float side = Mathf.Sign(Vector3.Dot(destination.forward, destination.position - cam.transform.position));
            Vector3 normal = destination.forward * side;
            Vector4 plane = PortalMath.CameraSpacePlane(cam.worldToCameraMatrix, destination.position, normal, -clipPlaneOffset);
            cam.projectionMatrix = viewer.CalculateObliqueMatrix(plane);

            cam.Render();
            ApplyToSurface();
        }

        void CreateVirtualCamera()
        {
            var go = new GameObject(name + " - Cámara virtual") { hideFlags = HideFlags.HideAndDontSave };
            m_virtualCamera = go.AddComponent<Camera>();
            m_virtualCamera.enabled = false;
            m_virtualCamera.cullingMask = ~0 & ~(1 << Mathf.Max(0, PortalLayer));
            m_virtualCamera.targetTexture = m_viewTexture;
        }

        void ReleaseTexture()
        {
            if (m_viewTexture == null) return;
            if (m_virtualCamera != null) m_virtualCamera.targetTexture = null;
            m_viewTexture.Release();
            SafeDestroy(m_viewTexture);
            m_viewTexture = null;
        }

        void OnDestroy()
        {
            ReleaseTexture();
            if (m_virtualCamera != null) SafeDestroy(m_virtualCamera.gameObject);
        }

        static void SafeDestroy(Object obj)
        {
            if (Application.isPlaying) Destroy(obj);
            else DestroyImmediate(obj);
        }
    }
}
