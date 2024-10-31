using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class boxDetection : MonoBehaviour
{
    private TMP_Text myNumber;
    private string newText;

    //Storing the component and string of the collided GameObject so that we can reset it later
    public TMP_Text colliderNum = null;
    public string collidedText = "";

    public string originalText { get; private set; }


    private void Awake()
    {
        myNumber = GetComponentInChildren<TMP_Text>();
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.OnObjectReleased -= ShootRay;
    }

    private void Start()
    {
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
                colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                collidedText = colliderNum.text;
                //h.collider.gameObject.GetComponent<boxDetection>().colliderNum = myNumber;

                newText = NumberOpertatorCombine() + colliderNum.text;
                colliderNum.text = "";
                myNumber.text = EquationEvaluator.Evaluate(newText);
                break;
            }
            else
            {
                colliderNum = null;
                collidedText = "";
            }
        }
    }

    public void Subscribe()
    {
        objectManager.Instance.OnObjectReleased += ShootRay;
    }

    public void Unsubscribe()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.OnObjectReleased -= ShootRay;
    }

    public void ResetText()
    {
        myNumber.text = originalText;

        if (colliderNum != null) { 
            //colliderNum.text = colliderNum.gameObject.GetComponentInParent<boxDetection>().originalText;
            colliderNum.text = collidedText;
            //colliderNum.gameObject.GetComponentInParent<boxDetection>().collidedText = "";
            //colliderNum = null;
        }
        collidedText = "";
    }

    //Gets the two text fields one containg the number and the other containing the operator and combines them
    private string NumberOpertatorCombine()
    {
        TMP_Text[] numberPlusOperator = GetComponentsInChildren<TMP_Text>();
        string numberWithOperator = "";
        foreach (var n in numberPlusOperator)
        {
            numberWithOperator += n.text;
        }
        return numberWithOperator;
    }
}

