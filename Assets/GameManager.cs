using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private static GameManager _instance;
    public static GameManager Instance
    {
        get
        {
            _instance = FindObjectOfType<GameManager>();
            if (_instance == null)
            {
                _instance = GameObject.FindObjectOfType<GameManager>(true);
            }

            return _instance;
        }
    }

    [field:SerializeField] public int win_Total { get; private set; } = 0;
    public bool tutorialState = false;
}
