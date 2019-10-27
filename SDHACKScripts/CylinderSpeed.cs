using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase;
using Firebase.Database;
using Firebase.Unity.Editor;
public class CylinderSpeed : MonoBehaviour
{
    public GameObject player1;
    public Vector3 initPos;
    private Vector3 toPlayer;
    private Vector3 flipz;

    private float change = 30;
    private float speed = 0.3f;
    // Start is called before the first frame update
    void Start()
    {
        FirebaseApp.DefaultInstance.SetEditorDatabaseUrl("https://dodgemonster.firebaseio.com/");
        toPlayer = player1.transform.position - this.transform.position;
        transform.right = toPlayer;
        flipz = new Vector3(0, 0, 180);
        this.transform.Rotate(flipz);
        initPos = this.transform.position;
        this.gameObject.tag = "Cylinder";
        getSpeed();
    }
    void DestroyObjectDelayed()
    {
        Destroy(this, 10);
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
        this.transform.RotateAround(transform.position, transform.right, Time.deltaTime * 900f);
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
        //Debug.Log(change);
    }
}

