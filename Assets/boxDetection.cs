using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class boxDetection : MonoBehaviour
{
    private void OnEnable()
    {
        objectManager.Instance.OnObjectReleased += ShootRay;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.OnObjectReleased -= ShootRay;
    }

    private void Start()
    {
        this.GetComponent<boxDetection>().enabled = false;
    }

    public void ShootRay()
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);

        foreach (var h in hit)
        { 
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                Debug.Log(h.collider.gameObject.name);
            }        
        }
    }
}

