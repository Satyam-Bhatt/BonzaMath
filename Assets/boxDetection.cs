using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class boxDetection : MonoBehaviour
{
    private TMP_Text myNumber;

    private string originalText;

    public string newText;

    private void Awake()
    {
        myNumber = GetComponentInChildren<TMP_Text>();
    }

    private void OnEnable()
    {
        objectManager.Instance.OnObjectReleased += ShootRay;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.OnObjectReleased -= ShootRay;
    }

    private void Start()
    {
        this.GetComponent<boxDetection>().enabled = false;

        originalText = myNumber.text;
    }

    public void ShootRay()
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);

        foreach (var h in hit)
        { 
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                Debug.Log(h.collider.gameObject.name);
                TMP_Text colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                newText = colliderNum.text + myNumber.text;
            }        
        }
    }
}

