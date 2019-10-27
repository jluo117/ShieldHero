using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Firebase;
using Firebase.Database;
using Firebase.Unity.Editor;

public class UIBoard : MonoBehaviour
{
    // Start is called before the first frame update

    public Text yourScore;
    public Text timeLeft;
    public Text highScore;
    public GameObject shield;
    public GameObject spawnSys;
    private int pullScored = 0;
    public int currentScore = 0;
    private float startTime = 90f;
    private float currTime;
    private bool gameOver = false;

    void Start()
    {
        

        highScore.text = "0";
        FirebaseApp.DefaultInstance.SetEditorDatabaseUrl("https://dodgemonster.firebaseio.com/");
        getHightScore();
        currTime = startTime;
        timeLeft.text = "Time left: \n" + startTime.ToString() + " sec";
    }

    // Update is called once per frame
    void Update()
    {
        if (gameOver)
        {
            if (Input.GetKeyDown("r"))
            {
                currentScore = 0;
                
                currTime = startTime;
                gameOver = false;
                shield.GetComponent<ShieldGen>().resetScore();
                spawnSys.GetComponent<SpawnObj>().startGame();
            }
            return;
        }
        currTime -= Time.deltaTime;
        int timeInt = (int)currTime;
        timeLeft.text = "Time left: \n" + timeInt.ToString() + " sec";
        if (currTime <= 0)
        {
            gameover();
        }

        currentScore = shield.GetComponent<ShieldGen>().getScore();
        yourScore.text = "Score: " + currentScore.ToString();
    }

    private void gameover()
    {
        spawnSys.GetComponent<SpawnObj>().stopGame();
        gameOver = true;
        if (pullScored < currentScore)
        {
            DatabaseReference reference = FirebaseDatabase.DefaultInstance.RootReference.Child("Score");
            reference.SetValueAsync(currentScore);
            pullScored = currentScore;
            highScore.text = currentScore.ToString();
        }
    }
    private void getHightScore()
    {
        FirebaseDatabase.DefaultInstance.GetReference("Score").GetValueAsync().ContinueWith(task =>
        {
            if (task.IsFaulted)
            {
                return;
            }
            else if (task.IsCompleted)
            {
                DataSnapshot snapshot = task.Result;
                highScore.text = snapshot.Value.ToString();
                pullScored = int.Parse(snapshot.Value.ToString());
            }
        }
               
        );


    }
}
