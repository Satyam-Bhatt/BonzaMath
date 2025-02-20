using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class BoundingBox : MonoBehaviour
{
    [field: SerializeField] public bool CanBeFilled { get; private set; } = false;

    public List<GameObject> storedObject = null; //The Objects present in the Bounding Box

    private void OnEnable()
    {
        objectManager.Instance.SendHitObject += PopulateBoxHighlights;
        objectManager.Instance.OnObjectReleased += MouseClickReleased;
    }

    private void OnDisable()
    {
        if (objectManager.Instance != null)
        {
            objectManager.Instance.SendHitObject -= PopulateBoxHighlights;
            objectManager.Instance.OnObjectReleased -= MouseClickReleased;
        }
    }

    private void Start()
    {
        CheckForAlreadyPresentNumber();
    }

    public void Fill(bool state)
    {
        CanBeFilled = state;
    }

    public void ChangeColor(Color color)
    {
        GetComponent<SpriteRenderer>().color = color;
    }

    private void PopulateBoxHighlights(GameObject o)
    {
        foreach (GameObject gO in storedObject)
        {
            if (gO == o)
            {
                storedObject.Remove(o);
                break;
            }
        }
    }

    private void MouseClickReleased()
    {
        if (storedObject.Count > 0)
        {
            ChangeColor(Color.black);
        }
        else
        {
            ChangeColor(Color.white);
        }
    }

    private void CheckForAlreadyPresentNumber()
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit2D[] hit = Physics2D.RaycastAll(ray.origin, ray.direction);

        foreach (var h in hit)
        {
            if (h.collider != null && h.collider.gameObject.tag == "ChildObject" && h.collider.gameObject != this.gameObject)
            {
                storedObject.Add(h.collider.transform.parent.gameObject);
                ChangeColor(Color.black);
            }
        }
    }

    public void ColorChange()
    {
        ChangeColor(storedObject.Count > 0 ? Color.black : Color.white);
    }

    public void RecalculateNumber_OnRelease()
    {
        RecalculateNumber();
        RearrangeTheDepth();
    }

    public void RecalculateNumber_OnClick(GameObject objectParent)
    {
        if (storedObject.Count > 0) storedObject.Remove(objectParent);

        RecalculateNumber();
    }

    private void RearrangeTheDepth()
    {
        if (storedObject.Count == 0) return;

        float depth = - 0.1f;
        foreach(GameObject g in storedObject)
        {
            Debug.Log(depth + " name" + g.name);
            g.transform.position = new Vector3(g.transform.position.x, g.transform.position.y, depth);
            depth -= 0.1f;
            
        }
    }

    //Loop through the boxes and then calculate the total. It does not Follow DMAS so we take 2 boxes at a time calculate the number and then move to the upper one
    private void RecalculateNumber()
    {
        if (storedObject.Count > 0)
        {
            List<boxDetection> boxesInBoundingBox = new List<boxDetection>();
            foreach (var sO in storedObject)
            {
                boxDetection[] boxesInObject = sO.GetComponentsInChildren<boxDetection>();
                foreach (boxDetection box in boxesInObject)
                {
                    if ((Vector2)box.transform.position == (Vector2)transform.position)
                    {
                        boxesInBoundingBox.Add(box);
                    }
                }
            }

            if (storedObject.Count > 1)
            {
                string number = "";
                string totalSum = "";
                string lowerNum = "";

                TMP_Text[] numberPlusOperator = boxesInBoundingBox[0].GetComponentsInChildren<TMP_Text>();
                lowerNum += boxesInBoundingBox[0].originalText;
                lowerNum += numberPlusOperator[1].text;

                for (int i = 1; i < boxesInBoundingBox.Count; i++)
                {
                    string upperNum = "";
                    TMP_Text[] numberPlusOperator2 = boxesInBoundingBox[i].GetComponentsInChildren<TMP_Text>();
                    for (int j = 0; j < numberPlusOperator2.Length; j++)
                    {
                        if (j == 0)
                        {
                            upperNum += boxesInBoundingBox[i].originalText;
                        }
                        else
                        {
                            upperNum += numberPlusOperator2[j].text;
                        }
                    }
                    number = upperNum + lowerNum;

                    char[] letters = number.ToCharArray();
                    if (letters[^1] is '+' or '-' or '*' or '/')
                    {
                        Array.Resize(ref letters, letters.Length - 1);
                    }
                    totalSum = EquationEvaluator.Evaluate(new string(letters));
                    lowerNum = totalSum + upperNum.ToCharArray()[1];
                }
                boxesInBoundingBox[^1].GetComponentInChildren<TMP_Text>().text = totalSum;

            }
            else
            {
                //Have the number shown of the only one remaining
                boxesInBoundingBox[0].GetComponentInChildren<TMP_Text>().text = boxesInBoundingBox[0].originalText;
            }
        }
    }
}
