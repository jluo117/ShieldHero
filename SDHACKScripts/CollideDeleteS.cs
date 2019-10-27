using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollideDeleteS : MonoBehaviour
{
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        
        if (other.gameObject.tag != "Player")
        {
            Destroy(other.gameObject);

        }
        else
        {
            other.transform.position = new Vector3(0, 0, 0);
        }
        /*
        else if (other.gameObject.tag == "Cylinder")
        {
            Debug.Log("we got a cylinder gals");
        }
        */
        
        


    }
}
