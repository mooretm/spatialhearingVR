using System.Collections;
using System.Collections.Generic;
using System;
using System.Text.RegularExpressions;


using UnityEngine;

// simple test of TCP/IP socket communication (i.e. with MATLAB)
//
//got some of this from leedilaav at 
// https://girlscancode.wordpress.com/2014/08/27/unity3d-and-tcpip-socket-connections

// In matlab, invoke a TCP socket server as:
// t = tcpip('0.0.0.0',4012,'NetworkRole','server'); % accept from any IP, port 4012
// fopen(t);  % will block until a connection is made
//
// fwrite(t,'Hello from Matlab!'); % will show in unity console
// fgetl(t); % will return next message sent via GUI or Fire button

public class NetworkController : MonoBehaviour
{
    //variables
    private TCPConnection myTCP;

    public GazeController myPlayer;
	public ArenaController myArena;
    public HomeBoxController homeBox;
	public HeadController myHeadController;

    //private double btnZ;
    //private double btnX;
    private double btnCountLeft;
    private double btnCountRight;
	private int loopStatus;

    private string serverMsg;
    public string msgToServer;
	    
	//public string conHost = "192.168.1.201"; // This is for the lab mac mini
	public string conHost = "127.0.0.1"; // localhost for any machine
    public string conPort = "4012";


    void Awake()
    {
        //add a copy of TCPConnection to this game object
        myTCP = gameObject.AddComponent<TCPConnection>();
    }


    void Update()
    {
        //keep checking the server for messages, if a message is received from 
		//    server, log it in the Debug console (see function below)
        SocketResponse();

        if (Input.GetKeyDown(KeyCode.Q))
        {
            SendToServer("QUIT");
            SendToServer(Time.time.ToString());
            myTCP.closeSocket();
        }
    }


    void OnGUI()
    {
        //if connection has not been made, display button to connect
        if (myTCP.socketReady == false)
        {
            //Note need to update this to allow editing server IP
            GUILayout.TextArea("In Matlab: t=tcpip('0.0.0.0',4012,'Networkrole','server'); fopen(t);");
            GUILayout.Label("Host IP:");
            conHost = GUILayout.TextField(conHost);
            GUILayout.Label("Host Port:");
            conPort = GUILayout.TextField(conPort);

            if (GUILayout.Button("Connect"))
            {
                // set the host params
                myTCP.conHost = conHost;
                myTCP.conPort = int.Parse(conPort);

                //try to connect
                Debug.Log("Attempting to connect..");
                myTCP.setupSocket();
            }
        }

        //once connection has been made, display editable text field with a button to send that string to the server (see function below)
        if (myTCP.socketReady == true)
        {
            // msgToServer = GUILayout.TextField(msgToServer);
            // if (GUILayout.Button("Write to server", GUILayout.Height(30)))
            // {
            //     SendToServer(msgToServer);
            // }
        }
    }


    //socket reading script...parse this for commands to game or player
    void SocketResponse()
    {
        if (myTCP.socketReady == true)
        {
            string tcpMsg = myTCP.readSocketLine();
            char[] splitters = { '\r', '\n', ' ' };

            tcpMsg.TrimEnd(splitters);

            //tcpMsg.Replace('\r', ''); tcpMsg.Replace('\n', '');
            if (tcpMsg != "")
            { 
                string[] msgWords = tcpMsg.Split(splitters);
 
                //for (int i = 0; i < msgWords.Length; i++)
                //{
                //    Debug.Log(i.ToString() + ": " + msgWords[i] + " length " + msgWords[i].Length.ToString());
                //}

                var numWords = msgWords.Length;
                if (msgWords[0].Trim() != "HOMECHECK")
                {
                    Debug.Log("[SERVER (Message length: " + numWords.ToString() + "/" + tcpMsg.Length.ToString() + ")] " + tcpMsg);
                }


//*****************************************************************************************
//************* This is where we start processing custom commands from matlab *************
//*****************************************************************************************
                switch (msgWords[0].Trim())
                {
				case "READTIME": // just report the time
					SendToServer(Time.time.ToString("F4") + "\tREADTIME");
					break;
//				case "FEEDBACK":
//					//SendToServer(Time.time.ToString("F4") + "\tEntered TARG case of switch in NetworkSocket.SocketResponse");
//					switch (numWords) // split always leaves an extra word (new line?)
//					{
//					case 1: // no args? use correct at default az (0), default dist and dur
//						myGame.Feedback(true);
//						break;
//					case 2: // given correct 
//						myGame.Feedback(bool.Parse(msgWords[1]));
//						break;
//					case 3: // given correct and az
//						myGame.Feedback(bool.Parse(msgWords[1]), float.Parse(msgWords[2]));
//						break;
//					case 4: // given correct, az, dist
//						myGame.Feedback(bool.Parse(msgWords[1]), float.Parse(msgWords[2]), float.Parse(msgWords[3]));
//						break;
//					case 5: // given correct, az, dist, dur
//						myGame.Feedback(bool.Parse(msgWords[1]), float.Parse(msgWords[2]), float.Parse(msgWords[3]), float.Parse(msgWords[4]));
//						break;
//					default:
//						SendToServer(Time.time.ToString("F4") + " HIT DEFAULT CASE!");
//						break;
//					}
//					break;
				case "TARG":
                        //SendToServer(Time.time.ToString("F4") + "\tEntered TARG case of switch in NetworkSocket.SocketResponse");
                        switch (numWords) // split always leaves an extra word (new line?)
                        {
	                            case 1: // no args? use random az and dist
									myArena.NewBalloon(0f); 
	                                break;
	                            case 2: // given az
									myArena.NewBalloon(float.Parse(msgWords[1])); 
	                                break;
	                            case 3: // given az and name
									myArena.NewBalloon(float.Parse(msgWords[1]), msgWords[2]); 
							        break;
								case 4: // given az, name, mode
									myArena.NewBalloon(float.Parse(msgWords[1]),
											(msgWords[2]), bool.Parse(msgWords[3]));
									break;
								case 5: // given az, name, mode, color
									myArena.NewBalloon(float.Parse(msgWords[1]),
										msgWords[2], bool.Parse(msgWords[3]), msgWords[4]);
									break;
								default:
	                                SendToServer(Time.time.ToString("F4") + " HIT DEFAULT CASE!");
	                                break;
	                    }
                        break;
				case "BOB":
					switch (numWords) { // split always leaves an extra word (new line?)
					case 2: // given az
						myArena.GetBalloonAtAngle (float.Parse (msgWords [1])).BalloonBob (); 
						SendToServer(Time.time.ToString("F4") + " BOB " + msgWords[1]);
						break;
					case 4: // given az, x  z
						myArena.GetBalloonAtAngle (float.Parse (msgWords [1])).BalloonBob (
							float.Parse (msgWords [2]),
							float.Parse (msgWords [3])); 
						SendToServer(Time.time.ToString("F4") + " BOB " + msgWords[1] +
							" " + msgWords[2] + " " + msgWords[3]);

						break;
					default:
						Debug.Log ("Error: tried to bob balloon with incorrect args");
						break;
					}
					break;
				case "VANISH":
						myArena.GetBalloonAtAngle(float.Parse(msgWords[1])).Vanish(); 
						SendToServer(Time.time.ToString("F4") + " VANISH " + msgWords[1]);

					break;
				case "COLOR":
					myArena.GetBalloonAtAngle(float.Parse(msgWords[1])).SetColor(msgWords[2]); 
					SendToServer(Time.time.ToString("F4") + " COLOR " 
						+ msgWords[1] + " " + msgWords[2]);

					break;
//                case "HEADTRANS":
//                        myPlayer.ToggleHeadTranslation(msgWords[1]); // ON or OFF
//                        break;
				case "CLEAR":
					myArena.Clear(msgWords[1]); 
					SendToServer(Time.time.ToString("F4") + " CLEAR " + msgWords[1]);

					break;
				case "RESPAWN":
					myArena.Respawn ();
					SendToServer(Time.time.ToString("F4") + " RESPAWN");
					break;
				case "REPOPULATE":
					myArena.Repopulate ();
					SendToServer(Time.time.ToString("F4") + " REPOPULATE");
					break;
				case "GAZE":
					myPlayer.ToggleGaze(msgWords[1]); // ON or OFF
					break;
				case "ARMDISPLAY":
					myPlayer.ToggleArmDisplay(msgWords[1]); // ON or OFF
					break;
				case "TERRAIN":
					myArena.SetTerrain(msgWords[1]); // ON or OFF
					break;
				case "FLOOR":
					myArena.SetFloor(msgWords[1]); // BRICK, WATER, CHECK, OFF
					break;
                // Update 8/23/17
                // Functionality for audio/visual latency checking.
                //      Must be used with scene "latencyCheck", which contains
                //      a cube (latencyTestObj) that fills the camera view. 
                //      This test is designed for use with a photoresistor in 
                //      the VR goggles to indicate the change in object color.
                case "LATENCY_TEST":
                        myArena.SetLatencyTestObj(msgWords[1], msgWords[2]); // BLACK, WHITE
                    break;
				
				// Update 1/30/18
				// Used to collect the number of button presses to adjust
				//     stimuli during method of adjustment task.
				case "CLICK_COUNT":
                        btnCountLeft = myPlayer.btnCounterLeft;
                        btnCountRight = myPlayer.btnCounterRight;

                        Debug.Log(btnCountLeft + " " + btnCountRight);
                        SendToServer(btnCountLeft.ToString() + " " + btnCountRight.ToString());
                        myPlayer.btnCounterLeft = 0;
                        myPlayer.btnCounterRight = 0;

					//btnZ = myHeadController.btnCounterZ;
					//btnX = myHeadController.btnCounterX;

					//Debug.Log (btnZ + " " + btnX);
					//SendToServer (btnZ.ToString () + " " + btnX.ToString());

					//myHeadController.btnCounterZ = 0;
					//myHeadController.btnCounterX = 0;
					break;


				case "CHECK_LOOP":
                        //loopStatus = myHeadController.END;
                        loopStatus = myPlayer.END;
					SendToServer (loopStatus.ToString());
					break;

                    case "RESETEND":
                        loopStatus = 0;
                        myPlayer.END = 0;
                        break;

//                    case "LINE":
//                        myGame.ShowLines(msgWords[1]); // NONE, I, +, x, or *
//                        break;
//                    case "WALL":
//                        myGame.ShowWalls(msgWords[1]); // '' 'FG' etc.
//                        break;
//                    case "CHAIR":
//                        myGame.ShowChair(msgWords[1]); // NONE, I, +, x, or *
//                        break;
//                    case "PANO":
//                        myGame.ShowPanoSphere(msgWords[1]); // '' 'FG' etc.
//                        break;
//                    case "PANOSCALE":
//                        myGame.ScalePanoSphere(msgWords[1]); // '' 'FG' etc.
//                        break;
//                    case "SPK":
//                        myGame.ShowSpeakers(msgWords[1]); // 'NONE' '*' 'ALL' etc.
//                        break;
                    case "HOMECHECK":  // sever is asking if ready to continue
                                       // send a series of messages
										// make this conform to standard gametime CMD boxtim
     					SendToServer(Time.time.ToString("F4") + "\tHOMECHECK\t" + homeBox.timeInBox.ToString("F4"), false); 			          
                        break;
                    case "HOMEBOX":
                        homeBox.boxEnabled = (msgWords[1].Trim() == "ON");
                        SendToServer(Time.time.ToString("F4") + "\tHOMEBOX\t" + msgWords[1]);

                        break;
				case "READHEAD":
					switch (numWords)
					{
					case 1:
						myPlayer.ReadHeadPos();
						break;
					case 2:
						myPlayer.ReadHeadPos(msgWords[1]);
						break;
					}
					break;
				case "TRIGHEAD":
					switch (numWords)
					{
					case 1:
						myPlayer.TrigHeadPos();
						break;
					case 2:
						myPlayer.TrigHeadPos(msgWords[1]);
						break;
					}
					break;
				default:
                        Debug.Log("[SERVER (Message length: " + numWords.ToString() + "/" + tcpMsg.Length.ToString() + ")] " + tcpMsg);
                        for (int i = 0; i < numWords; i++)
                        {
                            Debug.Log(i.ToString() + ": " + msgWords[i]);
                        }
                        break;

                }
            }
        }
    }

    //send message to the server
    public void SendToServer(string str, bool logDebug = true)
    {
        myTCP.writeSocket(str);
        if (logDebug)
        {
            Debug.Log("[CLIENT] -> " + str);
        }
    }

 
}