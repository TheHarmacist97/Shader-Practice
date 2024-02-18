using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CardManager))]
public class CardManagerInspector : Editor
{
    private CardManager manager;
    public override void OnInspectorGUI()
    {
        manager = (CardManager)target;
        base.OnInspectorGUI();
        if(GUILayout.Button("Set up card"))
        {
            manager.SetUpCard();
        }
    }
}
