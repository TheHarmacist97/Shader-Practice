using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CreatePalette : MonoBehaviour
{
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
    [Header("Texture Analysis")]
    [SerializeField, Range(8,128)] int skipCount;
    [SerializeField] List<ColorCount> colors;
    [SerializeField, Range(0.9f, 0.9999f)] float threshold;
    private Texture2D tex;

    [Header("Data Dispatch")]
    [SerializeField] Renderer ShowcasedObject;
    [SerializeField] Renderer BG;
    //Start is called before the first frame update
    void Start()
    {
        
    }

    [ContextMenu("Create Color Palette")]
    private void CreateColorPalette()
    {
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        Material sharedBGMaterial = BG.sharedMaterial;

        tex = ShowcasedObject.sharedMaterial.mainTexture as Texture2D;
        if(tex== null)
        {
            Debug.LogError("Attach a texture first fuckface");
            return;
        }

        if(skipCount>tex.width||skipCount>tex.height)
        {
            Debug.LogError("Skip count is too high for this texture");
            return;
        }

        colors = new List<ColorCount>();
        Color currentColor = Color.white;
        ColorCount foundColorCount; 
        for(int i = 0; i < tex.width; i+=skipCount)
        {
            for(int j = 0; j < tex.height; j+=skipCount)
            {
                currentColor = tex.GetPixel(i, j);
                if(currentColor.a>0.9&&currentColor.maxColorComponent>0.4)
                {
                    foundColorCount = colors.Find(i => Vector4.Dot(Vector4.Normalize(i.color), Vector4.Normalize(currentColor)) >= threshold);
                    if (foundColorCount.count==0)
                    {
                        colors.Add(new (currentColor, 1));
                        Debug.Log("added " + currentColor.ToString());
                    }
                    else
                    {
                        foundColorCount.count++;
                        Debug.Log("incremented");
                    }
                }
            }
        }
        colors.OrderBy((i)=>i.count);
        colors = colors.Take(3).ToList();

        mpb.SetColor("col", colors[1].color);
        mpb.SetColor("col2", colors[2].color);
        mpb.SetColor("col3", colors[0].color);

        BG.SetPropertyBlock(mpb);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

