// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'

Shader "Custom/DistanceFog"
{
    Properties
    {
        _FogColor ("Fog Color", Color) = (0.4, 0.6, 0.8, 1)
        _FogDensity ("Fog Density", Range(0, 0.05)) = 0.02
        _FogStart ("Fog Start Distance", Range(0, 200)) = 20
        _FogEnd ("Fog End Distance", Range(10, 1000)) = 400
        _HeightFogDensity ("Height Fog Density", Range(0, 1)) = 0.5
        _HeightFogStart ("Height Fog Start", Float) = 0
        _HeightFogEnd ("Height Fog End", Float) = 50
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            float4 _FogColor;
            float _FogDensity;
            float _FogStart;
            float _FogEnd;
            float _HeightFogDensity;
            float _HeightFogStart;
            float _HeightFogEnd;

            // Fog logic
            fixed4 frag(v2f_img i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);

                // Skip fog if depth invalid (sky)
                if (depth >= _FogEnd * 1.2) return col;

                // Distance fog factor
                float distFog = saturate((depth - _FogStart) / (_FogEnd - _FogStart));
                distFog = 1.0 - exp(-distFog * (_FogDensity * 100.0));

                // Reconstruct approximate world position
                float4 clipPos;
                clipPos.xy = i.uv * 2.0 - 1.0;
                clipPos.z = depth;
                clipPos.w = 1.0;
                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                viewPos /= viewPos.w;
                float3 worldPos = mul(unity_CameraToWorld, float4(viewPos.xyz,1)).xyz;

                // Height fog
                float heightFog = saturate((_HeightFogEnd - worldPos.y) / (_HeightFogEnd - _HeightFogStart));
                heightFog *= _HeightFogDensity;

                // Combine fog factors
                float fogFactor = saturate(distFog + heightFog * 0.5);

                // Preserve near-surface reflections
                if (depth < 15.0) fogFactor *= saturate((depth - 5.0) / 10.0);

                col.rgb = lerp(col.rgb, _FogColor.rgb, fogFactor);
                return col;
            }
            ENDCG
        }
    }
}
