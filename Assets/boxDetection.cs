using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;

public class boxDetection : MonoBehaviour
{
    private TMP_Text myNumber;
    private string newText;
    public string originalText { get; private set; }

    //Storing the component and string of the collided GameObject so that we can reset it later
    [field: Space(10)]
    [field: Header("Number Merge")]
    public TMP_Text colliderNum = null;
    public string collidedText = "";

    //BoundingBox fields storing the status and the bounding box
    [field: Space(10)]
    [field: Header("Bounding Box")]
    [field: SerializeField] public bool IsInBoundingBox { get; private set; } = false; 
    public BoundingBox _boundingBox = null;
    
    //Storage for parent
    public Vector3 PositionOfParent { get; private set; } = Vector3.zero;
    
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
        IsInBoundingBox = BoundingBoxCheckRay();
        PositionOfParent = transform.parent.position;
    }
    
    //Called when the mouse button is released
    public void ShootRay()
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);
        
        //Reset Everything
        colliderNum = null;
        collidedText = "";

        foreach (var h in hit)
        {
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                collidedText = colliderNum.text;

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
        IsInBoundingBox = BoundingBoxCheckRay();
    }

    //Called when the object is picked up
    public void Subscribe()
    {
        objectManager.Instance.OnObjectReleased += ShootRay;
    }

    public void Unsubscribe()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.OnObjectReleased -= ShootRay;
    }

    //Called when the object is picked up
    public void ResetText()
    {
        myNumber.text = originalText;

        if (colliderNum != null) { 
            colliderNum.text = collidedText;
        }
        collidedText = "";
        
        //If the object is picked from a bounding box method recalculates the value in the bounding box
        if (_boundingBox != null) _boundingBox.RecalculateNumber_OnClick(transform.parent.gameObject);

        _boundingBox = null;

    }
    
    //Called after shoot ray. Shoot ray is called on mouse release
    private bool BoundingBoxCheckRay()
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);
        bool foundBoundingBox = false;
        foreach (RaycastHit2D h in hit)
        {
            if (h.collider != null && h.collider.tag == "BoundingBox")
            {
                foundBoundingBox = true;
                _boundingBox = h.collider.gameObject.GetComponent<BoundingBox>();
                break;
            }
            else
            {
                foundBoundingBox = false;
                _boundingBox = null;
            }
        }
        
        return foundBoundingBox;
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
    
    //Called by the bounding box when we want to recalculate the figure
    public void ShootRay_Revaluate(GameObject objectToIgnore)
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);
        
        //Reset Everything
        colliderNum = null;
        collidedText = "";

        foreach (var h in hit)
        {
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject")
            {
                TMP_Text numberText = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                boxDetection bDScriptOnObject = h.collider.gameObject.GetComponent<boxDetection>();

                numberText.text = bDScriptOnObject.originalText;
                
                Debug.Log("Originial Text: " + numberText.text);
            }
        }
        
        //Improve it in a way that it recalculates all the superimpositions
        foreach (var h in hit)
        {
            bool calculate = true;
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                for (int i = 0; i < objectToIgnore.transform.childCount; i++)
                {
                    if (h.collider.gameObject == objectToIgnore.transform.GetChild(i).gameObject)
                    {
                        calculate = false;
                        break;
                    }
                }

                if (calculate)
                {
                    colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();
                    collidedText = colliderNum.text;
            
                    newText = NumberOpertatorCombine() + colliderNum.text;
                    colliderNum.text = "";
                    Debug.Log("new Text: "+ newText);
                    myNumber.text = EquationEvaluator.Evaluate(newText);
                    Debug.Log("myNumber.text: "+ myNumber.text);
                    break; //This breaks out of that constant calculation
                }
            }
            else
            {
                colliderNum = null;
                collidedText = "";
            }
        }
    }
}

