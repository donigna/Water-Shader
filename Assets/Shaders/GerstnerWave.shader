Shader "Custom/GerstnerWave"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0

        [Header(Wave Configuration)]
        _WaveCount("Wave Count", Range(0, 32)) = 32

        [Header(fBm Noise Settings)]
        _fbmStrength("Noise Strength", Range(0, 2)) = 0.1
        _fbmScale("Noise Scale", Range(1, 100)) = 10.0
        _fbmSpeed("Noise Speed", Range(0, 5)) = 1.0
        _fbmOctaves("Noise Octaves", Range(1, 8)) = 4
        _fbmLacunarity("Noise Lacunarity", Range(1.0, 4.0)) = 2.0
        _fbmGain("Noise Gain", Range(0.0, 1.0)) = 0.5


        [Header(Water Shading)]
        _ReflectionTex ("Reflection Cubemap", CUBE) = "" {}
        _ReflectionPower ("Reflection Power", Range(0, 1)) = 1
        _ShallowColor ("Shallow Water Color", Color) = (0.1, 0.4, 0.6, 1)
        _DeepColor ("Deep Water Color", Color) = (0.0, 0.1, 0.3, 1)
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _FoamStrength ("Foam Strength", Range(0, 1)) = 0.5
        _FresnelPower ("Fresnel Power", Range(1, 8)) = 2
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0

        #define MAX_WAVES 32

        sampler2D _MainTex;
        samplerCUBE _ReflectionTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 customNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Properti Gerstner Wave
        uniform float4 _Waves[MAX_WAVES];
        uniform int _WaveCount;

        // Properti fBm
        float _fbmStrength;
        float _fbmScale;
        float _fbmSpeed;
        int _fbmOctaves;
        float _fbmLacunarity;
        float _fbmGain;

        // Properti Shading
        float _FresnelPower;
        fixed4 _ShallowColor;
        fixed4 _DeepColor;
        fixed4 _FoamColor;

        float2 hash(float2 p) {
            p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
            return - 1.0 + 2.0 * frac(sin(p) * 43758.5453123);
        }

        float noise(in float2 p) {
            const float K1 = 0.366025404; // (sqrt(3) - 1) / 2;
            const float K2 = 0.211324865; // (3 - sqrt(3)) / 6;

            float2 i = floor(p + (p.x + p.y) * K1);

            float2 a = p - i + (i.x + i.y) * K2;
            float2 o = (a.x > a.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
            float2 b = a - o + K2;
            float2 c = a - 1.0 + 2.0 * K2;

            float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
            float3 n = h * h * h * h * float3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

            return dot(n, float3(70.0, 70.0, 70.0));
        }

        // Fractional Brownian Motion
        float fbm(float2 p) {
            float total = 0.0;
            float frequency = 1.0;
            float amplitude = 1.0;
            float maxValue = 0.0;

            for (int i = 0; i < _fbmOctaves; i ++) {
                total += noise(p * frequency) * amplitude;
                maxValue += amplitude;
                amplitude *= _fbmGain;
                frequency *= _fbmLacunarity;
            }

            return total / maxValue;
        }

        // Gerstner Wave
        float3 GerstnerWave (float4 wave, float3 p, inout float3 tangent, inout float3 binormal) {
            float steepness = wave.z;
            float wavelength = wave.w;
            float k = 2 * UNITY_PI / wavelength;
            float c = sqrt(9.8 / k);
            float2 d = normalize(wave.xy);
            float f = k * (dot(d, p.xz) - c * _Time.y);
            float a = steepness / k;

            tangent += float3 (
            - d.x * d.x * (steepness * sin(f)),
            d.x * (steepness * cos(f)),
            - d.x * d.y * (steepness * sin(f))
            );

            binormal += float3 (
            - d.x * d.y * (steepness * sin(f)),
            d.y * (steepness * cos(f)),
            - d.y * d.y * (steepness * sin(f))
            );

            return float3(
            d.x * (a * cos(f)),
            a * sin(f),
            d.y * (a * cos(f))
            );
        }

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float3 gridPoint = v.vertex.xyz;
            float3 p = gridPoint;

            float3 tangent = float3(1, 0, 0);
            float3 binormal = float3(0, 0, 1);
            for (int i = 0; i < _WaveCount; i ++)
            {
                p += GerstnerWave(_Waves[i], gridPoint, tangent, binormal);
            }

            float2 noiseCoords = (gridPoint.xz / _fbmScale) + (_Time.y * _fbmSpeed);
            float noiseVal = fbm(noiseCoords);
            p.y += noiseVal * _fbmStrength;

            float3 normal = normalize(cross(binormal, tangent));

            v.vertex.xyz = p;
            v.normal = normal;
            o.customNormal = UnityObjectToWorldNormal(normal);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        }

        float _FoamStrength;
        float _ReflectionPower;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float3 viewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float3 normal = normalize(IN.customNormal);

            float fresnel = pow(1.0 - saturate(dot(viewDir, normal)), _FresnelPower);

            float gerstnerFoam = saturate(1.0 - normal.y);
            gerstnerFoam *= pow(fresnel, 0.5);

            float2 noiseCoords = (IN.worldPos.xz / (_fbmScale * 0.5)) + (_Time.y * _fbmSpeed);
            float fbmFoam = fbm(noiseCoords);
            fbmFoam = saturate((fbmFoam + 1.0) * 0.5); 

            float finalFoam = saturate(gerstnerFoam + pow(fbmFoam, 3.0) * 0.5);

            float3 reflDir = reflect(- viewDir, normal);
            float3 reflection = texCUBE(_ReflectionTex, reflDir).rgb * _ReflectionPower;

            float depthFactor = saturate((IN.worldPos.y + 5) / 10);
            float3 depthColor = lerp(_DeepColor.rgb, _ShallowColor.rgb, depthFactor);

            float3 baseColor = lerp(depthColor, reflection, fresnel);

            o.Albedo = lerp(baseColor, _FoamColor.rgb, finalFoam * _FoamStrength);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
