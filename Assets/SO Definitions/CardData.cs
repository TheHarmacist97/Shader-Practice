using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Card Data", menuName = "Card Data")]
public class CardData : ScriptableObject
{
    public string cardName;
    public Texture2D showcase;
    public Stats[] stats;

    public void RandomizeStats()
    {
        if (stats == null) return;

        if(stats.Length == 0 )
        {
            stats = new Stats[4] { new("Health"), new("Speed"), new("Handling"), new("Damage") };
        }

        foreach (Stats item in stats)
        {
            item.max = Random.Range(4, 12);
            item.current = Random.Range(1, item.max);
            item.nextUpgrade = Random.Range(0, 3);
        }
    }
}
