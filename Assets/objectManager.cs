using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    //Fired when the object is released by the mouse
    public event Action OnObjectReleased;

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
                    boxDetection[] boxDetections = hitObject.GetComponentsInChildren<boxDetection>();
                    foreach (boxDetection bD in boxDetections)
                    { 
                        bD.enabled = true;
                    }

                    break;
                }
            }
        }

        if (Input.GetKey(KeyCode.Mouse0) && hitObject != null)
        {
            AttachToMouse(hitObject);

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
            DetachFromMouse(hitObject);
            OnObjectReleased?.Invoke(); // Shoots a ray from the cubes
            boxDetection[] boxDetections = hitObject.GetComponentsInChildren<boxDetection>();
            foreach (boxDetection bD in boxDetections)
            {
                bD.enabled = false;
            }
            hitObject = null;
        }
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
        gameObj.transform.position = new Vector2(posX, posY);
    }

    private void AttachToMouse(GameObject gameObj)
    {
        gameObj.transform.position = mousePosition_;
    }
}