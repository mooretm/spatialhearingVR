using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class clickToVanish : MonoBehaviour {

	public GameObject explosion;
	public AudioSource gunShot;
	public int clicked = 0;

	public void Vanish() 
	{
		clicked = 1;
		Instantiate (explosion, transform.position, transform.rotation);
		gunShot.Play ();
		Renderer[] rs = GetComponentsInChildren<Renderer> ();
		foreach (Renderer r in rs)
		r.enabled = false;

		//Destroy (gameObject, gunShot.clip.length);
	}
		
	//IEnumerator shoot() {
	//	gunShot.Play ();
	//	yield return new WaitForSeconds(gunShot.clip.length);
	//	Instantiate (explosion, transform.position, transform.rotation);
	//	Destroy (gameObject, gunShot.clip.length);
	//}


	public void balloonBob()
	{
		GetComponent<Rigidbody> ().AddForce (0, -300, 0);
	}




}