using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementOfFinger : MonoBehaviour
{
    [SerializeField] private ParticleSystem particles;
    [SerializeField] private Vector3 finalPosition;
    Vector3 position_Original;

    Vector3 speed = Vector3.zero;

    // Start is called before the first frame update
    void Start()
    {
        GameManager.Instance.tutorialState = true;
        position_Original = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        if (!GameManager.Instance.tutorialState)
        {
            particles.Stop();
            this.gameObject.SetActive(false);
            return;
        } 

        if(Vector3.Distance(transform.position, finalPosition) < 0.1f)
        {
            particles.Stop();
            transform.position = position_Original;
            particles.Play();
        }
        else
        {
            transform.position = Vector3.SmoothDamp(transform.position, finalPosition, ref speed, 1f);
        }
        particles.transform.position = new Vector3(transform.position.x, transform.position.y - 0.1f, transform.position.z);
    }
}
