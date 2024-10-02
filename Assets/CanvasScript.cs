using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class CanvasScript : MonoBehaviour
{
    //Total Text
    private boxDetection[] boxDetection_Components;
    [SerializeField] private TMP_Text totalText;

    private void OnEnable()
    {
        objectManager.Instance.OnObjectReleased += UpdateText;
    }

    private void OnDisable()
    {
        objectManager.Instance.OnObjectReleased -= UpdateText;
    }

    private void Start()
    {
        boxDetection_Components = FindObjectsOfType<boxDetection>();
    }

    public void UpdateText()
    { 
        
    }
}
