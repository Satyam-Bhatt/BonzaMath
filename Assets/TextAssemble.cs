using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TextAssemble : MonoBehaviour
{
    //-----------------TEXT ASSEMBLE ANIMATION-----------------
    [SerializeField] private boxDetection[] boxDetection_Components;
    [SerializeField] private Transform textAssemle_Start;
    private GameObject[] objectCollection;

    private void OnEnable()
    {
        objectManager.Instance.UpdateTotalText += TextAssembleAnimation;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
            objectManager.Instance.UpdateTotalText -= TextAssembleAnimation;
    }

    // Start is called before the first frame update
    void Start()
    {
        boxDetection_Components = FindObjectsOfType<boxDetection>();
        objectCollection = new GameObject[boxDetection_Components.Length];
        TextAssembleAnimation();
    }

    private void TextAssembleAnimation()
    {
        Sort_Boxes();
        StopAllCoroutines();
        DestroyGameObjects();

        float offset = 0f;
        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            GameObject element = boxDetection_Components[i].gameObject;
            GameObject newObj = new GameObject("T " + i);
            string valueStored = "";
            foreach (TMP_Text text in element.GetComponentsInChildren<TMP_Text>())
            {
                valueStored += text.text;
            }
            StartCoroutine(TextAssembleMove(newObj, i / 5f, element.transform, valueStored, new Vector3(offset, 0, 0)));
            offset += 0.8f;
            objectCollection[i] = newObj;
        }
        StartCoroutine(DestroyAll(objectCollection));
    }

    IEnumerator TextAssembleMove(GameObject obj, float delay, Transform bD, string text, Vector3 addedPos)
    {
        yield return new WaitForSeconds(delay);
        obj.transform.position = bD.gameObject.transform.position;
        obj.transform.SetParent(transform);
        RectTransform rt = obj.AddComponent<RectTransform>();
        rt.anchorMax = new Vector2(1, 1);
        rt.anchorMin = new Vector2(0, 0);
        rt.pivot = new Vector2(0.5f, 0.5f);
        TMP_Text tex = obj.AddComponent<TextMeshProUGUI>();
        tex.color = Color.black;
        tex.fontStyle = FontStyles.Bold;
        tex.text = text;
        tex.fontSize = 0.6f;
        tex.alignment = TextAlignmentOptions.Center;
        while (true)
        {
            yield return new WaitForEndOfFrame();
            if (obj == null) break;
            else
                obj.transform.position = Vector2.Lerp(obj.transform.position, textAssemle_Start.position + addedPos, 1f * Time.deltaTime);
        }
        StopAllCoroutines();
    }

    IEnumerator DestroyAll(GameObject[] obj)
    {
        yield return new WaitForSeconds(7f);
        foreach (GameObject o in obj)
        {
            if (o != null)
                Destroy(o);
        }
    }

    private void DestroyGameObjects()
    {
        foreach (GameObject o in objectCollection)
        {
            if (o != null)
                Destroy(o);
        }
    }

    private void Sort_Boxes()
    {
        for (int i = 0; i < boxDetection_Components.Length; i++)
        {
            if (i + 1 >= boxDetection_Components.Length)
                break;

            boxDetection index_0 = boxDetection_Components[i];
            float posY0 = Mathf.Round(index_0.transform.position.y);
            boxDetection index_01 = boxDetection_Components[i + 1];
            float posY01 = Mathf.Round(index_01.transform.position.y);

            if (posY0 < posY01)
            {
                boxDetection temp = boxDetection_Components[i];
                boxDetection_Components[i] = boxDetection_Components[i + 1];
                boxDetection_Components[i + 1] = temp;
                Sort_Boxes();
            }
            else if (posY0 == posY01)
            {
                if (index_0.transform.position.x > index_01.transform.position.x)
                {
                    boxDetection temp = boxDetection_Components[i];
                    boxDetection_Components[i] = boxDetection_Components[i + 1];
                    boxDetection_Components[i + 1] = temp;
                    Sort_Boxes();
                }
            }
        }
    }
}
