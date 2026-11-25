using UnityEngine;

namespace Portals
{
    // Teclas de la escena: 1, 2, 3 cambian de foco · Espacio abre/cierra los portales · H muestra la ayuda.
    public class PortalShowcaseController : MonoBehaviour
    {
        [SerializeField] ShowcaseCamera showcaseCamera;
        [SerializeField] PortalOpening[] portals = new PortalOpening[0];
        [Tooltip("Objeto con el texto de ayuda en pantalla.")]
        [SerializeField] GameObject help;

        bool m_portalsOpen = true;

        void Update()
        {
            if (showcaseCamera != null)
            {
                if (Input.GetKeyDown(KeyCode.Alpha1)) showcaseCamera.Focus(0);
                if (Input.GetKeyDown(KeyCode.Alpha2)) showcaseCamera.Focus(1);
                if (Input.GetKeyDown(KeyCode.Alpha3)) showcaseCamera.Focus(2);
            }

            if (Input.GetKeyDown(KeyCode.Space))
            {
                m_portalsOpen = !m_portalsOpen;
                foreach (var portal in portals)
                    if (portal != null) portal.SetOpen(m_portalsOpen);
            }

            if (Input.GetKeyDown(KeyCode.H) && help != null)
                help.SetActive(!help.activeSelf);
        }
    }
}
