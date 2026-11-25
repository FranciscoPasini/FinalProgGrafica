using System.Collections.Generic;
using UnityEngine;

namespace Portals
{
    /// <summary>
    /// Portal enlazado (efecto "Umbral"). Cada cámara que mira este portal (la del juego, la vista Scene, etc.)
    /// recibe su propia imagen: una cámara virtual se ubica del otro lado, con la misma posición relativa que
    /// esa cámara tiene respecto de este portal, y renderiza lo que se vería al salir por el otro portal.
    /// El shader muestra esa imagen en coordenadas de pantalla (_PortalView), así la perspectiva cambia al moverse.
    /// El frente visible del portal es su -forward (como el Quad de Unity).
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public class LinkedPortal : MonoBehaviour
    {
        public enum ViewMode
        {
            [Tooltip("Como en el juego Portal: se sale por el frente del otro portal, girado media vuelta.")]
            PortalClasico,
            [Tooltip("Se ve lo que hay detrás del otro portal, como una ventana.")]
            Ventana
        }

        public const string PortalLayerName = "Portal";
        static readonly int PortalViewId = Shader.PropertyToID("_PortalView");

        /// <summary>Cámaras virtuales de todos los portales: nunca renderizan portales (sin recursión).</summary>
        static readonly HashSet<Camera> s_virtualCameras = new HashSet<Camera>();
        static bool s_rendering;

        [Tooltip("Portal del otro lado. Lo que se ve a través de este portal es lo que se vería al salir por ese.")]
        [SerializeField] LinkedPortal linkedPortal;

        [Tooltip("Superficie que muestra la vista (si se deja vacío, usa el Renderer de este objeto).")]
        [SerializeField] Renderer surface;

        [Tooltip("Portal clásico: se sale por el frente del otro portal. Ventana: se ve lo que hay detrás de él.")]
        [SerializeField] ViewMode viewMode = ViewMode.PortalClasico;

        [Tooltip("Corre el plano de recorte unos centímetros hacia la cámara para evitar cortes en el borde del portal de destino.")]
        [SerializeField] float clipPlaneOffset = 0.05f;

        readonly Dictionary<Camera, RenderTexture> m_textures = new Dictionary<Camera, RenderTexture>();
        Camera m_virtualCamera;
        MaterialPropertyBlock m_block;

        public LinkedPortal LinkedTo => linkedPortal;
        public ViewMode Mode { get => viewMode; set => viewMode = value; }
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

        /// <summary>True para cámaras reales (juego, vista Scene); false para las cámaras virtuales de los portales.</summary>
        public bool ShouldRenderFor(Camera viewer)
        {
            if (viewer == null || s_rendering || s_virtualCameras.Contains(viewer)) return false;
            return viewer.cameraType == CameraType.Game || viewer.cameraType == CameraType.SceneView;
        }

        /// <summary>Textura de la vista para una cámara; se recrea si esa cámara cambió de tamaño.</summary>
        public RenderTexture GetViewTexture(Camera viewer, int width, int height)
        {
            width = Mathf.Max(1, width);
            height = Mathf.Max(1, height);
            if (m_textures.TryGetValue(viewer, out var texture) && texture != null &&
                texture.width == width && texture.height == height)
                return texture;

            if (texture != null) Release(texture);
            texture = new RenderTexture(width, height, 24, RenderTextureFormat.DefaultHDR)
            {
                name = name + " (vista para " + viewer.name + ")"
            };
            texture.Create();
            m_textures[viewer] = texture;
            return texture;
        }

        /// <summary>Pasa la textura al shader sin tocar el material compartido.</summary>
        public void ApplyToSurface(RenderTexture texture)
        {
            if (m_block == null) m_block = new MaterialPropertyBlock();
            var target = Surface;
            target.GetPropertyBlock(m_block);
            if (texture != null) m_block.SetTexture(PortalViewId, texture);
            target.SetPropertyBlock(m_block);
        }

        /// <summary>Unity lo llama por cada cámara que va a dibujar este portal, justo antes de dibujarlo.</summary>
        void OnWillRenderObject()
        {
            var viewer = Camera.current;
            if (ShouldRenderFor(viewer)) RenderView(viewer);
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
            cam.cullingMask = viewer.cullingMask & ~(1 << Mathf.Max(0, PortalLayer));
        }

        /// <summary>Renderiza lo que esta cámara vería a través del portal y se lo pasa al shader.</summary>
        public void RenderView(Camera viewer)
        {
            if (linkedPortal == null) return;
            if (!PortalMath.IsViewerInFront(viewer.transform.position, transform.position, transform.forward)) return;

            var texture = GetViewTexture(viewer, viewer.pixelWidth, viewer.pixelHeight);
            var cam = VirtualCamera;
            SyncCameraSettings(viewer);
            cam.targetTexture = texture;

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

            s_rendering = true;
            try { cam.Render(); }
            finally { s_rendering = false; }
            ApplyToSurface(texture);
        }

        void CreateVirtualCamera()
        {
            var go = new GameObject(name + " - Cámara virtual") { hideFlags = HideFlags.HideAndDontSave };
            m_virtualCamera = go.AddComponent<Camera>();
            m_virtualCamera.enabled = false;
            m_virtualCamera.cullingMask = ~0 & ~(1 << Mathf.Max(0, PortalLayer));
            s_virtualCameras.Add(m_virtualCamera);
        }

        void OnDisable()
        {
            foreach (var texture in m_textures.Values) Release(texture);
            m_textures.Clear();
            if (m_virtualCamera != null)
            {
                s_virtualCameras.Remove(m_virtualCamera);
                SafeDestroy(m_virtualCamera.gameObject);
                m_virtualCamera = null;
            }
        }

        void Release(RenderTexture texture)
        {
            if (texture == null) return;
            if (m_virtualCamera != null && m_virtualCamera.targetTexture == texture) m_virtualCamera.targetTexture = null;
            texture.Release();
            SafeDestroy(texture);
        }

        static void SafeDestroy(Object obj)
        {
            if (Application.isPlaying) Destroy(obj);
            else DestroyImmediate(obj);
        }
    }
}
