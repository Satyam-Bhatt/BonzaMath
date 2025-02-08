using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class MouseAndShader : MonoBehaviour
{
    public Material material;
    public Vector2 num;
    public float threshold = 0.5f;

    float valX, valY;

    private void Awake()
    {
        material = GetComponent<Renderer>().material;
        valX = 0;
        valY = 0;
    }

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetAxis("Mouse X") != 0)
        {
            valX = valX + Input.GetAxis("Mouse X") * Time.deltaTime * 10;
            Debug.Log(valX);
        }
        else
        {
            valX = 0;
            //if (valX > threshold)
            //{
            //    valX -= 0.5f * Time.deltaTime;
            //}
            //else if (valX < -threshold)
            //{
            //    valX += 0.5f * Time.deltaTime;
            //}
            //else if (Mathf.Abs(valX) < threshold)
            //{
            //    valX = 0;
            //}
        }
        if (Input.GetAxis("Mouse Y") != 0)
        {
            valY = valY + Input.GetAxis("Mouse Y") * Time.deltaTime * 10;
        }
        else
        {
            valY = 0;
            //if (valY > threshold)
            //{
            //    valY -= 0.5f * Time.deltaTime;
            //}
            //else if (valY < -threshold)
            //{
            //    valY += 0.5f * Time.deltaTime;
            //}
            //else if (Mathf.Abs(valY) < threshold)
            //{
            //    valY = 0;
            //}
        }
        Debug.Log(valX + " valY: " + valY);
        material.SetFloat("_DirectionX", Mathf.Clamp(valX, -1, 1));
        //material.SetFloat("_DirectionY", Mathf.Clamp(valY, -1, 1));
    }

    IEnumerator AnimateProperties()
    {
        while(true)
        {
            if(Input.GetAxis("Mouse X") != 0 || Input.GetAxis("Mouse Y") != 0)
            {
                material.SetFloat("_DirectionX", 1);
                material.SetFloat("_DirectionY", 1);
            }
            else
            {
                material.SetFloat("_DirectionX", 0);
                material.SetFloat("_DirectionY", 0);
            }


            yield return new WaitForSeconds(0.2f);
        }
    }
}
