using System;
using System.Collections;
using System.Collections.Generic;
using PathCreation;
using UnityEngine;
using UnityEngine.UIElements;

public class ElementsScript : MonoBehaviour
{
    public static ElementsScript instance;
    
    public PathCreator pathCreator;

    private float length;

    public float numOfElements = 3f;

    public float animationTime = 0.5f;

    public GameObject prefabElement;

    private List<GameObject> elements = new List<GameObject>();
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created

    void Start()
    {
        if (instance == null)
        {
            instance = this;
            // DontDestroyOnLoad(gameObject);
        }
        
        pathCreator.GetComponent<PathCreator>();
        length = pathCreator.path.length;
        
        StartCoroutine(buildElements(animationTime / (float)numOfElements));

    }

    // Update is called once per frame
    void Update()
    {
   
    }

    public void StartCreating()
    {
        // if (!gameObject.activeSelf)
        // {
        //     gameObject.SetActive(true);
        // }

        StartCoroutine(buildElements(animationTime / (float)numOfElements));
        // Debug.Log("Creating ElementsScript");
    }

    private IEnumerator buildElements(float time)
    {
    
        for (float t = 0; t <= 1; t += 1f / numOfElements)
        {
            Vector3 pointPath = pathCreator.path.GetPointAtDistance(length * t);
            Quaternion rot = pathCreator.path.GetRotationAtDistance(length * t);
            GameObject newElement = GameObject.Instantiate(prefabElement, pointPath, rot, transform);
            elements.Add(newElement);
            
            newElement.SetActive(false);
            yield return new WaitForSeconds(time);
        }
    }

    public void StartDestroyElements()
    {
        StartCoroutine(DestroyElements(animationTime / (float)numOfElements));
   
    }

    private IEnumerator DestroyElements(float time)
    {
        while (transform.childCount>0)
        {
            GameObject.Destroy(transform.GetChild(transform.childCount-1).gameObject);
            //0
            
            yield return new WaitForSeconds(time);
        }
        gameObject.SetActive(false);
    }

    public void ActiveElements()
    {
        StartCoroutine(Reactive(animationTime / elements.Count));
  
    }

    private IEnumerator Reactive(float time)
    {
        for (int i = 0; i < elements.Count; i++)
        {
            GameObject element = elements[i];
            if (element != null && !element.activeSelf)
            {
                element.SetActive(true);
                yield return new WaitForSeconds(time);
            }
        }
    }

    public void DeactiveElements()
    {
        
    StartCoroutine(InactiveElements(animationTime/elements.Count));
   
    }

    private IEnumerator InactiveElements(float time)
    {
        for (int i = 0; i < elements.Count; i++)
        {
            GameObject element = elements[i];
            if (element != null && element.activeSelf)
            {
                element.SetActive(false);
                yield return new WaitForSeconds(time);
            }
        }
    }
    
}
