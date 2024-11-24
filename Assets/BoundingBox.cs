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
}