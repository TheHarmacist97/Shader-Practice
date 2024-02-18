using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CardData))]
public class CardSOInspector : Editor
{
    private CardData cardData;
    public override void OnInspectorGUI()
    {
        cardData = (CardData)target;
        base.OnInspectorGUI();
        if(GUILayout.Button("Randomize SO Data"))
        {
            cardData.RandomizeStats();
        }
    }
}
