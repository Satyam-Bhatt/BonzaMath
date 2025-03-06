using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestScrip : MonoBehaviour
{
    public RectTransform graphContainer;
    public GameObject pointPrefab;

    void Start()
    {
        DrawGraph();
    }

    void DrawGraph()
    {
        List<float> progressValues = new List<float>();
        List<float> timeValues = new List<float>();

        // Calculate progress values over time
        for (float t = 0f; t <= 1f; t += 0.02f)
        {
            float d = 2f;
            float progress = (float)(Mathf.Pow(2, -10 * t) * Mathf.Sin((t * d - 0.075f) * (2 * Mathf.PI) / 0.3f) + 1);

            progressValues.Add(progress);
            timeValues.Add(t);
        }

        // Get graph dimensions
        float graphWidth = graphContainer.rect.width;
        float graphHeight = graphContainer.rect.height;

        // Create points
        for (int i = 0; i < progressValues.Count; i++)
        {
            GameObject pointObject = Instantiate(pointPrefab, graphContainer);
            RectTransform pointRectTransform = pointObject.GetComponent<RectTransform>();

            // Position X based on time (0 to 1)
            float xPosition = timeValues[i] * graphWidth;

            // Position Y based on progress value
            // Normalize to graph height, inverting because Unity's UI starts from bottom
            float yPosition = (1 - progressValues[i]) * graphHeight;

            pointRectTransform.anchoredPosition = new Vector2(xPosition, yPosition);

            // Optional: Color gradient based on progress
            Image pointImage = pointObject.GetComponent<Image>();
            pointImage.color = Color.Lerp(Color.blue, Color.red, progressValues[i]);
        }
    }
}
