using UnityEngine;
[System.Serializable]
public class Stats 
{
    public string statName;
    [Range(1,12)] public int max;
    [Range(1, 12)] public int current;
    [Range(0, 4)] public int nextUpgrade;

    public Stats(string statName)
    {
        this.statName = statName;
    }
}
