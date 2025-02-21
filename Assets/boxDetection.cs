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
                collidedText = h.collider.gameObject.GetComponentInChildren<TMP_Text>().text;
                colliderNum = h.collider.gameObject.GetComponentInChildren<TMP_Text>();

                colliderNum.text = "";
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

        collidedText = "";

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

}

