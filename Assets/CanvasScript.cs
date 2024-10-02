using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;
using System.Linq;

public class CanvasScript : MonoBehaviour
{
    //-----------------TOTAL TEXT-----------------
    private boxDetection[] boxDetection_Components;
    [SerializeField] private TMP_Text totalText;

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
        UpdateText();
    }

    //Updates the text that shows the total value
    public void UpdateText()
    {
        string allNumbers = "";

        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            allNumbers += boxDetection_Components[i].GetComponentInChildren<TMP_Text>().text;
        }

        allNumbers = allNumbers.Replace("-", "+").Replace("*", "+").Replace("/", "+");
        allNumbers = allNumbers.Remove(allNumbers.Length - 1);

        string total = EquationEvaluator.Evaluate(allNumbers);
        string allNumbersWithoutRichText = allNumbers + " = " + total;
        allNumbers += "= <color=orange>" + total + "</color>";

        totalText.text = allNumbers;

        WinCheckAndTextUpdate(allNumbersWithoutRichText);

    }

    private void WinCheckAndTextUpdate(string finalTotal)
    {
        finalTotal = finalTotal.Split("=").Last();
        Debug.Log(finalTotal);
        if (float.Parse(finalTotal) == GameManager.Instance.win_Total)
        {
            totalText.text += "\n" + finalTotal + "<color=green><b> =" + GameManager.Instance.win_Total + "<b></color>";
            GameManager.Instance.Win();
        }
        else
        {
            totalText.text +="\n <color=orange>" + finalTotal +  "</color><color=red><b> ≠" + GameManager.Instance.win_Total + "<b></color>";
        }
    }
}
