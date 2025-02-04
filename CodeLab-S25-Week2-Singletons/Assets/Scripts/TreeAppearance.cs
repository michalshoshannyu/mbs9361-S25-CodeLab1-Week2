using PathCreation;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using PathCreation;
using UnityEngine;
using UnityEngine.UIElements;

public class TreeAppearance : MonoBehaviour
{
    public PathCreator mainPath;

    public GameObject prefabElement;
    public float numOfPath = 6f;
    private float length;
    private bool canAdd = true;
    private GameObject newPathObject;

    public EndOfPathInstruction end;
    private bool establishedpath = false;
    private float dstTravelld;
    public float speed;
    private List<GameObject> newPathElements = new List<GameObject>();
    private Dictionary<GameObject, float> elements = new Dictionary<GameObject, float>();

    // public static TreeAppearance instance;

    // Start is called once before the first execution of Update after the MonoBehaviour is created

    void Start()
    {
        // if (instance == null)
        // {
        //     instance = this;
        //     DontDestroyOnLoad(gameObject);
        // }
        // else
        // {
        //     Destroy(gameObject);
        // }
       
        mainPath = GetComponent<PathCreator>();
        length = mainPath.path.length;
        StartCoroutine(AddPath());
    }

    // Update is called once per frame
    void Update()
    {
        // if (Input.GetKeyDown(KeyCode.S) && canAdd)
        // {
        //     StartCoroutine(AddPath());
        //     canAdd = false;
        // }
        //
        // if (Input.GetKeyUp(KeyCode.S) && !canAdd)
        // {
        //     canAdd = true;
        // }
        //
        // if (Input.GetKey(KeyCode.D))
        // {
        //     StartCoroutine(DestroyOldPath());
        // }

        if (establishedpath)
        {
            if (PlayerController.instance.canMove)
            {
                MoveAlong(1);
            }
            if (PlayerController.instance.canMoveBack)
            {
                MoveAlong(-1);
            }
        }
    }

    public IEnumerator AddPath()
    {
        for (float t = 0; t <= 1; t += 1f / numOfPath)
        {
            Vector3 pointMainPath = mainPath.path.GetPointAtDistance(length * t);
            Quaternion rotMainPath = Quaternion.identity;
            newPathObject = GameObject.Instantiate(prefabElement, pointMainPath, rotMainPath);
            newPathObject.transform.localScale = prefabElement.transform.localScale;
            newPathObject.transform.rotation = prefabElement.transform.rotation;

            newPathObject.transform.SetParent(transform);
        
            newPathElements.Add(newPathObject);
            elements[newPathObject] = length * t;
            establishedpath = true;

            yield return null;
        }
    }

    private IEnumerator DestroyOldPath()
    {
        while (transform.childCount > 0)
        {
            GameObject.Destroy(transform.GetChild(0).gameObject);
            establishedpath = false;
            yield return null;
        }
        
        newPathElements.Clear();
        elements.Clear();
        establishedpath = false;
    }

    void MoveAlong(int num)
    {
        for (int i = 0; i < newPathElements.Count; i++)
        {
            GameObject obj = newPathElements[i];
            if (obj != null)
            {
                elements[obj] += num * speed * Time.deltaTime;
                obj.transform.position = mainPath.path.GetPointAtDistance(elements[obj], end);
                obj.transform.rotation = prefabElement.transform.rotation;
            }
        }
    }


}