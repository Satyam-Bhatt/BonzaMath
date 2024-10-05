using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class AlternateCanvasScript : MonoBehaviour
{
    //-----------------TOTAL TEXT-----------------
    [SerializeField] private boxDetection[] boxDetection_Components;
    [SerializeField] private TMP_Text totalText;

    //-----------------WIN PANEL-----------------
    [SerializeField] private GameObject winPanel;

    //-----------------OBJECTIVE TEXT--------------
    [SerializeField] private TMP_Text objectiveNumber;

    private void OnEnable()
    {
        objectManager.Instance.UpdateTotalText += UpdateText;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.UpdateTotalText -= UpdateText;
    }

    private void Start()
    {
        boxDetection_Components = FindObjectsOfType<boxDetection>();
        winPanel.SetActive(false);
        UpdateText();
        objectiveNumber.text = GameManager.Instance.win_Total.ToString();
    }

    //Updates the text that shows the total value
    public void UpdateText()
    {
        Sort_Boxes();

        string allNumbers = "";

        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            if (boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text != "")
            {
                allNumbers += boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text;
            }
        }

        Debug.Log(allNumbers);
        //totalText.text = allNumbers;

        WinCheckAndTextUpdate(allNumbers);
    }

    private void WinCheckAndTextUpdate(string finalTotal)
    {
        finalTotal = finalTotal.Split("=").Last();
        if (float.Parse(finalTotal) == GameManager.Instance.win_Total)
        {
            totalText.text = "<color=orange>" + finalTotal + "</color><color=green><b>=" + GameManager.Instance.win_Total + "<b></color>";
            winPanel.SetActive(true);
        }
        else
        {
            totalText.text = "<color=#D97448>" + finalTotal + "</color><color=#7C0A02><b>≠" + GameManager.Instance.win_Total + "<b></color>";
        }
    }

    public void NextLevel()
    {
        Debug.Log("Next Level");
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        currentSceneIndex++;
        SceneManager.LoadScene(currentSceneIndex);
    }

    private void Sort_Boxes()
    {
        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            if (i + 1 >= boxDetection_Components.Length)
                break;

            boxDetection index_0 = boxDetection_Components[i];
            float posY0 = Mathf.Round(index_0.transform.position.y);
            boxDetection index_01 = boxDetection_Components[i + 1];
            float posY01 = Mathf.Round(index_01.transform.position.y);

            if (posY0 < posY01)
            {
                boxDetection temp = boxDetection_Components[i];
                boxDetection_Components[i] = boxDetection_Components[i + 1];
                boxDetection_Components[i + 1] = temp;
                Sort_Boxes();
            }
            else if (posY0 == posY01)
            {
                if (index_0.transform.position.x > index_01.transform.position.x)
                {
                    boxDetection temp = boxDetection_Components[i];
                    boxDetection_Components[i] = boxDetection_Components[i + 1];
                    boxDetection_Components[i + 1] = temp;
                    Sort_Boxes();
                }
            }
        }
    }
}
