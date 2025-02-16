using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlightMovement : MonoBehaviour
{
    [SerializeField] private Transform objectToMove;
    [SerializeField] private float offset_X;
    [SerializeField] private float offset_Y;

    private Vector3 originalPosition;
    private void Start()
    {
        originalPosition = objectToMove.position;
    }

    // Update is called once per frame
    void Update()
    {
        float x, y;
        if (Input.GetAxis("Mouse Y") > 0)
        {
            y = Mathf.Lerp(objectToMove.position.y, objectToMove.position.y + offset_Y, 4 * Time.deltaTime);
        }
        else if (Input.GetAxis("Mouse Y") < 0)
        {
            y = Mathf.Lerp(objectToMove.position.y, objectToMove.position.y - offset_Y, 4 * Time.deltaTime);
        }
        else
        {
            y = Mathf.Lerp(objectToMove.position.y, originalPosition.y, 4 * Time.deltaTime);
        }

        if (Input.GetAxis("Mouse X") > 0)
        {
            x = Mathf.Lerp(objectToMove.position.x, objectToMove.position.x + offset_X, 4 * Time.deltaTime);
        }
        else if (Input.GetAxis("Mouse X") < 0)
        {
            x = Mathf.Lerp(objectToMove.position.x, objectToMove.position.x - offset_X, 4 * Time.deltaTime);
        }
        else
        {
            x = Mathf.Lerp(objectToMove.position.x, originalPosition.x, 4 * Time.deltaTime);
        }

        objectToMove.position = new Vector3(x, y, objectToMove.position.z);
    }
}
