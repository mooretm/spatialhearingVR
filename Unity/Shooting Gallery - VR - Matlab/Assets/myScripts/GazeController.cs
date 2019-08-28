using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GazeController : MonoBehaviour
{
	private Transform headTrans; //where is the head?
	public bool latched;  // flag for trigger waiting

	public ArenaController myArena;
	public GameObject armedSprite;
	public NetworkController myNetwork;

    RaycastHit hit;

	public Vector3 headPos;  // will hold the latched head position
	public Vector3 headAngle; // will hold the latched head angle

	public double btnCounterLeft = 0;
    public double btnCounterRight = 0;
	public int END = 0;

    // Use this for initialization
    void Start()
    {
		headTrans = gameObject.transform;
    }


    // Update is called once per frame
    void Update()
    {
		if (Input.GetKeyDown ("g"))
			ToggleGaze ();
		if (Input.GetKeyDown ("a"))
			ToggleArmDisplay ();
			
		if (Physics.Raycast (transform.position, transform.forward, out hit)) {
			var objectHit = hit.transform; // do something

            if (objectHit.name == "homeBox")
				objectHit.GetComponent<HomeBoxController> ().Hide ();
		}
     }


    public void HandleTriggerPull()
    {
		// Update 2/19/18: trigger pull also sets END = 1 to stop the MATLAB trial loop
		//     for the MOA task. This should be benign unless the MATLAB script looks for 
		//     this value. 


		// Update 7/20/2017: took out all of the game logic. now trigger just sets the latch
		//     for reading head pos later (from matlab)

		// first grab the head position at time of trigger pull...
		LatchHeadPos(); // take this out once under matlab control
		// if you don't, then subject can click many times and change the value

		// Everything below is obsolete. Initiate vanish directly from matlab...

        // Note that this public function gets called by TriggerController/HandleTriggerclicks
        //      the TriggerController script is attached to both hand controls, so pulling
        //      either trigger gets you here. 
        
        // This is manual raycasting...checking it ourselves
        //      I think there is an alternate approach using a
        //      Physics Raycaster to handle this more generically, 
        //      much like the Graphics Raycaster was passing OnMouseDown
        //      to your balloon objects. 
        //
        // But this works


//		// find a balloon and blow it up. take out once under matlab control?
//		int theLayerMask = 1 << LayerMask.NameToLayer("Balloons");
//	
//		if (Physics.Raycast(transform.position, transform.forward, out hit, Mathf.Infinity, theLayerMask))
//        {
//            // do something
//            var objectHit = hit.transform;
//
//			Debug.Log ("Hit: " + objectHit.ToString ());
//
//            if (objectHit.tag == "Balloon")
//            {
//                Debug.Log(objectHit.ToString());
//
//                // This works. Previously we attempted to destroy ObjectHit, which 
//                // is a Transform, not a GameObject. 
//                objectHit.GetComponent<BalloonController>().Vanish(); // was OnMouseDown
//
//                // Here you might also want to grab/return/report the head position
//                //  you could get it from the transform of this object 
//                //      (GazeController is a child of the eye camera
//                //  or you could get it from your balloons as before
//                //
//                // I'll let you play with this but I have code that handles
//                //   connection to matlab, which will allow to report back
//                //   to matlab from right here. 
//            }
//		}
    }


	public void HandlePadPress(float padX = 0, float padY = 0)  
	{
        END = 1;
		// Obsolete as bob is now initiated from matlab
		// x and y are floats
		// find a balloon and blow it up. take out once under matlab control?
//		int theLayerMask = 1 << LayerMask.NameToLayer("Balloons");
//
//		if (Physics.Raycast(transform.position, transform.forward, out hit,theLayerMask))
//		{
//			var objectHit = hit.transform; // do something
//
//			if (objectHit.tag == "Balloon")
//			{
//				Debug.Log(objectHit.ToString());
//				objectHit.GetComponent<BalloonController>().BalloonBob(padX,padY);
//			}
//		}
	}


	public void HandleButtonPress(object buttonLR)
	{
        // index 3: left controller
        // index 4: right controller
        if (buttonLR.ToString().Contains("left"))
        {
            btnCounterLeft = btnCounterLeft - 1;
            Debug.Log(btnCounterLeft);
        }
        else
        //else if (buttonLR == 4)
        {
            btnCounterRight = btnCounterRight + 1;
            Debug.Log(btnCounterRight);
        }

		// Obsolete as Respawn is now initiated from matlab
//		Debug.Log("Respawn!");
//		//goRespawn.GetComponent<respawn>().repopulate();
//		myArena.Respawn(); // it's a public method so we can just call it!
	}


    public void HandleGripDown(object gripLR)
    {
        if(gripLR.ToString().Contains("left"))
        //if (gripLR == 3)
        {
            btnCounterLeft = btnCounterLeft - 3;
            Debug.Log(btnCounterLeft);
        }
        else
        //else if (gripLR == 4)
        {
            btnCounterRight = btnCounterRight + 3;
            Debug.Log(btnCounterRight);
        }
    }



	// Here's a future thought about the gaze and armdisplay bits. Would be better
	//     to have a generic HUD in front of user, then change the texture between
	//		various assets in the Resources folder...


	// turn the gaze cross hairs on or off
	public void ToggleGaze(string onoff = "TOG")
	{
		// arg "ON" or "OFF" will set the gaze cursor on or off
		// any other (or empty) arg will toggle cursor visibility
		var gazerender = GetComponent<SpriteRenderer>();
		var curstate = gazerender.enabled;
		var newstate = new bool();

		switch (onoff)
		{
		case "ON":
			newstate = true;
			break;
		case "OFF":
			newstate = false;
			break;
		default:
			newstate = !curstate;
			break;
		}
		myNetwork.SendToServer(Time.time.ToString("F4") + "\tGAZE " + onoff);
		gazerender.enabled = newstate;
	}


	// turn the display for "armed" on or off
	public void ToggleArmDisplay(string onoff = "TOG")
	{
		// arg "ON" or "OFF" will set the gaze cursor on or off
		// any other (or empty) arg will toggle cursor visibility
		SpriteRenderer[] sprites = armedSprite.GetComponentsInChildren<SpriteRenderer> ();
		var curstate = sprites[0].enabled;
		var newstate = new bool();

		switch (onoff)
		{
		case "ON":
			newstate = true;
			break;
		case "OFF":
			newstate = false;
			break;
		default:
			newstate = !curstate;
			break;
		}
		myNetwork.SendToServer(Time.time.ToString("F4") + "\tARM " + onoff);
		foreach (SpriteRenderer mySprite in sprites) {
			mySprite.enabled = newstate;
		}
	}

// To enable this, add using UnityEngine.VR  but prepare to be VR specific
//	public void ToggleHeadTranslation(string mode = "ON")
//	{
//		switch (mode)
//		{
//		case "OFF":
//			// The following disables transalation of user (Unity 5.6+)
//			InputTracking.disablePositionalTracking = true;
//			// adjust the head height though...
//			var camRig = FindObjectOfType<SteamVR_ControllerManager>();
//			camRig.transform.localPosition = new Vector3(0.0f, 1.44f, 0.0f); // y=1.44 is where GameController puts speakers
//			//camRig.transform.Translate(0.0f, 1.44f, 0.0f); // y=1.44 is where GameController puts speakers
//			break;
//		case "ON":
//			// The following enables transalation of user (Unity 5.6+)
//			InputTracking.disablePositionalTracking = false;
//			var camRig2 = FindObjectOfType<SteamVR_ControllerManager>();
//			camRig2.transform.localPosition = new Vector3(0.0f, 0.0f, 0.0f); // y=1.44 is where GameController puts speakers
//			//camRig2.transform.Translate(0.0f, -1.44f, 0.0f); // y=1.44 is where GameController puts speakers
//			break;
//		}
//		myNetwork.SendToServer(Time.time.ToString("F4") + "\tHEAD TRANSLATION " + mode);
//
//	}
//
	// from VR Test Project 4:
	public void LatchHeadPos(bool force = false) // store the head position for reading later
	{
		// the logic: don't reset a previously latched headPos unless told to force it
		if (force | !latched) {
			latched = true;
			headAngle = headTrans.eulerAngles;
			headPos = headTrans.position;
			//Debug.Log("x " + headAngle.x.ToString() + " y " + headAngle.y.ToString() + " z " + headAngle.z.ToString());

			// transform to upward elevation
			headAngle.x *= -1;
			if (headAngle.x > 180)
				headAngle.x = headAngle.x - 360;
			if (headAngle.x < -180)
				headAngle.x = headAngle.x + 360;

			// transform to rightward azimuth
			if (headAngle.y < -180)
				headAngle.y = headAngle.y + 360;
			if (headAngle.y > 180)
				headAngle.y = headAngle.y - 360;

			// transform to clockwise roll
			headAngle.z *= -1;
			if (headAngle.z > 180)
				headAngle.z = headAngle.z - 360;
			if (headAngle.z < -180)
				headAngle.z = headAngle.z + 360;
		}
	}


	public void ReportHeadPos(string mode = "ALL") // tell the server where the head was at latch
	{
		switch (mode)
		{
		case "ALL":
			myNetwork.SendToServer(Time.time.ToString("F4") + "\tHEAD\t"
				+ headPos.ToString() + "\t"
				+ headAngle.ToString());
			break;
		case "AZIM":
			myNetwork.SendToServer(Time.time.ToString("F4") + "\tHEAD\t"
				+ "AZIM\t" + headAngle.y.ToString());
			break;
		case "ELEV":
			myNetwork.SendToServer(Time.time.ToString("F4") + "\tHEAD\t"
				+ "ELEV\t" + headAngle.x.ToString());
			break;
		}
	}


	public void ReadHeadPos(string mode = "ALL")
	{
		LatchHeadPos(true);  // force the latch because we want to read it right now
		ReportHeadPos(mode);
	}


	public void TrigHeadPos(string mode = "ALL")
	{
		latched = false;  // clear the latch
		StartCoroutine(TriggerWait(mode)); // Wait for a trigger pull
	}


	// this just waits for a trigger pull
	public IEnumerator TriggerWait(string mode = "ALL")
	{
		while (!latched)
		{
			yield return 0; // keep waiting
		}
		// I presume we arrive here once latched is true
		if (latched)
		{
			ReportHeadPos(mode);
		}
	}


}
