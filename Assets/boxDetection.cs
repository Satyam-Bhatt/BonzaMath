using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class boxDetection : MonoBehaviour
{
    private TMP_Text myNumber;
    private string newText;
    public string originalText { get; private set; }

    //Storing the component and string of the collided GameObject so that we can reset it later
    public TMP_Text colliderNum = null;
    public string collidedText = "";

    //BoundingBox
    [field: SerializeField] public bool IsInBoundingBox { get; private set; } = false; 
    [SerializeField]  private BoundingBox _boundingBox = null;
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

    public void Subscribe()
    {
        objectManager.Instance.OnObjectReleased += ShootRay;
        _boundingBox = null;
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
            colliderNum.text = collidedText;
        }
        collidedText = "";
    }
    
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
                _boundingBox.Fill(true);
                break;
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
}

