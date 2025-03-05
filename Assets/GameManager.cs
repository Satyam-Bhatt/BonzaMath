using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private static GameManager _instance;
    public static GameManager Instance
    {
        get
        {
            _instance = FindObjectOfType<GameManager>();
            if (_instance == null)
            {
                _instance = GameObject.FindObjectOfType<GameManager>(true);
            }

            return _instance;
        }
    }

    [field:SerializeField] public int win_Total { get; private set; } = 0;
    public bool tutorialState = false;

    [Range(0.1f, 1f)]
    public float shakeMagnitude = 0.3f;

    [Range(0.1f, 2f)]
    public float shakeDuration = 0.5f;

    [Range(1f, 10f)]
    public float shakeDecay = 3f;

    private Vector3 originalPosition;
    private float shakeIntensity;

    public void ShakeCamera()
    {
        originalPosition = Camera.main.transform.localPosition;
        shakeIntensity = shakeMagnitude;
        StopAllCoroutines();
        StartCoroutine(DoShake());
    }

    private IEnumerator DoShake()
    {
        while (shakeIntensity > 0)
        {
            Vector3 shakeOffset = Random.insideUnitSphere * shakeIntensity;

            Camera.main.transform.localPosition = originalPosition + shakeOffset;
            shakeIntensity = Mathf.Lerp(shakeIntensity, 0, shakeDecay * Time.deltaTime);

            yield return null;
        }

        Camera.main.transform.localPosition = originalPosition;
    }

}
