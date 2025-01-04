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

    public void ColorChange()
    {
        ChangeColor(storedObject.Count > 0 ? Color.black : Color.white);
    }

    public void RecalculateNumber_OnRelease()
    {
        RecalculateNumber();
    }

    public void RecalculateNumber_OnClick(GameObject objectParent)
    {
        if(storedObject.Count > 0) storedObject.Remove(objectParent);

        RecalculateNumber();
    }

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
                int iterations = 0;
                for (int i = boxesInBoundingBox.Count - 1; i >= 0; i--)
                {
                    TMP_Text[] numberPlusOperator = boxesInBoundingBox[i].GetComponentsInChildren<TMP_Text>();
                    for (int j = 0; j < numberPlusOperator.Length; j++)
                    {
                        if (j == 0)
                        {
                            number += boxesInBoundingBox[i].originalText;
                        }
                        else
                        {
                            number += numberPlusOperator[j].text;
                        }
                    }
                    if (iterations >= 1)
                    {
                        Debug.Log("Number before: " + number);
                        Debug.Log("Total Sum Before: " + totalSum);
                        char[] letters = number.ToCharArray();
                        string lastLetter = letters[^1].ToString();
                        if (letters[^1] is '+' or '-' or '*' or '/')
                        {
                            Array.Resize(ref letters, letters.Length - 1);
                        }
                        //commit check
                        totalSum = EquationEvaluator.Evaluate(totalSum + new string(letters));
                        Debug.Log("Total Sum After: " + totalSum);
                        number = "" + lastLetter;
                    }
                    iterations++;

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