using UnityEngine;

public class Buoyancy : MonoBehaviour
{
    [Header("Wave Settings")]
    public Vector4[] Waves;
    public int WaveCount = 8;

    [Header("Noise Settings")]
    public float fbmStrength = 0.1f;
    public float fbmScale = 10f;
    public float fbmSpeed = 1f;
    public int fbmOctaves = 4;
    public float fbmLacunarity = 2f;
    public float fbmGain = 0.5f;

    [Header("Buoyancy Settings")]
    public float buoyancyHeightOffset = 0f;
    public float buoyancySmooth = 2f;
    public float buoyancyStrength = 5f;

    [Header("Water Flow Settings")]
    public float horizontalFlowStrength = 1f;
    public float flowSmooth = 0.5f;

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.drag = 1f;
        rb.angularDrag = 0.5f;
    }

    void FixedUpdate()
    {
        Vector3 pos = transform.position;

        float waterHeight;
        Vector3 flowDir;
        (waterHeight, flowDir) = GetWaveData(pos.x, pos.z, Time.time);

        float diff = (waterHeight + buoyancyHeightOffset) - pos.y;
        rb.AddForce(Vector3.up * diff * buoyancyStrength, ForceMode.Acceleration);

        Vector3 horizontalFlow = flowDir * horizontalFlowStrength;
        rb.AddForce(horizontalFlow, ForceMode.Acceleration);
    }

    (float height, Vector3 flowDir) GetWaveData(float x, float z, float time)
    {
        Vector3 p = new Vector3(x, 0, z);
        Vector3 totalDir = Vector3.zero;
        float height = 0f;

        for (int i = 0; i < WaveCount; i++)
        {
            Vector4 wave = Waves[i];
            float2 d = new float2(wave.x, wave.y).normalized;
            float steepness = wave.z;
            float wavelength = wave.w;

            float k = 2 * Mathf.PI / wavelength;
            float c = Mathf.Sqrt(9.8f / k);
            float f = k * (d.x * p.x + d.y * p.z - c * time);
            float a = steepness / k;

            height += Mathf.Sin(f) * a;

            totalDir += new Vector3(d.x * Mathf.Cos(f), 0, d.y * Mathf.Cos(f));
        }

        float fbm = FBM(new Vector2(x, z) / fbmScale + Vector2.one * fbmSpeed * time);
        height += fbm * fbmStrength;

        return (height, totalDir.normalized);
    }

    float FBM(Vector2 p)
    {
        float total = 0f;
        float amplitude = 1f;
        float frequency = 1f;
        float maxValue = 0f;

        for (int i = 0; i < fbmOctaves; i++)
        {
            total += Mathf.PerlinNoise(p.x * frequency, p.y * frequency) * amplitude;
            maxValue += amplitude;
            amplitude *= fbmGain;
            frequency *= fbmLacunarity;
        }

        return (total / maxValue) * 2f - 1f;
    }

    struct float2
    {
        public float x, y;
        public float2(float X, float Y) { x = X; y = Y; }
        public static float2 operator +(float2 a, float2 b) => new float2(a.x + b.x, a.y + b.y);
        public static float2 operator *(float2 a, float b) => new float2(a.x * b, a.y * b);
        public float magnitude => Mathf.Sqrt(x * x + y * y);
        public float2 normalized => this * (1f / magnitude);
    }
}

