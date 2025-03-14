using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;

public class objectManager : MonoBehaviour
{
    private static objectManager _instance;

    public static objectManager Instance
    {
        get
        {
            _instance = FindObjectOfType<objectManager>();
            if (_instance == null)
            {
                _instance = GameObject.FindObjectOfType<objectManager>(true);
            }

            return _instance;
        }
    }

    //--------------RAYCAST-----------------
    private Ray ray;
    private RaycastHit2D[] hit;
    private Vector2 mousePosition_;
    private GameObject hitObject;

    //--------------EVENT-----------------
    public event Action OnObjectReleased; //Fired when the object is released by the mouse
    public event Action UpdateTotalText; //Updates the total text
    public event Action<GameObject> SendHitObject; //Sends Out HitObject when mouse is clicked and HitObject != null

    //--------------OBJECT POSITION-----------
    private float _zValueForObject = -0.1f;

    //-------------BOUNDING BOX---------------
    [SerializeField] private GameObject[] boundingBoxes;
    public List<BoundingBoxWithTile> boxesToHighlight = new List<BoundingBoxWithTile>();
    private BoundingBox _boxToHighlight = null;
    private Transform _relaventTile = null;

    void Start()
    {
        boundingBoxes = GameObject.FindGameObjectsWithTag("BoundingBox"); //Not efficient
    }

    // Update is called once per frame
    void Update()
    {
        mousePosition_ = Camera.main.ScreenToWorldPoint(Input.mousePosition);

        if (Input.GetKeyDown(KeyCode.Mouse0) && hitObject == null)
        {
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            hit = Physics2D.RaycastAll(ray.origin, ray.direction);
            foreach (RaycastHit2D h in hit)
            {
                if (h.collider != null && h.collider.gameObject.tag == "MainObject")
                {
                    hitObject = h.collider.gameObject;

                    #region Populate the list of BoundingBox To check distance with them
                    for (int i = 0; i < hitObject.transform.childCount; i++)
                    {
                        Transform childTransform = hitObject.transform.GetChild(i);
                        BoundingBox childStoredBoundinBox = hitObject.transform.GetChild(i).GetComponent<boxDetection>()._boundingBox;
                        if (childStoredBoundinBox != null)
                        {
                            BoundingBoxWithTile childStoredBoundinBoxWithTile = new BoundingBoxWithTile(childStoredBoundinBox, childTransform);
                            boxesToHighlight.Add(childStoredBoundinBoxWithTile);
                        }
                    }
                    #endregion

                    boxDetection[] boxDetections = hitObject.GetComponentsInChildren<boxDetection>();
                    foreach (boxDetection bD in boxDetections)
                    {
                        bD.Subscribe();
                        bD.ResetText();

                        bD.GetComponent<MouseAndShader>().onHold = true;
                    }

                    //Play pick sound
                    AudioManager.Instance.Pickup();

                    break;
                }
            }

            SendHitObject?.Invoke(hitObject);

            ResetZPosition();
        }

        if (Input.GetKey(KeyCode.Mouse0) && hitObject != null)
        {
            AttachToMouse(hitObject);
            BoundingBoxHighlight(hitObject);

            if (Input.GetKeyDown(KeyCode.E))
            {
                RotateRight(hitObject);
            }
            else if (Input.GetKeyDown(KeyCode.Q))
            {
                RotateLeft(hitObject);
            }
        }
        else if (Input.GetKeyUp(KeyCode.Mouse0) && hitObject != null)
        {
            if (boxesToHighlight.Count == hitObject.transform.childCount)
            {
                DetachFromMouse(hitObject);
            }
            else
            {
                hitObject.transform.position = hitObject.transform.GetChild(0).GetComponent<boxDetection>().PositionOfParent;
            }
            OnObjectReleased?.Invoke(); // Shoots a ray from the cubes and checks if the cell occupies any bounding boxes

            boxDetection[] boxDetections = hitObject.GetComponentsInChildren<boxDetection>();
            foreach (boxDetection bD in boxDetections)
            {
                bD.Unsubscribe();

                bD.GetComponent<MouseAndShader>().onHold = false;
            }

            //Adds the Hit Object to the corresponding bounding boxes.
            if (boxesToHighlight.Count > 0)
            {
                foreach (BoundingBoxWithTile b in boxesToHighlight)
                {
                    b.boundingBox.storedObject.Add(hitObject);
                    b.boundingBox.RecalculateNumber_OnRelease();
                    b.boundingBox.ChangeColor(new Color(0.78f, 0.18f, 0.09f)); //Color when the cell is occupied
                }
            }

            UpdateTotalText?.Invoke();

            boxesToHighlight.Clear();

            hitObject = null;

            //Camera Shake
            GameManager.Instance.ShakeCamera();

            //Play place sound
            AudioManager.Instance.Place();
        }
    }

    //Checks the distance and then highlights the box
    private void BoundingBoxHighlight(GameObject o)
    {
        //When the hit object finds the bounding box just loop through the bounding boxes found by the hit object
        if (boxesToHighlight.Count == o.transform.childCount)
        {
            foreach (BoundingBoxWithTile box in boxesToHighlight)
            {
                box.boundingBox.ChangeColor(new Color(0.85f, 0.74f, 0.15f));
            }

            //Distance Check
            foreach (BoundingBoxWithTile box in boxesToHighlight)
            {
                float dist = Vector2.Distance(box.boundingBox.transform.position, box.tileTransform.position);
                if (dist > 0.75f)
                {
                    foreach (BoundingBoxWithTile box2 in boxesToHighlight)
                    {
                        box2.boundingBox.ColorChange();
                        box2.boundingBox.Fill(false);
                    }

                    _boxToHighlight = null;
                    _relaventTile = null;
                    boxesToHighlight.Clear();
                    return;
                }
            }
        }
        //When the hit object doesn't find the bounding box just loop through all the bounding boxes present
        else
        {
            for (int i = 0; i < o.transform.childCount; i++)
            {
                Transform child = o.transform.GetChild(i);
                foreach (var vBox in boundingBoxes)
                {
                    BoundingBox boundingBox = vBox.GetComponent<BoundingBox>();
                    if (!boundingBox.CanBeFilled)
                    {
                        var minDist = 100f;
                        var distBetweenBoxAndObject = Vector2.Distance(child.position, boundingBox.transform.position);
                        if (distBetweenBoxAndObject < minDist && distBetweenBoxAndObject < 0.5f)
                        {
                            _boxToHighlight = boundingBox;
                            _relaventTile = child;
                            minDist = distBetweenBoxAndObject;
                        }
                    }
                }

                if (!_boxToHighlight)
                {
                    boxesToHighlight.Clear();
                    return;
                }

                BoundingBoxWithTile box = new BoundingBoxWithTile(_boxToHighlight, _relaventTile);
                boxesToHighlight.Add(box);
                _boxToHighlight = null;
                _relaventTile = null;
            }
        }
    }

    //Resets all the main objects to 0 on Z axis
    private void ResetZPosition()
    {
        if (hitObject == null)
        {
            return;
        }
        else
        {
            hitObject.transform.position = new Vector3(hitObject.transform.position.x, hitObject.transform.position.y, -2);
            GameManager.Instance.tutorialState = false;
        }

        //GameObject[] mainObjects = GameObject.FindGameObjectsWithTag("MainObject");
        //int objectsStoringOtherObjects = 1;
        //foreach (GameObject mO in mainObjects)
        //{
        //    if (mO.GetComponentInChildren<boxDetection>() != null && mO.GetComponentInChildren<boxDetection>().colliderNum == null)
        //    {
        //        mO.transform.position = new Vector3(mO.transform.position.x, mO.transform.position.y, 0);
        //    }
        //    else if (mO.GetComponentInChildren<boxDetection>() != null && mO.GetComponentInChildren<boxDetection>().colliderNum != null)
        //    {
        //        objectsStoringOtherObjects++;
        //    }
        //}

        //_zValueForObject = objectsStoringOtherObjects switch
        //{
        //    1 => -0.1f,
        //    > 1 => -0.1f * objectsStoringOtherObjects,
        //    _ => _zValueForObject
        //};
    }

    private void RotateLeft(GameObject gameObj)
    {
        float rotationAngle = gameObj.transform.rotation.eulerAngles.z - 90;
        gameObj.transform.rotation = Quaternion.AngleAxis(rotationAngle, Vector3.forward);

        //Rotates the canvas in opposite direction
        Canvas[] canvases = gameObj.transform.GetComponentsInChildren<Canvas>();
        foreach (Canvas canvas in canvases)
        {
            if (canvas.gameObject.CompareTag("ObjectCanvas"))
            {
                canvas.gameObject.transform.rotation = Quaternion.Inverse(gameObj.transform.rotation) * gameObj.transform.rotation;
            }
        }
    }

    private void RotateRight(GameObject gameObj)
    {
        float rotationAngle = gameObj.transform.rotation.eulerAngles.z + 90;
        gameObj.transform.rotation = Quaternion.AngleAxis(rotationAngle, Vector3.forward);

        //Rotates the canvas in opposite direction
        Canvas[] canvases = gameObj.transform.GetComponentsInChildren<Canvas>();
        foreach (Canvas canvas in canvases)
        {
            if (canvas.gameObject.CompareTag("ObjectCanvas"))
            {
                canvas.gameObject.transform.rotation = Quaternion.Inverse(gameObj.transform.rotation) * gameObj.transform.rotation;
            }
        }
    }

    private void DetachFromMouse(GameObject gameObj)
    {
        float posX = Mathf.Round(gameObj.transform.position.x);
        float posY = Mathf.Round(gameObj.transform.position.y);
        gameObj.transform.position = new Vector3(posX, posY, _zValueForObject);
    }

    private void AttachToMouse(GameObject gameObj)
    {
        gameObj.transform.position = new Vector3(mousePosition_.x, mousePosition_.y, -2);
    }
}

[System.Serializable]
public class BoundingBoxWithTile
{
    public BoundingBox boundingBox;
    public Transform tileTransform;

    public BoundingBoxWithTile(BoundingBox boundingBox_, Transform tileTransform_)
    {
        boundingBox = boundingBox_;
        tileTransform = tileTransform_;
    }
}