using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase;
using Firebase.Database;
using Firebase.Unity.Editor;
public class SphereSpeed : MonoBehaviour
{
    public GameObject player1;
    protected Vector3 toPlayer;
    public Vector3 initPos;
    private float change = 30;
    private float speed = 0.3f;
    private string objName;
    // Start is called before the first frame update
    void Start()
    {
       
        FirebaseApp.DefaultInstance.SetEditorDatabaseUrl("https://dodgemonster.firebaseio.com/");
        toPlayer = player1.transform.position - this.transform.position;
        initPos = this.transform.position;
        this.gameObject.tag = "Sphere";
        getSpeed();
    }
    
    // Update is called once per frame
    void Update()
    {
        getSpeed();
        speed = (1 * (change / 100));
        /*if (initPos.y < 0)
        {
            initPos.y = -initPos.y;
        }*/
        this.transform.position += (speed * toPlayer * Time.deltaTime);
        this.transform.Rotate(toPlayer);
    }
    void DestroyObjectDelayed()
    {
        Destroy(this, 10);
    }
    private void getSpeed()
    {
        FirebaseDatabase.DefaultInstance.GetReference("Speed").ValueChanged += HandleValueChange;
    }
    void HandleValueChange(object sender, ValueChangedEventArgs args)
    {
        if (args.DatabaseError != null)
        {
            return;
        }
        DataSnapshot myChange = args.Snapshot;
        string strData = myChange.Value.ToString();
        change = float.Parse(strData);
       // Debug.Log(change);
    }
}
