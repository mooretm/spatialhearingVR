using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement; // need this to access SceneManager

public class helpManager : MonoBehaviour 
{

	public void changeScene(string sceneName)
	{
		SceneManager.LoadScene (sceneName); 
	}

}
