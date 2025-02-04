using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public static PlayerController instance;

    public KeyCode keyUp = KeyCode.UpArrow;
    public KeyCode keyDown = KeyCode.DownArrow;
    public KeyCode keyLeft = KeyCode.LeftArrow;
    public KeyCode keyRight = KeyCode.RightArrow;

    Rigidbody rb;
    public bool canMove = false;
    public bool canMoveBack = false;
    public float moveForce = 0.1f;

    public bool Walkingforward = false;

    private Animator _animator;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

        rb = GetComponent<Rigidbody>();
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        rb.linearVelocity *= 0.99f;
        float movingDirection = 0f;

        if (Input.GetKeyDown(keyUp))
        {
            Walkingforward = true;
        }
        

        if (Input.GetKeyDown(keyDown))
        {
            Walkingforward = false;
        }
        if (Input.GetKey(keyLeft))
        { 
            canMoveBack = true;
            movingDirection = -1f;
        }

        if (Input.GetKey(keyRight))
        {
            canMove = true;
            movingDirection = 1f;
        }

        if (!Input.GetKey(keyRight) && !Input.GetKey(keyLeft))
        {
            canMove = false;
            canMoveBack = false;
            movingDirection = Mathf.Lerp(movingDirection, 0f, Time.deltaTime * 0.1f);
        }

        _animator.SetFloat("Forward", movingDirection);
    }
    

}