using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoundingBox : MonoBehaviour
{
    [field:SerializeField] public bool IsFilled { get; private set; }  = false;

    public List<BoundingBoxWithTile> _boxToHighlight = null;
    public GameObject storedObject = null;

    private void OnEnable()
    {
        objectManager.Instance.SendHitObject += PopulateBoxHighlights;
    }

    private void OnDisable()
    {
        objectManager.Instance.SendHitObject -= PopulateBoxHighlights;

    }

    public void Fill( bool state)
    {
        IsFilled = state;
    }

    public void ChangeColor(Color color)
    {
        GetComponent<SpriteRenderer>().color = color;
    }

    public void PopulateBoxHighlights(GameObject o)
    {
        if (o == storedObject)
        {
           if(_boxToHighlight.Count > 0) objectManager.Instance._boxesToHighlight = new List<BoundingBoxWithTile>(_boxToHighlight);
        }
    }
}
