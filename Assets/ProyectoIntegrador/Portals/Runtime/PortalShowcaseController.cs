using UnityEngine;

namespace Portals
{
    // Teclas de la escena: 1, 2, 3 cambian de foco · Espacio abre/cierra los portales · H muestra la ayuda.
    public class PortalShowcaseController : MonoBehaviour
    {
        public const string HelpText = "1 Vista general · 2 Umbral · 3 Abismo · Espacio abrir/cerrar portales · H ayuda · ←/→ escena";

        [SerializeField] ShowcaseCamera showcaseCamera;
        [SerializeField] PortalOpening[] portals = new PortalOpening[0];
        [Tooltip("Objeto con el texto de ayuda en pantalla.")]
        [SerializeField] GameObject help;

        bool m_portalsOpen = true;

        public void Configure(ShowcaseCamera camera, PortalOpening[] portalOpenings, GameObject helpObject)
        {
            showcaseCamera = camera;
            portals = portalOpenings;
            help = helpObject;
        }

        void Update()
        {
            if (Input.GetKeyDown(KeyCode.Alpha1)) HandleKey(KeyCode.Alpha1);
            if (Input.GetKeyDown(KeyCode.Alpha2)) HandleKey(KeyCode.Alpha2);
            if (Input.GetKeyDown(KeyCode.Alpha3)) HandleKey(KeyCode.Alpha3);
            if (Input.GetKeyDown(KeyCode.Space)) HandleKey(KeyCode.Space);
            if (Input.GetKeyDown(KeyCode.H)) HandleKey(KeyCode.H);
        }

        public void HandleKey(KeyCode key)
        {
            switch (key)
            {
                case KeyCode.Alpha1: showcaseCamera?.Focus(0); break;
                case KeyCode.Alpha2: showcaseCamera?.Focus(1); break;
                case KeyCode.Alpha3: showcaseCamera?.Focus(2); break;
                case KeyCode.Space:
                    m_portalsOpen = !m_portalsOpen;
                    foreach (var portal in portals)
                        if (portal != null) portal.SetOpen(m_portalsOpen);
                    break;
                case KeyCode.H:
                    if (help != null) help.SetActive(!help.activeSelf);
                    break;
            }
        }
    }
}
