using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class HeadController : MonoBehaviour {
    // HeadController replaces tracked head camera (SteamVRTracked...) and TouchController
    // for running without SteamVR
	public NetworkController myNetwork;
    public GazeController myGazeController;

    public float rotSpeed = 30.0f;
	//public double btnCounterZ = 0;
	//public double btnCounterX = 0;
	public int END = 0;
 

    // Use this for initialization
    void Start () {
        Debug.Log("Enabling KEYBOARD mode");
	}
	
	// Update is called once per frame
	void Update () {
        // Trigger emulation
        if (Input.GetKey("space"))
        {
            myGazeController.HandleTriggerPull();
        }


        // Head rotation:
        if (Input.GetKey("up"))
        {
            transform.Rotate(-rotSpeed * Vector3.right * Time.deltaTime);
        }

        if (Input.GetKey("down"))
        {
            transform.Rotate(rotSpeed * Vector3.right * Time.deltaTime);
        }

        if (Input.GetKey("right"))
        {
            transform.Rotate(rotSpeed * Vector3.up * Time.deltaTime,Space.World);
        }

        if (Input.GetKey(KeyCode.LeftArrow))
        {
            transform.Rotate(-rotSpeed * Vector3.up * Time.deltaTime, Space.World);
        }


		// Increase or decrease binaural cue value for method of adjustment task
		//if(Input.GetKeyDown("z"))
		//{
		//	btnCounterZ = btnCounterZ - 1;
		//	Debug.Log (btnCounterZ);
		//}

		//if(Input.GetKeyDown("x"))
		//{
		//	btnCounterX = btnCounterX + 1;
		//	Debug.Log (btnCounterX);
		//}
			

		// stop the standard-probe MOA task loop
		//if (Input.GetKey (KeyCode.End)) 
		//{
		//	END = 1;
		//}
    }

}
