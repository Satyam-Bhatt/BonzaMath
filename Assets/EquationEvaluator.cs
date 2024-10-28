using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;

public static class EquationEvaluator
{
    public static string Evaluate(string equation)
    {
        //equation = "2*9+3*6/2-4";
        
        equation = equation.Replace("+", " + ").Replace("-", " - ").Replace("*", " * ").Replace("/", " / ");
        List<string> equationElements = equation.Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();

        /*float finalValue = 0;

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
            else if (equationElements.Count == 1 && !IsOperator(equationElements[0])) // if there is only one element in the equation
            { 
                finalValue = float.Parse(equationElements[0]);
            }
        }

        return finalValue.ToString();*/
        while (equationElements.Count > 1)
        {
            // Find the index of multiplication or division operator
            int operatorIndex = equationElements.FindIndex(x => x == "*" || x == "/");
            
            if (operatorIndex != -1)  // If multiplication or division exists
            {
                float result = Calculate(
                    float.Parse(equationElements[operatorIndex - 1]),
                    float.Parse(equationElements[operatorIndex + 1]),
                    equationElements[operatorIndex]);
                
                // Replace the three elements (number, operator, number) with result
                equationElements.RemoveRange(operatorIndex - 1, 3);
                equationElements.Insert(operatorIndex - 1, result.ToString());
            }
            else  // Handle addition/subtraction
            {
                float result = Calculate(
                    float.Parse(equationElements[0]),
                    float.Parse(equationElements[2]),
                    equationElements[1]);
                
                // Replace the first three elements with result
                equationElements.RemoveRange(0, 3);
                equationElements.Insert(0, result.ToString());
            }
        }
        // Debug.Log(equationElements[0]);
        return equationElements[0];
        
    }

    public static string EvaluateWithDMAS(string equation)
    {
        equation = equation.Replace("+", " + ").Replace("-", " - ").Replace("*", " * ").Replace("/", " / ");
        List<string> equationElements = equation.Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();

        float finalValue = 0;

        for (int i = 0; i < equationElements.Count; i++)
        {
            if (IsOperator(equationElements[i]))
            {
                var thisOperator = equationElements[i];
                
                if(thisOperator is "*" or "/")
                {
                    
                }
                else if (thisOperator is "+" or "-")
                {
                    var nextOperator = equationElements[i + 2];
                    if (nextOperator is "*" or "/")
                    {
                        
                    }
                    else
                    {
                        
                    }
                }

            }
            else if (equationElements.Count == 1 && !IsOperator(equationElements[0])) // if there is only one element in the equation
            {
                finalValue = float.Parse(equationElements[0]);
            }
        }

        return finalValue.ToString();
    }

    private static bool IsOperator(string c)
    {
        return c is "+" or "-" or "*" or "/";
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
