using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class boxDetection : MonoBehaviour
{
    private TMP_Text myNumber;
    private string newText;

    //Storing the component and string of the collided GameObject so that we can reset it later
    private TMP_Text colliderNum = null;
    private string collidedText = "";

    public string originalText;


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
        GetComponent<boxDetection>().enabled = false;

        originalText = myNumber.text;
    }

    public void ShootRay()
    {
        if (colliderNum != null)
        { 
            colliderNum.text = collidedText;
        }

        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);

        foreach (var h in hit)
        {
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                collidedText = colliderNum.text;

                newText =  myNumber.text + colliderNum.text;
                Debug.Log(newText);
                myNumber.text = EquationEvaluator.Evaluate(newText);
            }
        }
    }
}

