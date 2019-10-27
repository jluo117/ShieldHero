using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase;
using Firebase.Database;
using Firebase.Unity.Editor;

public class SpawnObj : MonoBehaviour
{
    private float updateTime = 5.0f;
    private float timerInt = 3.0f;
    private bool playing = true;
    private float randAddTime = 3.0f;
    private List<float> xCord = new List<float>(); //x ranges from -330 to 330
    private List<float> yCord = new List<float>(); //y ranges from -640 to 640
    public GameObject[] objList;
    private int randObj, randZ;

    // Start is called before the first frame update
    void Start()
    {
        FirebaseApp.DefaultInstance.SetEditorDatabaseUrl("https://dodgemonster.firebaseio.com/");
        
        //Debug.Log(objList.Length);
    }

    // Update is called once per frame
    void Update()
    {
        if (!playing)
        {
            return;
        }
        updateTime -= Time.deltaTime;
        timerInt -= Time.deltaTime;
        randAddTime -= Time.deltaTime;
        
        if (updateTime <= 0)
        {
            pullFromDataBase();
            updateTime = 5f;
        } 
        
        if (timerInt <= 0)
        {
            spawnObjects();
            timerInt = 3f;
        }
        
        if (randAddTime <= 0)
        {
            randAdd();
            randAddTime = 3f;
        }
    }
    private void pullFromDataBase()
    {
        this.xCord.Clear();
        this.yCord.Clear();
        FirebaseDatabase.DefaultInstance.GetReference("Object").GetValueAsync().ContinueWith(task =>
        {
            DataSnapshot snapshot = task.Result;
            DataSnapshot xCordSnap = snapshot.Child("X");
            for (int i =0; i < xCordSnap.ChildrenCount; i++)
            {
                string curNode = i.ToString();
                string FoundValue = xCordSnap.Child(curNode).Value.ToString();
                float newCord = float.Parse(FoundValue);
              //  Debug.Log(newCord);
                xCord.Add(newCord);
            }
            DataSnapshot yCordSnap = snapshot.Child("Y");
            for (int i = 0; i < yCordSnap.ChildrenCount; i++)
            {
                string curNode = i.ToString();
                string FoundValue = yCordSnap.Child(curNode).Value.ToString();
                float newCord = float.Parse(FoundValue);
              //  Debug.Log(newCord);
                yCord.Add(newCord);
            }
        });
    }
    public void stopGame()
    {
        playing = false;
        xCord.Clear();
        yCord.Clear();
    }
    public void startGame()
    {
        playing = true;
        pullFromDataBase();
        updateTime = 5f;
        spawnObjects();
        timerInt = 3f;
        randAdd();
        randAddTime = 3f;
    }
    private void spawnObjects()
    {
        //18 <= z <= -18, 18 <= x <= -18
        //x ranges from -360 to 360, y ranges from -640 to 640
        // x by factor of 20, y by factor of
        // 640 / 18 =  320 / 9
        randZ = Random.Range(10, 18);
        randObj = Random.Range(0, objList.Length - 1);
        //Debug.Log(xCord.Count + " " + yCord.Count);
        
        if (xCord.Count > 0 && yCord.Count > 0)
        {
            //Debug.Log(xCord[0] + " " + yCord[0]);
            Vector3 newPos = new Vector3(xCord[0] / 20, randZ, yCord[0] * 9 / 320);
            GameObject newObj = Instantiate(objList[randObj], newPos, Quaternion.identity);
             
            xCord.Remove(0);
            yCord.Remove(0);
            Debug.Log(newPos);
        }
        
    }

    private void randAdd()
    {
        int rX, rY;
        rX = Random.Range(-360, 360);
        rY = Random.Range(-640, 640);
        xCord.Add(rX);
        yCord.Add(rY);
    }

}
