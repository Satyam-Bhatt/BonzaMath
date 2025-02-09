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

    private IEnumerator storeRoutine;
    float timeStore = 0;
    bool isRunning = false;
    bool timerRunning = false;

    private void Awake()
    {
        material = GetComponent<Renderer>().material;
        valX = 0;
        valY = 0;
    }

    // Start is called before the first frame update
    void Start()
    {
        storeRoutine = TestRoutine();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetAxis("Mouse X") != 0)
        {
            timerRunning = true;
            if(!isRunning)
            {
                //valX = valX + Input.GetAxis("Mouse X") * Time.deltaTime * 10;
                StartCoroutine(storeRoutine);
                isRunning = true;
            }
        }
        else if (Input.GetAxis("Mouse X") == 0 && isRunning)
        {
            timerRunning = false;
            if(timeStore + 2f < Time.time)
            {
                StopCoroutine(storeRoutine);
                isRunning = false;
                Debug.Log("!!!");
                valX = 0;
            }    
        }

        if(timerRunning && isRunning)
        {
            timeStore = Time.time;
        }

        //Debug.Log(valX + " valY: " + valY);
        material.SetFloat("_DirectionX", Mathf.Clamp(valX, -1, 1));
        //material.SetFloat("_DirectionY", Mathf.Clamp(valY, -1, 1));
    }

    IEnumerator TestRoutine()
    {
        while (true)
        {
            valX += 0.01f;
            Debug.Log("+++++" + valX);
            yield return new WaitForSeconds(0.05f);
        }
    }
    IEnumerator StopOtherRoutine()
    {
        yield return new WaitForSeconds(2f);
        if (Input.GetAxis("Mouse X") == 0)
        {
            StopCoroutine(storeRoutine);
            Debug.Log("!!!");
            valX = 0;
        }
    }

    IEnumerator AnimateProperties()
    {
        while (true)
        {
            if (Input.GetAxis("Mouse X") != 0 || Input.GetAxis("Mouse Y") != 0)
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
