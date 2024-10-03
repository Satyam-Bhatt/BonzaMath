﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class AlternateCanvasScript : MonoBehaviour
{
    //-----------------TOTAL TEXT-----------------
    private boxDetection[] boxDetection_Components;
    [SerializeField] private TMP_Text totalText;

    //-----------------WIN PANEL-----------------
    [SerializeField] private GameObject winPanel;

    //-----------------SORTING STUFF--------------
    private List<boxDetection> boxDetection_Components_Sorted;

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
    }

    //Updates the text that shows the total value
    public void UpdateText()
    {
        string allNumbers = "";

        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            if (boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text != "")
            {
                allNumbers += boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text + "+";
            }
        }

        allNumbers = allNumbers.Remove(allNumbers.Length - 1);
        Debug.Log(allNumbers);

        string total = EquationEvaluator.Evaluate(allNumbers);
        string allNumbersWithoutRichText = allNumbers + " = " + total;
        allNumbers += "=<color=orange>" + total + "</color>";

        totalText.text = allNumbers;

        WinCheckAndTextUpdate(allNumbersWithoutRichText);
    }

    private void WinCheckAndTextUpdate(string finalTotal)
    {
        finalTotal = finalTotal.Split("=").Last();
        if (float.Parse(finalTotal) == GameManager.Instance.win_Total)
        {
            totalText.text += "\n<color=orange>" + finalTotal + "</color><color=green><b>=" + GameManager.Instance.win_Total + "<b></color>";
            winPanel.SetActive(true);
        }
        else
        {
            totalText.text += "\n<color=orange>" + finalTotal + "</color><color=red><b>≠" + GameManager.Instance.win_Total + "<b></color>";
        }
    }

    public void NextLevel()
    {
        Debug.Log("Next Level");
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentSceneIndex++);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.S))
        {
            Sort();
        }
    }

    private void Sort()
    {
        int indexToFill = 0;
        float lowestX;
        float HighestY;
        while (boxDetection_Components_Sorted.Count != boxDetection_Components.Length)
        {
            foreach (boxDetection bD in boxDetection_Components)
            { 
                
            }
        }
    }
}
