using System;
using UnityEngine;

public class PathElementCollision : MonoBehaviour
{
    private bool hadTriged = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "CubeCollision" && !hadTriged)
        {
            ElementsScript elementScript = GetComponent<ElementsScript>();
            if (elementScript != null)
            {
                // elementScript.StartCreating();
                elementScript.ActiveElements();
            }

            hadTriged = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.name == "CubeCollisionEnd" && hadTriged)
        {
            ElementsScript elementScript = GetComponent<ElementsScript>();
            if (elementScript != null)
            {
                // elementScript.StartDestroyElements();
                elementScript.DeactiveElements();
            }

            hadTriged = false;
        }
    }
}