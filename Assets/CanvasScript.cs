using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

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

        Debug.Log(allNumbers);
        string total = EquationEvaluator.Evaluate(allNumbers);
        allNumbers += "=" + total;

        totalText.text = allNumbers;
    }
}
