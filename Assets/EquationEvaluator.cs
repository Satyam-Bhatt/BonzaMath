using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public static class EquationEvaluator
{
    public static string Evaluate(string equation)
    {
        /*        List<string> equationElements = equation.Select(c => c.ToString()).ToList();

                float finalValue = 0;

                for (int i = 0; i < equationElements.Count; i++)
                {
                    if (IsOperator(equationElements[i]))
                    {
                        float a = float.Parse(equationElements[i - 1]);
                        float b = 0;
                        if (i + 1 < equationElements.Count)
                            b = float.Parse(equationElements[i + 1]);
                        else
                            return finalValue.ToString();

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

                return finalValue.ToString();*/

        equation = equation.Replace("+", " + ").Replace("-", " - ").Replace("*", " * ").Replace("/", " / ");
        List<string> equationElements = equation.Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();

        float finalValue = 0;

        for (int i = 0; i < equationElements.Count; i++)
        {
            if (IsOperator(equationElements[i]))
            {
                float a = float.Parse(equationElements[i - 1]);
                float b = 0;
                if (i + 1 < equationElements.Count)
                    b = float.Parse(equationElements[i + 1]);
                else
                    return finalValue.ToString();

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

        return finalValue.ToString();
    }

    private static bool IsOperator(string c)
    {
        return c == "+" || c == "-" || c == "*" || c == "/";
    }

    private static float Calculate(float a, float b, string op)
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
