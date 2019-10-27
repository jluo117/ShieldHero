using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase;
using Firebase.Database;
using Firebase.Unity.Editor;
public class ShieldGen : MonoBehaviour
{
    bool shieldOn = true;
    private float sTimer = 3f;
    private int NewTon = 0;
    private int nextWeight = 500;
    private int score = 0;
    public GameObject scoreBoard;
    // Start is called before the first frame update
    void Start()
    {
        getNewTon();
        toggleShield();
        //shieldOn = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (shieldOn)
        {
            sTimer -= Time.deltaTime;
            if (sTimer <= 0)
            {
                toggleShield();
            } 
        }
    }

    public int getScore()
    {
        return score;
    }
    public void resetScore()
    {
        score = 0;
        NewTon = 0;
    }
    private void OnTriggerEnter(Collider other)
    {
       
        // Debug.Log("Collided");
        if (other.gameObject.tag != "Player")
        {
                Destroy(other.gameObject);
            if (shieldOn)
            {
                score += 2;
            }
            else
            {
                score++;
            }
                 
        }
        

    }
    private void getNewTon()
    {
        FirebaseDatabase.DefaultInstance.GetReference("Newton").ValueChanged += HandleValueChange;
    }
    void HandleValueChange(object sender, ValueChangedEventArgs args)
    {
        if (args.DatabaseError != null)
        {
            return;
        }
        if (shieldOn)
        {
            return;
        }
        DataSnapshot myChange = args.Snapshot;
        string strData = myChange.Value.ToString();
        NewTon += int.Parse(strData);
// Debug.Log(NewTon);
        if (NewTon > nextWeight){
            toggleShield();
            NewTon = 0;
            sTimer = 5f;
            nextWeight += 350;
            Debug.Log("power up");

        }
    }
    private void toggleShield()
    {
        if (shieldOn)
        {
            shieldOn = false;
            this.transform.localScale = new Vector3(.25f, .25f, .25f);
        }
        else
        {
            shieldOn = true;
            this.transform.localScale = new Vector3(2f, 2f, 2f);
            
        }
    }
}
