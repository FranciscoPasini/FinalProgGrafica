using UnityEngine;

namespace Portals
{
    // Cuentas de los portales. El frente visible de un portal es su -forward.
    public static class PortalMath
    {
        static readonly Matrix4x4 HalfTurn = Matrix4x4.Rotate(Quaternion.Euler(0f, 180f, 0f));

        // Pose de la cámara virtual: relativa al portal de origen, girada 180° (modo clásico) y llevada al destino.
        public static Matrix4x4 VirtualCameraMatrix(Matrix4x4 viewerLocalToWorld, Matrix4x4 fromPortal, Matrix4x4 toPortal, bool halfTurn = true)
        {
            Matrix4x4 relative = fromPortal.inverse * viewerLocalToWorld;
            return halfTurn ? toPortal * HalfTurn * relative : toPortal * relative;
        }

        // Plano (normal, distancia) en espacio de cámara, para el recorte oblicuo.
        public static Vector4 CameraSpacePlane(Matrix4x4 worldToCamera, Vector3 planePos, Vector3 planeNormal, float offset)
        {
            Vector3 p = worldToCamera.MultiplyPoint(planePos + planeNormal * offset);
            Vector3 n = worldToCamera.MultiplyVector(planeNormal).normalized;
            return new Vector4(n.x, n.y, n.z, -Vector3.Dot(p, n));
        }

        public static bool IsViewerInFront(Vector3 viewerPos, Vector3 portalPos, Vector3 portalForward)
        {
            return Vector3.Dot(viewerPos - portalPos, -portalForward) > 0f;
        }
    }
}
