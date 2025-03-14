﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class OperatorCalculatingScript : MonoBehaviour
{
    //-----------------TOTAL TEXT-----------------
    [SerializeField] private boxDetection[] boxDetection_Components;
    [SerializeField] private TMP_Text totalText;

    //-----------------WIN PANEL-----------------
    [SerializeField] private GameObject winPanel;

    //-----------------GAME COMPLETE PANEL-----------------
    [SerializeField] private GameObject gameCompletePanel;

    //-----------------OBJECTIVE TEXT--------------
    [SerializeField] private TMP_Text objectiveNumber;
    
    //-----------------LEVEL NUMBER----------------
    [SerializeField] private TMP_Text levelNumber;

    private void OnEnable()
    {
        objectManager.Instance.UpdateTotalText += UpdateText;
        SceneManager.sceneLoaded += ChangeScene;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.UpdateTotalText -= UpdateText;
        SceneManager.sceneLoaded -= ChangeScene;
    }

    private void Start()
    {
        boxDetection_Components = FindObjectsOfType<boxDetection>();
        winPanel.SetActive(false);
        gameCompletePanel.SetActive(false);
        objectiveNumber.text = GameManager.Instance.win_Total.ToString();
        StartCoroutine(DelayedUpdate());
    }

    //Updates the text that shows the total value
    private void UpdateText()
    {
        Sort_Boxes();

        string allNumbers = "";

        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            if (boxDetection_Components[i].IsInBoundingBox && boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text != "")
            {
                TMP_Text[] textComponents = boxDetection_Components[i].GetComponentsInChildren<TMP_Text>();
                foreach (TMP_Text t in textComponents)
                { 
                    allNumbers += t.text;
                }
            }
        }

        if (allNumbers != "")
        {
            allNumbers = allNumbers.Remove(allNumbers.Length - 1);
            allNumbers = allNumbers.Replace(" ", "");
            
            totalText.text = allNumbers + "=" + EquationEvaluator.Evaluate(allNumbers);
        }
        else
        {
            allNumbers = "0";
            totalText.text = "0";
        }
        
        WinCheckAndTextUpdate(EquationEvaluator.Evaluate(allNumbers));
    }

    private void WinCheckAndTextUpdate(string finalTotal)
    {
        if (float.Parse(finalTotal) == GameManager.Instance.win_Total)
        {
            //totalText.text += "\n<color=orange>" + finalTotal + "</color><color=green><b>=" + GameManager.Instance.win_Total + "<b></color>";
            if(SceneManager.GetActiveScene().buildIndex == SceneManager.sceneCountInBuildSettings - 1)
            {
                gameCompletePanel.SetActive(true);
            }
            else
            {
                winPanel.SetActive(true);
            }
        }
        else
        {
            //totalText.text += "\n<color=#D97448>" + finalTotal + "</color><color=#7C0A02><b>≠" + GameManager.Instance.win_Total + "<b></color>";
        }
    }

    public void NextLevel()
    {
        Debug.Log("Next Level");
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        currentSceneIndex++;
        if(currentSceneIndex < SceneManager.sceneCountInBuildSettings)
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
                (boxDetection_Components[i], boxDetection_Components[i + 1]) = (boxDetection_Components[i + 1], boxDetection_Components[i]);
                Sort_Boxes();
            }
            else if (posY0 == posY01)
            {
                if (index_0.transform.position.x > index_01.transform.position.x)
                {
                    (boxDetection_Components[i], boxDetection_Components[i + 1]) = (boxDetection_Components[i + 1], boxDetection_Components[i]);
                    Sort_Boxes();
                }
            }
        }
    }

    //Updates the text on top but after some small delay. This is done so that that boxes are added
    private IEnumerator DelayedUpdate()
    {
        yield return new WaitForSeconds(0.5f);
        UpdateText();
    }
    
    //Called everytime the scene changes
    private void ChangeScene(Scene scene, LoadSceneMode mode)
    {
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        currentSceneIndex++;
        levelNumber.text = currentSceneIndex.ToString();
    }

    public void MuteToggle(bool state)
    {
        AudioManager.Instance.MuteAudio(state);
    }
}

