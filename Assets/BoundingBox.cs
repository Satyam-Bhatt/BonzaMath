using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoundingBox : MonoBehaviour
{
    [field:SerializeField] public bool IsFilled { get; private set; }  = false;

    public void Fill( bool state)
    {
        IsFilled = state;
    }

    public void ChangeColor(Color color)
    {
        GetComponent<SpriteRenderer>().color = color;
    }
}
