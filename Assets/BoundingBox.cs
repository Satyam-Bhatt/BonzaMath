using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoundingBox : MonoBehaviour
{
    [field: SerializeField] public bool CanBeFilled { get; private set; } = false;

    public List<GameObject> storedObject = null; //The Objects present in the Bounding Box

    private void OnEnable()
    {
        objectManager.Instance.SendHitObject += PopulateBoxHighlights;
        objectManager.Instance.OnObjectReleased += MouseClickReleased;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
        {
            objectManager.Instance.SendHitObject -= PopulateBoxHighlights;
            objectManager.Instance.OnObjectReleased -= MouseClickReleased;
        }
    }

    public void Fill(bool state)
    {
        CanBeFilled = state;
    }

    public void ChangeColor(Color color)
    {
        GetComponent<SpriteRenderer>().color = color;
    }

    private void PopulateBoxHighlights(GameObject o)
    {
        foreach (GameObject gO in storedObject)
        {
            if (gO == o)
            {
                storedObject.Remove(o);
                break;
            }
        }
    }

    private void MouseClickReleased()
    {
        if (storedObject.Count > 0)
        {
            ChangeColor(Color.black);
        }
        else
        {
            ChangeColor(Color.white);
        }
    }

    public void ColorChange()
    {
        ChangeColor(storedObject.Count > 0 ? Color.black : Color.white);
    }

    public void RecalculateNumber(GameObject objectParent)
    {
        if (storedObject.Count > 0)
        {
            //Change
            Debug.Log("Passed Object Name: " + objectParent.name);
            
            foreach (GameObject gO in storedObject)
            {
                Debug.Log("Nameee: " + gO.name);
            }
            
            Debug.Log("Last Object To be added: " + storedObject[storedObject.Count - 1].name);
            
            //if the name of the last object is not the same then we will need to recalculate
            if (storedObject[storedObject.Count - 1].name != objectParent.name)
            {
                GameObject  parent = storedObject[storedObject.Count - 1];

                for (int i = 0; i < parent.transform.childCount; i++)
                {
                    GameObject child = parent.transform.GetChild(i).gameObject;
                    if ((Vector2)child.transform.position == (Vector2)transform.position)
                    {
                        Debug.Log("Right Child Spotted : " + child.name);
                        child.GetComponent<boxDetection>().ShootRay_Revaluate(objectParent);
                    }
                    else
                    {
                        Debug.Log("Wriong Child Spotted : " + child.name);
                    }
                }
            }
            
        }
    }
}