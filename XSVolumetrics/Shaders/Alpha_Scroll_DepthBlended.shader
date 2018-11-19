Shader "Xiexe/Alpha_Scroll_DepthBlended"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[HDR]_Color("Color Tint", color) = (1,1,1,1)
		_ScrollSpeedX("Scroll Speed X", range(-1,1)) = 0
		_ScrollSpeedY("Scroll Speed Y", range(-1,1)) = 0
		_FadeStrength("Edge Fade", Range(1,5)) = 1
		_DistFade("Distance Fade", Range(0,1)) = 0.7
		_FadeAmt("Depth Blending", Range(0, 1)) = 0.1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		ZTest On
		Cull Back
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				float4 worldPos : TEXCOORD4;
				float3 viewDir : TEXCOORD5;
				float4 screenPos : TEXCOORD6;
			};

			sampler2D _MainTex, _CameraDepthTexture;
			float4 _MainTex_ST, _Color;
			float _ScrollSpeedX, _ScrollSpeedY, _FadeAmt, _DistFade, _FadeStrength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.worldNormal = UnityObjectToWorldNormal(float4(v.normal, 0.0));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.screenPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				o.viewDir = ObjSpaceViewDir(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float fadeAmt = 1-(_FadeAmt);
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float partZ = i.screenPos.z;
				float depthFade = saturate(fadeAmt * (sceneZ-partZ));

				float fade = pow(saturate(dot(normalize(i.normal), normalize(i.viewDir))), _FadeStrength);
				float distFade = 1-saturate(distance(i.worldPos.rgb,_WorldSpaceCameraPos) * _DistFade) ;
				float2 uv = float2(i.uv.x + (_Time.y * _ScrollSpeedX), i.uv.y + (_Time.y * _ScrollSpeedY)); 
				fixed4 col = tex2D(_MainTex, uv) ;
				col *= _Color * fade * (1-distFade) * depthFade;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;//saturate(distFade);//float4(col.xyz, col.w*ndv);
			}
			ENDCG
		}
	}
}
