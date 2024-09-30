using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class EquationEvaluator : MonoBehaviour
{
    public string input;
    public string output;

    private void Start()
    {
        output = Evaluate(input).ToString();
    }

    public float Evaluate(string equation)
    {
        List<string> equationElements = equation.Select(c => c.ToString()).ToList();

        float finalValue = 0;

        for (int i = 0; i < equationElements.Count; i++)
        {
            Debug.Log(equationElements[i]);
            if (IsOperator(equationElements[i]))
            {
                float a = float.Parse(equationElements[i - 1]);
                float b = 0;
                if (i + 1 < equationElements.Count)
                    b = float.Parse(equationElements[i + 1]);
                else
                    return finalValue;

                Debug.Log("a: " + a + " b: " + b + " op: " + equationElements[i]);

                //return Calculate(a, b, equationElements[i]);
                if (i + 1 < equationElements.Count)
                {
                    equationElements[i + 1] = Calculate(a, b, equationElements[i]).ToString();
                    finalValue = float.Parse(equationElements[i + 1]);
                }
                else
                {
                    finalValue = Calculate(a, b, equationElements[i]);
                }
            }
        }

        return finalValue;
    }

    private bool IsOperator(string c)
    { 
        return c == "+" || c == "-" || c == "*" || c == "/";
    }

    private float Calculate(float a, float b, string op)
    {
        return op switch
        {
            "+" => a + b,
            "-" => a - b,
            "*" => a * b,
            "/" => b == 0 ? throw new DivideByZeroException("Division by zero") : a / b,
            _ => throw new ArgumentException($"Unknown operator: {op}"),
        };
    }

}
