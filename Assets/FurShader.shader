Shader "Custom/FurShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		NoiseSize ("NoiseSize", Range(10, 10000)) = 1000.0
		NoiseVariance ("NoiseVariance", Range(-1, 1)) = 0.6
		NoiseSmooth ("NoiseSmooth", Range(0, 1)) = 0.0
	}
	SubShader {
		Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" } 
		
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
		#pragma multi_compile_instancing

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 5.0

float3 hash3( float2 p ){
    float3 q = float3( dot(p,float2(127.1,311.7)), 
				   dot(p,float2(269.5,183.3)), 
				   dot(p,float2(419.2,371.9)) );
	return frac(sin(q)*43758.5453);
}

float iqnoise( in float2 x, float u, float v ){
    float2 p = floor(x);
    float2 f = frac(x);
		
	float k = 1.0+63.0*pow(1.0-v,4.0);
	
	float va = 0.0;
	float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        float2 g = float2( float(i),float(j) );
		float3 o = hash3( p + g )*float3(u,u,1.0);
		float2 r = g - f + o.xy;
		float d = dot(r,r);
		float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
		va += o.z*ww;
		wt += ww;
    }
	
    return va/wt;
}

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		uniform int count;
		float NoiseSize;
		float NoiseSmooth;
		float NoiseVariance;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert (inout appdata_full v) {
		  UNITY_SETUP_INSTANCE_ID(v)
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float random = iqnoise(IN.uv_MainTex*NoiseSize, NoiseVariance, NoiseSmooth);
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb*random;
			o.Alpha = 1.0;
			#ifdef UNITY_INSTANCING_ENABLED
			if (random < 0.5 + 0.5/float(count) * unity_InstanceID)
				o.Alpha = -0.00001;
			#endif

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			clip(o.Alpha);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
