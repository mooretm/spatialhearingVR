using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArenaController : MonoBehaviour {

	public NetworkController myNetwork;

	// these are from fancyPopulate
	public int numPoints = 20; // number of prefabs to place
	public GameObject balloonPrefab;// was public GameObject prefabObject; // empty game object to load with prefab
	public float radiusX,radiusY; // radii for x and y axes
	public bool isCircular = false; // complete circle?
	public bool vertical = true; // elevation or azimuth?
	public float prefabHeight = 10; // height of the objects above the ground
	public float textureRotate = 90f;
	Vector3 pointPos; // position for each prefab

	List<BalloonController> balloonClones = new List<BalloonController>();

	// Use this for initialization
	void Start () {
		Repopulate();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	public void SetTerrain(string msg = "TOG") {
		var myTerrain = GameObject.Find("myTerrain").GetComponent<Terrain>();
		var curstate = myTerrain.enabled;
		var newstate = new bool();

		switch (msg)
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
		myNetwork.SendToServer(Time.time.ToString("F4") + "\tTERRAIN " + msg);
		myTerrain.enabled = newstate;
	}


	public void SetFloor(string msg = "TOG") {
		var myFloor = GameObject.Find("arenaFloor").GetComponent<Renderer>();
		var curstate = myFloor.enabled;
		var newstate = curstate; // default to keep it on or off

		switch (msg)
		{
		case "BRICK":
			myFloor.material = Resources.Load ("brickWall") as Material;
			break;
		case "WATER":
			myFloor.material = Resources.Load ("WaterBasicDaytime") as Material;
			break;
		case "CHECK":
			myFloor.material = Resources.Load ("DefaultCheck") as Material;
			break;
		case "ON":
			newstate = true;
			break;
		case "OFF":
			newstate = false;
			break;
		case "TOG":
			newstate = !curstate;
			break;
		default:
			newstate = !curstate;
			break;
		}
		myNetwork.SendToServer(Time.time.ToString("F4") + "\tFLOOR " + msg);
		myFloor.enabled = newstate;
	}


    // Updated 8/23/17 for A/V latency testing. See note in NetworkController.cs
    public void SetLatencyTestObj(string msgColor = "BLACK", string msgType = "AV")
    {
        var myScreen = GameObject.Find("latencyTestObj").GetComponent<Renderer>();
        AudioSource tone = myScreen.GetComponent<AudioSource>();

        if (msgType == "A")
        {
            tone.Play();
        }
        else if (msgColor == "WHITE")
        {
            switch (msgType)
            {
                case "V":
                    myScreen.material.color = new Color32(255, 255, 255, 255);
                    break;
                case "AV":
                    tone.Play();
                    myScreen.material.color = new Color32(255, 255, 255, 255);
                    break;
            }
        }
        else if (msgColor == "BLACK")
        {
            switch (msgType)
            {
                case "V":
                    myScreen.material.color = new Color32(0, 0, 0, 255);
                    break;
                case "AV":
                    tone.Play();
                    myScreen.material.color = new Color32(0, 0, 0, 255);
                    break;
            }
        }

        myNetwork.SendToServer(Time.time.ToString("F4") + "\tLATENCY_TEST" + msgColor);
        myScreen.enabled = true;
    }
		

	public void Respawn () {
		// instead of looping through balloon names, this uses the list balloonClones
		foreach (BalloonController theBalloon in balloonClones) {

			if (theBalloon.clicked == 1) 
			{
				Debug.Log ("Respawn called");
				theBalloon.Reappear ();
				GetComponent<AudioSource> ().Play (); // was respawnAudio.Play(); // should this sound belong to the balloon itself?
			}
		}
	}


	public void Clear (string mode = "ALL") {
		//Actually destroy some balloons
		Debug.Log("Clear " + mode);
		switch (mode) {
			case "ALL":
				foreach (BalloonController theBalloon in balloonClones)
					Destroy (theBalloon.gameObject);
				balloonClones.Clear();
				break;
			default: // they sent us an angle
				Destroy (GetBalloonAtAngle (float.Parse (mode)).gameObject);
				break;
		}
	}


	public void Repopulate() {
		// this is from fancyPopulate
			GetComponent<AudioSource> ().Play (); // was sndAppear.Play ();
		// here we just make an array of angles and ask for new balloons at each
		string theColor = "red";
		bool theMode = true; // restoreOnly or not? 

		for (float angle = 0f; angle < 360f; angle += 1.0f) { // be careful of the sphere collider!
			// NewBalloon() does the actual instantiation, etc. 
			BalloonController myBalloon = NewBalloon (
				                              angle, 
				                              "Balloon_" + ((int)angle).ToString (),
				                              theMode,
				                              theColor);		
			// do this from matlab if you really want to:
//			if (angle == 0)
//				myBalloon.SetColor (Color.green);
		}
	}

		// don't do this anymore. can do it by making the balloons in matlab instead.
	IEnumerator StepPopulate() {
		// here we just make an array of angles and ask for new balloons at each
		string theColor = "red";
		bool theMode = true; // restoreOnly or not? 

		for (float angle = 0f; angle< 360f; angle += 1.0f) { // be careful of the sphere collider!
			// NewBalloon() does the actual instantiation, etc. 
			BalloonController myBalloon = NewBalloon (
				angle, 
				"Balloon_" + ((int)angle).ToString(),
				theMode,
				theColor);

			if (angle==0) 
				myBalloon.SetColor(Color.green);
//			else
//			myBalloon.SetColor(Color.Lerp (Color.red, Color.blue, pointNum));

			yield return new WaitForSeconds(0.0f);
		}

		// keeps radius on both axes the same if circular
		if (isCircular) {
			radiusY = radiusX;
		}

		//sndAppear.Play ();
	}


	// this public method can be called any time to make a new balloon at any angle...
	public BalloonController NewBalloon(float angle, string name = "Balloon_XX", bool restoreOnly = false, string theColorName = "red")
	{
		// Note that balloon array is centered on transform.position (of the Arena)
		Vector3 center = transform.position; // make Arena the center of the circle (must drag script to Player)

		// make a local copy of the prefab to work from 
		GameObject sourceBalloon = balloonPrefab;
		// thus we can set some of the behavior before implementing.
		// for example, restoreOnly must be set _before_ OnEnable()
		// so set it here, before instantiating later
		sourceBalloon.GetComponent<BalloonController>().restoreOnly = restoreOnly;
		sourceBalloon.GetComponent<BalloonController> ().angle = angle;

		// we need radians for Sin and Cos...
		float radAngle = (angle/360f) * (2f * Mathf.PI);

		float x = Mathf.Sin (radAngle) * radiusX;
		float y = Mathf.Cos (radAngle) * radiusY;

		// position for the prefab
		if (vertical)
			pointPos = new Vector3 (x, y) + center;
		else if (!vertical) {
			pointPos = new Vector3 (x, prefabHeight, y) + center;
		}
			
		// place prefab at position
		//GameObject go = (GameObject) Instantiate (prefabObject, pointPos, Quaternion.identity,transform);
		// this controls the rotation of the prefabs, so the player is always seeing the same surface
		// useful with images instead of solid colors

		// OK, I get it, but we can do this without stepping a global variable deg?
		//		the rotation should be equal to the angle itself, in degrees, 
		//		plus fixed offset of 90 degrees that relates to the texture geometry 
		float ballRot = angle + textureRotate;

		GameObject go = (GameObject)Instantiate(
			sourceBalloon, 
			pointPos, 
			Quaternion.Euler(0,ballRot,0), 
			transform);

		go.name = name;

		go.GetComponent<BalloonController> ().SetColor (theColorName);

		balloonClones.Add (go.GetComponent<BalloonController>());

		return go.GetComponent<BalloonController>();
	}


	public BalloonController  GetBalloonAtAngle(float balloonAngle) 
	{
		//return balloonClones [0]; // for starters just give me the first one
		// map to 0..360 degrees
		while (balloonAngle < 0f)
			balloonAngle += 360f;

		while (balloonAngle >= 360f)
			balloonAngle -= 360f;
		
		return balloonClones.Find (x => Mathf.Round(x.angle) == Mathf.Round(balloonAngle));
	}

}
