Shader "Custom/GerstnerWave"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Header(Wave)]
        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _WaveB ("Wave B", Vector) = (0, 1, 0.25, 20)
        _WaveC ("Wave C", Vector) = (1, 1, 0.15, 10)

        [Header(Water Shading)]
        _ReflectionTex ("Reflection Cubemap", CUBE) = "" {}
        _ShallowColor ("Shallow Water Color", Color) = (0.1, 0.4, 0.6, 1)
        _DeepColor ("Deep Water Color", Color) = (0.0, 0.1, 0.3, 1)
        _FresnelPower ("Fresnel Power", Range(1, 8)) = 3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert 
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos : POSITION;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        // float _Amplitude;
        float _Steepness;
        float _Wavelength;
        // float _Speed;
        float2 _Direction;
        float4 _WaveA;
        float4 _WaveB;
        float4 _WaveC;
        float _FresnelPower;
        samplerCUBE _ReflectionTex;
        fixed4 _ShallowColor;
        fixed4 _DeepColor;


        float3 GerstnerWave (float4 wave, float3 p, inout float3 tangent, inout float3 binormal) {
            float steepness = wave.z;
            float wavelength = wave.w;
            float k = 2 * UNITY_PI / wavelength;
            float c = sqrt(9.8 / k);
            float2 d = normalize(wave.xy);
            float f = k * (dot(d, p.xz) - c * _Time.y);
            float a = steepness / k;

            tangent += float3 (
                -d.x * d.x * (steepness * sin(f)),
                d.x * (steepness * cos(f)),
                -d.x * d.y * (steepness * sin(f))
            ); 

            binormal += float3 (
                d.x * d.y * (steepness * sin(f)),
                d.y * (steepness * cos(f)),
                -d.y * d.y * (steepness * sin(f))
            );

            return float3(
                d.x * (a * cos(f)),
                a * sin(f),
                d.y * (a * cos(f))
            );
        }

        void vert(inout appdata_full vertexData)
        {
            float3 gridPoint = vertexData.vertex.xyz;
            float3 tangent = float3 (1,0,0);
            float3 binormal = float3 (0,0,1);
            float3 p = gridPoint;
            p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            vertexData.vertex.xyz = p;
            vertexData.normal = normal;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            // ambil arah pandang & normal permukaan
            float3 viewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float3 normal = normalize(o.Normal);

            // Fresnel 
            float fresnel = pow(1 - saturate(dot(viewDir, normal)), _FresnelPower);

            // Reflection
            float3 reflDir = reflect(-viewDir, normal);
            float3 reflection = texCUBE(_ReflectionTex, reflDir).rgb;

            // deep color
            float depthFactor = saturate((IN.worldPos.y + 5) / 10);
            float3 depthColor = lerp(_DeepColor.rgb, _ShallowColor.rgb, depthFactor);

			o.Albedo = lerp(depthColor, reflection, fresnel);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
