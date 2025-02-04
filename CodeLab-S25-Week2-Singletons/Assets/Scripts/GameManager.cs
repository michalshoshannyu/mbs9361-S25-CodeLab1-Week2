using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public int score;

    public int targetScore = 3;

    //the static instance that holds the sole object of this Singleton
    public static GameManager instance;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        //example for a static function that only returns
        Vector3 newVec = UtilScript.CloneVec3(Vector3.down);

        //check to see if someone has set the instance
        if (instance == null)
        {
            //if they haven't this is the instance
            instance = this;
            //and keep it around in other scenes
            DontDestroyOnLoad(this);
        }
        else //otherwise, if there is an existing instance
        {
            //destroy the new instance that was just created
            Destroy(gameObject);
        }
    }

    // Update is called once per frame
    void Update()
    {
        Debug.Log(score);
        //
        // if (targetScore == score)
        // {
        //     targetScore *= 3;
        //     SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
        // }

        // if (PlayerController.instance.canMove)
        // {
        //     // SceneManager.LoadScene(SceneManager.GetActiveScene(0));
        //     SceneManager.LoadScene("Scenes/Forest1");
        // }

        if (SceneManager.GetActiveScene().name != "Forest5")
        {
            if (PlayerController.instance.Walkingforward)
            {
                SceneManager.LoadScene("Scenes/Forest5");
                Debug.Log("yes");
            }
        }
        
        if (SceneManager.GetActiveScene().name != "Forest3")
        {
            if (!PlayerController.instance.Walkingforward)
            {
                SceneManager.LoadScene("Scenes/Forest3");
            }
        }
    }
    
}