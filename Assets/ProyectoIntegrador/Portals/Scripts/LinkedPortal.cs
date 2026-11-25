using System.Collections.Generic;
using UnityEngine;

namespace Portals
{
    // Portal enlazado (Umbral): una cámara virtual en el otro portal renderiza lo que se ve al salir por él.
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

        static readonly int PortalViewId = Shader.PropertyToID("_PortalView");
        static readonly Matrix4x4 HalfTurn = Matrix4x4.Rotate(Quaternion.Euler(0f, 180f, 0f));

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

        Renderer Surface => surface != null ? surface : (surface = GetComponent<Renderer>());
        static int PortalLayer => LayerMask.NameToLayer("Portal");

        // Se llama por cada cámara que va a dibujar el portal (juego, vista Scene, jugador).
        void OnWillRenderObject()
        {
            var viewer = Camera.current;
            if (viewer == null || s_rendering || s_virtualCameras.Contains(viewer)) return;
            if (viewer.cameraType != CameraType.Game && viewer.cameraType != CameraType.SceneView) return;
            RenderView(viewer);
        }

        void RenderView(Camera viewer)
        {
            if (linkedPortal == null) return;
            // Solo se ve desde el frente (el frente visible del quad es su -forward).
            if (Vector3.Dot(viewer.transform.position - transform.position, -transform.forward) <= 0f) return;

            var texture = GetViewTexture(viewer);
            var cam = GetVirtualCamera();
            cam.fieldOfView = viewer.fieldOfView;
            cam.nearClipPlane = viewer.nearClipPlane;
            cam.farClipPlane = viewer.farClipPlane;
            cam.clearFlags = viewer.clearFlags;
            cam.backgroundColor = viewer.backgroundColor;
            cam.allowHDR = viewer.allowHDR;
            cam.cullingMask = viewer.cullingMask & ~(1 << Mathf.Max(0, PortalLayer));
            cam.targetTexture = texture;

            // La cámara virtual queda respecto del otro portal igual que el jugador respecto de este
            // (sin la escala del quad, para no deformarla).
            Matrix4x4 from = Matrix4x4.TRS(transform.position, transform.rotation, Vector3.one);
            Matrix4x4 to = Matrix4x4.TRS(linkedPortal.transform.position, linkedPortal.transform.rotation, Vector3.one);
            Matrix4x4 relative = from.inverse * viewer.transform.localToWorldMatrix;
            Matrix4x4 m = viewMode == ViewMode.PortalClasico ? to * HalfTurn * relative : to * relative;
            cam.transform.SetPositionAndRotation(m.GetPosition(), m.rotation);

            // Recorte oblicuo: lo que está detrás del portal de destino no tapa la vista.
            Transform destination = linkedPortal.transform;
            float side = Mathf.Sign(Vector3.Dot(destination.forward, destination.position - cam.transform.position));
            Vector3 normal = destination.forward * side;
            Vector3 p = cam.worldToCameraMatrix.MultiplyPoint(destination.position - normal * clipPlaneOffset);
            Vector3 n = cam.worldToCameraMatrix.MultiplyVector(normal).normalized;
            cam.projectionMatrix = viewer.CalculateObliqueMatrix(new Vector4(n.x, n.y, n.z, -Vector3.Dot(p, n)));

            s_rendering = true;
            try { cam.Render(); }
            finally { s_rendering = false; }

            // MaterialPropertyBlock: la textura se asigna solo a este portal, sin tocar el material.
            if (m_block == null) m_block = new MaterialPropertyBlock();
            Surface.GetPropertyBlock(m_block);
            m_block.SetTexture(PortalViewId, texture);
            Surface.SetPropertyBlock(m_block);
        }

        // Una textura por cámara; se recrea si cambia de tamaño.
        RenderTexture GetViewTexture(Camera viewer)
        {
            int width = Mathf.Max(1, viewer.pixelWidth);
            int height = Mathf.Max(1, viewer.pixelHeight);
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

        Camera GetVirtualCamera()
        {
            if (m_virtualCamera != null) return m_virtualCamera;
            var go = new GameObject(name + " - Cámara virtual") { hideFlags = HideFlags.HideAndDontSave };
            m_virtualCamera = go.AddComponent<Camera>();
            m_virtualCamera.enabled = false;
            s_virtualCameras.Add(m_virtualCamera);
            return m_virtualCamera;
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
