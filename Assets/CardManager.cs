using System.Collections.Generic;
using System.Linq;
using UnityEngine;


public class CardManager : MonoBehaviour
{
    [Header("Texture Analysis")]
    [SerializeField, Range(8, 128)] int skipCount;
    [SerializeField, Range(0.9f, 0.9999f)] float threshold;

    [Header("Other References")]
    [SerializeField] private CreatePalette paletteCreator;
    [SerializeField] private CardData cardData;
    [SerializeField] private Renderer BG;
    [SerializeField] private Renderer showcasedObject;
    private MaterialPropertyBlock bgMPB;
    private MaterialPropertyBlock ShowcaseMPB;
    [SerializeField] private Color[] colors;

    private void Awake()
    {
        if (cardData == null) return;

        if (colors == null)
        {
        }
            SetUpColorData();

        DispatchData();
    }

    public void SetUpCard()
    {
        if (cardData == null)
        {
            return;
        }
        SetUpColorData();

        DispatchData();
    }

    private void SetUpColorData()
    {
        bgMPB = new MaterialPropertyBlock();
        ShowcaseMPB = new MaterialPropertyBlock();
        colors = CreateColorPalette(cardData.showcase, skipCount, threshold);
    }

    private void DispatchData()
    {
        bgMPB.Clear();
        ShowcaseMPB.Clear();
        bgMPB.SetColor("_Color1", colors[0 % colors.Length]);
        bgMPB.SetColor("_Color2", colors[1 % colors.Length]);
        bgMPB.SetColor("_Color3", colors[2 % colors.Length]);
        BG.SetPropertyBlock(bgMPB);

        ShowcaseMPB.SetTexture("_MainTex", cardData.showcase);
        showcasedObject.SetPropertyBlock(ShowcaseMPB);
    }

    public Color[] CreateColorPalette(Texture2D tex, int skipCount, float threshold)
    {
        if (tex == null)
        {
            Debug.LogError("Attach a texture first fuckface");
            return null;
        }

        if (skipCount > tex.width || skipCount > tex.height)
        {
            Debug.LogError("Skip count is too high for this texture");
            return null;
        }

        List<ColorCount> colors = new();
        Color currentColor = Color.white;
        ColorCount foundColorCount;
        for (int i = 0; i < tex.width; i += skipCount)
        {
            for (int j = 0; j < tex.height; j += skipCount)
            {
                currentColor = tex.GetPixel(i, j);
                if (currentColor.a > 0.9 && currentColor.maxColorComponent > 0.6)
                {
                    foundColorCount = colors.Find(i => Vector4.Dot(Vector4.Normalize(i.color), Vector4.Normalize(currentColor)) >= threshold);
                    if (foundColorCount.count == 0)
                    {
                        colors.Add(new(currentColor, 1));
                        Debug.Log("added " + currentColor.ToString());
                    }
                    else
                    {
                        //foundColorCount.color = foundColorCount.color * (foundColorCount.count / foundColorCount.count + 1) 
                        //    + currentColor/(foundColorCount.count+1);
                        foundColorCount.count++;
                        Debug.Log("incremented");
                    }
                }
            }
        }
        colors.OrderBy((i) => i.count);
        return colors.Take(3).Select(i => i.color).ToArray();
    }

    [System.Serializable]
    public struct ColorCount
    {
        public Color color;
        public int count;

        public ColorCount(Color color, int count)
        {
            this.color = color;
            this.count = count;
        }
    }

}
