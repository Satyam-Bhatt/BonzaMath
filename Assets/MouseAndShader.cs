using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class MouseAndShader : MonoBehaviour
{
    private Material material;
    public Vector2 num;
    public float threshold = 0.5f;

    float valX, valY;

    private void Awake()
    {
        valX = 0;
        valY = 0;
    }

    // Start is called before the first frame update
    void Start()
    {
        Material materialInstance = Instantiate(GetComponent<MeshRenderer>().sharedMaterial);
        GetComponent<MeshRenderer>().material = materialInstance;
        material = materialInstance;
    }

    // Update is called once per frame
    void Update()
    {

        if (Input.GetAxis("Mouse X") > 0)
        {
            valX += 4 * Time.deltaTime;
            material.SetFloat("_SignX", 1);
        }
        else if (Input.GetAxis("Mouse X") < 0)
        {
            valX -= 4 * Time.deltaTime;
            material.SetFloat("_SignX", -1);
        }
        else
        {
            if (Approximate(valX, 0, 0.01f))
            {
                valX = 0;
            }
            else
            {
                valX = Mathf.Lerp(valX, 0, 4 * Time.deltaTime);
            }
        }

        if(Input.GetAxis("Mouse Y") > 0)
        {
            valY += 4 * Time.deltaTime;
            material.SetFloat("_SignY", 1);
        }
        else if (Input.GetAxis("Mouse Y") < 0)
        {
            valY -= 4 * Time.deltaTime;
            material.SetFloat("_SignY", -1);
        }
        else
        {
            if (Approximate(valY, 0, 0.01f))
            {
                valY = 0;
            }
            else
            {
                valY = Mathf.Lerp(valY, 0, 4 * Time.deltaTime);
            }
        }

        material.SetFloat("_DirectionX", Mathf.Clamp(valX, -1, 1));
        material.SetFloat("_DirectionY", Mathf.Clamp(valY, -1, 1));
    }

    private bool Approximate(float a, float b, float threshold)
    {
        return Mathf.Abs(a - b) < threshold;
    }
}
