using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BalloonController : MonoBehaviour {

	public GameObject explosion;
	//public AudioSource gunShot;

	// for tracking the balloon parameters
	public float angle;
	public int clicked = 0;
	public Vector3 originalPosition;

	// for controlling the balloon behavior
	// restoreOnly means to implement restoring force that returns the balloon to 
	// originalPosition (following Hooke's law). Leave false to use "gravity" instead
	public float restoreForce = 8f;
	public bool restoreOnly = false;

	void OnEnable() 
	{
		originalPosition = transform.position;

		if (restoreOnly) 
		{
			// in this case we will use the restoring force to return to 
			// original position, rather than inverse gravity w/ceiling
			// here I'm setting up the behavior to override the prefab settings
			restoreForce = 8f;
			GetComponent<Rigidbody>().useGravity = false;
			GetComponent<Rigidbody>().mass = 0.5f;
			GetComponent<Rigidbody> ().drag = 2.0f;
			GetComponent<SphereCollider> ().isTrigger = true;
		}
	}


	void Update()
	{
		if (restoreOnly) {// Here is an example of maintaining position without using ceiling
			// set restoreForce around 2.0 and Rigidbody Drag around 1.0, turn gravity off. 
			GetComponent<Rigidbody> ().AddForce (restoreForce * (originalPosition - transform.position));
		}
		// But it doesn't emulate the string in the same as your upside down gravity...
	}


	public void Vanish() // should this be called "BalloonPop"?
	{
		clicked = 1;
		Instantiate (explosion, transform.position, transform.rotation);
		GetComponent<AudioSource> ().Play (); // was gunShot.Play (); // should this sound belong to the gazecontroller?
		Renderer[] rs = GetComponentsInChildren<Renderer> ();
		foreach (Renderer r in rs)
		r.enabled = false;
		GetComponent<SphereCollider> ().enabled = false;

		//Destroy (gameObject, gunShot.clip.length);
	}
		

	public void Reappear() // should this be called "BalloonPop"?
	{
		clicked = 0;
		Renderer[] rs = GetComponentsInChildren<Renderer> ();
		foreach (Renderer r in rs)
			r.enabled = true;
		GetComponent<SphereCollider> ().enabled = true;
	}


	// apply a force, downward by default but in any direction for restoreOnly mode
	public void BalloonBob(float x = 0, float z = 0)
	{
		// x is toward player, z is side to side? 
		Vector3 forceDir = Vector3.down; // default is down
		float forceMult = 300;

		if (restoreOnly) {
			// this balloon can handle displacement in any direction
			// x and z come from padX and padY respectively
			// apply force in a direction corresponding to the pad...sort of
				
			//forceDir = new Vector3 (-x, 0f, -z);// this would work except Travis' balloons are rotated 90 deg for some reason
			forceDir = new Vector3 (z, 0f, -x);
			forceDir = transform.TransformDirection (forceDir); 
			forceDir.y = -(1.0f - forceDir.magnitude); // down if not clicking in x/z
				Debug.Log(forceDir.ToString());
		} 
		GetComponent<Rigidbody> ().AddForce (forceDir * forceMult);
	}


	// set the color of a balloon with a string
	public void SetColor(string theColorName) {
		Color theColor = (Color)typeof(Color).GetProperty (theColorName.ToLowerInvariant ()).GetValue (null, null);
		SetColor (theColor);
	}


	// set the color of a balloon with a color (or a Vector4 perhaps?)
	public void SetColor(Color theColor) {
		GetComponent<Renderer> ().material.color = theColor;
	}


}