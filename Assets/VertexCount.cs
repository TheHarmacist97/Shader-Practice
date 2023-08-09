using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VertexCount : MonoBehaviour
{
    Material objectMat;
    [SerializeField] private float duration;
    private Renderer rend;
    void Start()
    {
        rend = GetComponent<Renderer>();
        objectMat = rend.material;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space)) 
        {
            StartCoroutine(Startup());
        }
        if(Input.GetKeyDown(KeyCode.Tab)) 
        {
            StartCoroutine(Shutdown());
        }
    }

    private IEnumerator Startup()
    {
        float elapsedTime = 0f;
        float initVal = 0f;
        float targetVal = 1f;
        while(elapsedTime<=duration)
        {
            yield return null;
            elapsedTime += Time.deltaTime;
            objectMat.SetFloat("_Startup", Mathf.Lerp(initVal, targetVal, elapsedTime / duration));
            //Debug.Log(propertyBlock.GetFloat("_Startup"));
        }
    }

    private IEnumerator Shutdown()
    {
        float elapsedTime = 0f;
        float initVal = 1f;
        float targetVal = 0f;
        while (elapsedTime <= duration)
        {
            yield return null;
            elapsedTime += Time.deltaTime;
            objectMat.SetFloat("_Startup", Mathf.Lerp(initVal, targetVal, elapsedTime / duration));
        }
    }


}
