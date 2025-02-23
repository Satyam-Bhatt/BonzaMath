using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    private static AudioManager _instance;
    public static AudioManager Instance
    {
        get
        {
            _instance = FindObjectOfType<AudioManager>();
            if (_instance == null)
            {
                _instance = GameObject.FindObjectOfType<AudioManager>(true);
            }

            return _instance;
        }
    }

    public AudioSource audioSource1;
    public AudioSource audioSource2;
    [SerializeField] private AudioClip placeSound;
    [SerializeField] private AudioClip pickSound;

    private void Awake()
    {
        DontDestroyOnLoad(this);
    }

    public void MuteAudio(bool state)
    {
        audioSource1.mute = state;
        audioSource2.mute = state;
    }

    public void Pickup()
    {
        audioSource2.PlayOneShot(pickSound);
    }

    public void Place()
    {
        audioSource1.PlayOneShot(placeSound);
    }
}
