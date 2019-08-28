using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class inflate : MonoBehaviour {

	public float maxSize;
	public float speed;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown (KeyCode.I)) {
			StartCoroutine (Scale ());
		}
	}

		IEnumerator Scale()
	{
		float timer = 0;
		//while (true) {
			while (maxSize > transform.localScale.x) {
				timer += Time.deltaTime;
			transform.localScale += new Vector3(1,0,1) * Time.deltaTime * speed;
				yield return null;
			}
	}

	}