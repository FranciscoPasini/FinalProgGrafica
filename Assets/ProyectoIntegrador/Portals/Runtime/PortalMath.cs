using UnityEngine;

namespace Portals
{
    /// <summary>
    /// Matemática de portales enlazados, sin estado (testeable sin escena).
    /// Convención: el frente visible de un portal es su -forward (el quad mira hacia -Z).
    /// </summary>
    public static class PortalMath
    {
        static readonly Matrix4x4 HalfTurn = Matrix4x4.Rotate(Quaternion.Euler(0f, 180f, 0f));

        /// <summary>
        /// Dónde ubicar la cámara virtual: la pose del observador relativa al portal de origen,
        /// re-expresada desde el portal de destino.
        /// halfTurn = true: portal clásico (se sale por el frente del destino, girado media vuelta).
        /// halfTurn = false: ventana (se ve lo que hay detrás del portal de destino).
        /// </summary>
        public static Matrix4x4 VirtualCameraMatrix(Matrix4x4 viewerLocalToWorld, Matrix4x4 fromPortal, Matrix4x4 toPortal, bool halfTurn = true)
        {
            Matrix4x4 relative = fromPortal.inverse * viewerLocalToWorld;
            return halfTurn ? toPortal * HalfTurn * relative : toPortal * relative;
        }

        /// <summary>Plano (normal, distancia) en espacio de cámara, para CalculateObliqueMatrix.</summary>
        public static Vector4 CameraSpacePlane(Matrix4x4 worldToCamera, Vector3 planePos, Vector3 planeNormal, float offset)
        {
            Vector3 p = worldToCamera.MultiplyPoint(planePos + planeNormal * offset);
            Vector3 n = worldToCamera.MultiplyVector(planeNormal).normalized;
            return new Vector4(n.x, n.y, n.z, -Vector3.Dot(p, n));
        }

        /// <summary>True si el observador está del lado visible del portal.</summary>
        public static bool IsViewerInFront(Vector3 viewerPos, Vector3 portalPos, Vector3 portalForward)
        {
            return Vector3.Dot(viewerPos - portalPos, -portalForward) > 0f;
        }
    }
}
