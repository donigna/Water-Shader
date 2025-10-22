using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class WaveController : MonoBehaviour
{
    /// <summary>
    /// The number of waves to calculate. This will be passed to the shader.
    /// </summary>
    [Tooltip("Number of active waves. Must be between 0 and 10.")]
    [Range(0, 10)]
    public int waveCount = 3;

    /// <summary>
    /// Wave data. Each Vector4 represents one wave.
    /// X, Y: Direction of the wave.
    /// Z: Steepness (how sharp the wave peak is).
    /// W: Wavelength (distance between crests).
    /// </summary>
    [Tooltip("Wave Data (XY=Direction, Z=Steepness, W=Wavelength)")]
    public Vector4[] waves = new Vector4[10];

    // Default wave presets for demonstration.
    private static readonly Vector4[] defaultWaves = new Vector4[]
    {
        new Vector4(1.0f, 0.0f, 0.5f, 10.0f),
        new Vector4(0.0f, 1.0f, 0.25f, 20.0f),
        new Vector4(1.0f, 1.0f, 0.15f, 10.0f),
        new Vector4(0.5f, 0.2f, 0.2f, 5.0f),
        new Vector4(0.2f, 0.8f, 0.1f, 12.0f),
        new Vector4(0.8f, -0.4f, 0.3f, 8.0f),
        new Vector4(-0.3f, 0.6f, 0.15f, 15.0f),
        new Vector4(-0.7f, -0.1f, 0.25f, 6.0f),
        new Vector4(0.4f, 0.9f, 0.05f, 25.0f),
        new Vector4(-0.9f, 0.3f, 0.1f, 18.0f)
    };

    private Material _material;

    /// <summary>
    /// Resets the wave data to a default set.
    /// </summary>
    [ContextMenu("Reset Waves to Default")]
    void ResetWaves()
    {
        for (int i = 0; i < waves.Length; i++)
        {
            if (i < defaultWaves.Length)
            {
                waves[i] = defaultWaves[i];
            }
        }
        waveCount = 3;
        UpdateShaderProperties();
    }

    void Awake()
    {
        InitializeMaterial();
        UpdateShaderProperties();
    }

    /// <summary>
    /// Called when the script is loaded or a value is changed in the Inspector.
    /// This allows for real-time updates in the editor.
    /// </summary>
    void OnValidate()
    {
        InitializeMaterial();
        UpdateShaderProperties();
    }

    private void InitializeMaterial()
    {
        if (_material == null)
        {
            MeshRenderer renderer = GetComponent<MeshRenderer>();
            // Use sharedMaterial in editor to avoid creating material instances.
            _material = Application.isPlaying ? renderer.material : renderer.sharedMaterial;
        }
    }

    /// <summary>
    /// Sends the current wave configuration to the shader.
    /// </summary>
    private void UpdateShaderProperties()
    {
        if (_material != null)
        {
            _material.SetInt("_WaveCount", waveCount);
            _material.SetVectorArray("_Waves", waves);
        }
    }
}
