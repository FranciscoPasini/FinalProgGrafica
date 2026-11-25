using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneNavigator : MonoBehaviour
{
    [SerializeField] private string previousScene;
    [SerializeField] private string nextScene;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            LoadSceneIfValid(previousScene);
        }
        else if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            LoadSceneIfValid(nextScene);
        }
    }

    private void LoadSceneIfValid(string sceneName)
    {
        if (string.IsNullOrWhiteSpace(sceneName))
        {
            return;
        }

        if (Application.CanStreamedLevelBeLoaded(sceneName))
        {
            SceneManager.LoadScene(sceneName);
        }
        else
        {
            Debug.LogWarning($"Scene '{sceneName}' is not in Build Settings or cannot be loaded.");
        }
    }
}
