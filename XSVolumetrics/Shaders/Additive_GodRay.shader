Shader "Xiexe/Additive_GodRay"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR]_Color("Color Tint", Color) = (1,1,1,1)
		_PulseSpeed("Pulse Speed", Range(0,2)) = 0
		_FadeStrength("Edge Fade", Range(1,5)) = 1
		_DistFade("Distance Fade", Range(0,1)) = 0.7
		_FadeAmt("Depth Blending", Range(0, 1)) = 0.1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		Blend One One
		Cull Off
		ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD2;
				float4 color : TEXCOORD3;
				float4 normal : TEXCOORD4;
				float3 viewDir : TEXCOORD5;
				float4 screenPos : TEXCOORD6;
			};

			sampler2D _MainTex, _CameraDepthTexture;
			float4 _MainTex_ST, _Color;
			float _PulseSpeed;
			float _FadeStrength, _FadeAmt, _DistFade;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.color = v.color;
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex);
				o.screenPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float fadeAmt = 1-(_FadeAmt);
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float partZ = i.screenPos.z;
				float depthFade = saturate(fadeAmt * (sceneZ-partZ));

				float distFade = saturate(distance(i.worldPos.rgb,_WorldSpaceCameraPos) * _DistFade) ;
				float fade = pow(saturate(dot(normalize(i.normal), normalize(i.viewDir))), _FadeStrength);
				float2 uv = float2(i.uv.x, i.uv.y); 
				fixed4 col = tex2D(_MainTex, uv) * ((sin(_Time.y * _PulseSpeed) * 0.5 + 1)) * i.color;
				col *= fade;
				col *= depthFade;
				col *= distFade;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col * _Color;
			}
			ENDCG
		}
	}
}
