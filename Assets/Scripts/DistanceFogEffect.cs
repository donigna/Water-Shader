using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class DistanceFogEffect : MonoBehaviour
{
    public Material fogMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (fogMaterial == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        fogMaterial.SetVector("_WorldSpaceCameraPos", Camera.main.transform.position);

        Graphics.Blit(source, destination, fogMaterial);
    }
}
