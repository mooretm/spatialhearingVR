using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// this is a script Chris wrote to register for and handle click events

public class TouchController : MonoBehaviour {

    private SteamVR_TrackedController myController;
    public GazeController myGazeController;

    private void OnEnable()
    {
        myGazeController = GameObject.Find("GazeController").GetComponent<GazeController>(); 

        myController = GetComponent<SteamVR_TrackedController>();
        myController.TriggerClicked += HandleTriggerClicked;
        myController.PadClicked += HandlePadClicked;
		myController.MenuButtonClicked += HandleButtonClicked; // add menu button
        myController.Gripped += HandleGripped;
    }

    private void OnDisable()
    {
        myController.TriggerClicked -= HandleTriggerClicked;
        myController.PadClicked -= HandlePadClicked;
		myController.MenuButtonClicked -= HandleButtonClicked; // remove menu button
        myController.Gripped -= HandleGripped;
    }


    private void HandleTriggerClicked(object sender, ClickedEventArgs e)
    {
        //Debug.Log("Trigger click: " + sender.ToString() + " " + e.ToString());

        // User pulled the trigger. Let's do something!
        // Actually, let the gaze controller handle it
        myGazeController.HandleTriggerPull();
    }

    private void HandlePadClicked(object sender, ClickedEventArgs e)
    {
		//Obsolete: Bob is now initiated from MATLAB
		//Debug.Log("Pad click: " + sender.ToString() + " " + e.ToString());
		myGazeController.HandlePadPress (e.padX,e.padY);
    }

	private void HandleButtonClicked(object sender, ClickedEventArgs e)
	{
        //Obsolete: Respawn is initiated from MATLAB
        //Debug.Log ("Menu click: " + sender.ToString () + " " + e.ToString ());
        //myGazeController.HandleButtonPress (e.controllerIndex);
        myGazeController.HandleButtonPress(sender);
    }

    private void HandleGripped(object sender, ClickedEventArgs e)
    {
        //Obsolete: Respawn is initiated from MATLAB
        //Debug.Log ("Menu click: " + sender.ToString () + " " + e.ToString ());
        //myGazeController.HandleGripDown(e.controllerIndex);
        myGazeController.HandleGripDown(sender);
    }



    }
