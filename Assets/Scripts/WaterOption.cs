using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterOption : MonoBehaviour
{
    const string SMOOTHNESS = "_Glossiness";
    const string METTALIC = "_Metallic";
    const string WAVE_A = "_WaveA";
    const string WAVE_B = "_WaveB";
    const string WAVE_C = "_WaveC";

    public Material grestnerMaterial;
    [Header("Grestner Option")]
    [Range(0, 1)]
    public float smoothness;
    [Range(0, 1)]
    public float metallic;
    public Vector4 waveA;
    public Vector4 waveB;
    public Vector4 waveC;

    void Update()
    {
    }
}
