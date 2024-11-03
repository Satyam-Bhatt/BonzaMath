using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoundingBox : MonoBehaviour
{
    [SerializeField] private bool isFilled = false;

    public void Fill( bool state)
    {
        isFilled = state;
    }
}
