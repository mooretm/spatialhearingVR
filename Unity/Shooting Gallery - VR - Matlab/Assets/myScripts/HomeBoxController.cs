using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomeBoxController : MonoBehaviour {

    private bool inBox = false; // gets updated by Player Raycast
    public bool boxEnabled = true; // allows outside control of home box function
    public float timeInBox = 0.0f;
    private Renderer theRender;
    //private AudioSource theAudio;


    // Use this for initialization
    void Start () {
        theRender = GetComponent<Renderer>();
        //theAudio = GetComponentInChildren<AudioSource>();

    }

    // Update is called once per frame
    void Update () {
		
        if (inBox)
            timeInBox += Time.deltaTime;
        else
            timeInBox = 0;

        // hide this if not enabled or in the box
        theRender.enabled = (boxEnabled && !inBox);
        //theAudio.mute = (!boxEnabled || inBox);

    }

    // need to update this functionality to keep track of how long
    //      the user has been in the box. 

    public void Hide()
    {
       // theRender.enabled = false;
        inBox = true;
        // show the box again in 100 ms. So we don't need to track exiting.
        Invoke("Show", 0.1f); 
    }

    public void Show()
    {
       // theRender.enabled = true;
        inBox = false;
    }
}
