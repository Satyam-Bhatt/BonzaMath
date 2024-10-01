using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

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
                        bD.Subscribe();
                        bD.ResetText();
                    }

                    break;
                }
            }

            ResetZPosition();
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
                bD.Unsubscribe();
                //bD.enabled = false;
            }
            hitObject = null;
        }
    }

    //Resets all the main objects to 0 on Z axis
    private void ResetZPosition()
    {
        GameObject[] mainObjects = GameObject.FindGameObjectsWithTag("MainObject");

        foreach (GameObject mO in mainObjects)
        {
            mO.transform.position = new Vector3(mO.transform.position.x, mO.transform.position.y, 0);
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
        gameObj.transform.position = new Vector3(posX, posY, -0.1f);
    }

    private void AttachToMouse(GameObject gameObj)
    {
        gameObj.transform.position = new Vector3(mousePosition_.x, mousePosition_.y, -0.1f);
    }
}
