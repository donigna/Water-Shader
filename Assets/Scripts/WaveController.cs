using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class WaveController : MonoBehaviour
{
    /// <summary>
    /// The number of waves to calculate. This will be passed to the shader.
    /// </summary>
    [Tooltip("Number of active waves. Must be between 0 and 10.")]
    [Range(0, 32)]
    [SerializeField] int waveCount = 32;
    [SerializeField] Vector2 amplitudeRange = new Vector2(0.02f, 0.15f);
    [SerializeField] Vector2 wavelengthRange = new Vector2(5f, 15f);


    /// <summary>
    /// Wave data. Each Vector4 represents one wave.
    /// X, Y: Direction of the wave.
    /// Z: Steepness (how sharp the wave peak is).
    /// W: Wavelength (distance between crests).
    /// </summary>
    [Tooltip("Wave Data (XY=Direction, Z=Steepness, W=Wavelength)")]
    public Vector4[] waves = new Vector4[32];

    Vector4[] GenerateLowWaves()
    {
        Vector4[] waves = new Vector4[waveCount];
        for (int i = 0; i < waveCount; i++)
        {
            Vector2 dir = Random.insideUnitCircle.normalized;
            float amplitude = Random.Range(amplitudeRange.x, amplitudeRange.y);
            float wavelength = Random.Range(wavelengthRange.x, wavelengthRange.y);

            waves[i] = new Vector4(dir.x, dir.y, amplitude, wavelength);
        }
        return waves;
    }

    private Material _material;

    /// <summary>
    /// Resets the wave data to a default set.
    /// </summary>
    [ContextMenu("Reset Waves to Default")]
    void ResetWaves()
    {
        Vector4[] defaultWaves = GenerateLowWaves();

        for (int i = 0; i < waves.Length; i++)
        {
            if (i < defaultWaves.Length)
            {
                waves[i] = defaultWaves[i];
            }
        }
        waveCount = 32;
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
