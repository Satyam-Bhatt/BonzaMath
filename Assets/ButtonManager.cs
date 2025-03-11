using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ButtonManager : MonoBehaviour
{
    [SerializeField] private GameObject _pauseMenu;

    //-----------------MATERIALS FOR MENU-----------------
    [SerializeField] private Material[] materials;
    private int counter = 0;

    private void Start()
    {
        _pauseMenu.SetActive(false);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (!_pauseMenu.activeSelf == true)
            {
                _pauseMenu.GetComponent<Image>().material = materials[counter];
                counter++;
                if(counter == materials.Length) counter = 0;
            }
            _pauseMenu.SetActive(!_pauseMenu.activeSelf);
        }
    }

    public void ExitGame()
    {
        Application.Quit();
    }
    public void LoadScene(int num)
    {
        SceneManager.LoadScene(num);
    }
    public void NextLevel_InGame()
    {
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        currentSceneIndex++;
        SceneManager.LoadScene(currentSceneIndex);
    }

    public void RestartLevel_InGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }
}
