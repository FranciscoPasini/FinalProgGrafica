// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Portales/Umbral"
{
	Properties
	{
		_PortalView("Vista del otro lado", 2D) = "black" {}
		_Opening("Apertura", Float) = 1
		_EdgeWidth("Ancho del borde", Float) = 0.12
		_NoiseScale("Escala del ruido", Float) = 8
		_NoiseSpeed("Velocidad del ruido", Float) = 0.35
		_RippleStrength("Fuerza de ondas", Float) = 0.02
		_RippleFrequency("Frecuencia de ondas", Float) = 14
		_RippleSpeed("Velocidad de ondas", Float) = 2.5
		_Aberration("Aberración cromática", Float) = 0.006
		_ViewTint("Tinte de la vista", Color) = (1,1,1,1)
		_EdgeColor("Color del borde", Color) = (0,2.5,3,1)
		_PulseSpeed("Velocidad del pulso", Float) = 2
		_PulseAmount("Intensidad del pulso", Float) = 0.3

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _PortalView;
			uniform float _RippleFrequency;
			uniform float _RippleSpeed;
			uniform float _RippleStrength;
			uniform float _Aberration;
			uniform float4 _ViewTint;
			uniform float _NoiseScale;
			uniform float _NoiseSpeed;
			uniform float _EdgeWidth;
			uniform float _Opening;
			uniform float4 _EdgeColor;
			uniform float _PulseSpeed;
			uniform float _PulseAmount;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_1_0_g1 = i.ase_texcoord2.xy;
				float2 temp_output_6_0_g1 = ( temp_output_1_0_g1 - float2( 0.5,0.5 ) );
				float2 normalizeResult12_g1 = normalize( ( temp_output_6_0_g1 + float2( 1E-05,1E-05 ) ) );
				float2 temp_output_16_39 = normalizeResult12_g1;
				float2 break8_g1 = abs( temp_output_6_0_g1 );
				float temp_output_10_0_g1 = ( max( break8_g1.x , break8_g1.y ) * 2.0 );
				float temp_output_16_38 = temp_output_10_0_g1;
				float mulTime21 = _Time.y * _RippleSpeed;
				float2 temp_output_27_0 = ( (ase_screenPosNorm).xy + ( temp_output_16_39 * ( ( sin( ( ( temp_output_16_38 * _RippleFrequency ) - mulTime21 ) ) * _RippleStrength ) * temp_output_16_38 ) ) );
				float2 temp_output_30_0 = ( temp_output_16_39 * ( _Aberration * temp_output_16_38 ) );
				float3 appendResult36 = (float3(tex2D( _PortalView, ( temp_output_27_0 + temp_output_30_0 ) ).r , tex2D( _PortalView, temp_output_27_0 ).g , tex2D( _PortalView, ( temp_output_27_0 - temp_output_30_0 ) ).b));
				float mulTime14_g1 = _Time.y * _NoiseSpeed;
				float simplePerlin2D17_g1 = snoise( ( ( temp_output_1_0_g1 * _NoiseScale ) + mulTime14_g1 ) );
				simplePerlin2D17_g1 = simplePerlin2D17_g1*0.5 + 0.5;
				float temp_output_3_0_g1 = _EdgeWidth;
				float temp_output_20_0_g1 = ( temp_output_10_0_g1 + ( ( simplePerlin2D17_g1 - 0.5 ) * temp_output_3_0_g1 ) );
				float temp_output_2_0_g1 = _Opening;
				float temp_output_23_0_g1 = ( temp_output_2_0_g1 * ( 1.0 - temp_output_3_0_g1 ) );
				float temp_output_25_0_g1 = ( temp_output_23_0_g1 + ( temp_output_3_0_g1 * 0.5 ) );
				float temp_output_33_0_g1 = saturate( ( temp_output_2_0_g1 * 20.0 ) );
				float temp_output_16_0 = ( step( temp_output_20_0_g1 , temp_output_25_0_g1 ) * temp_output_33_0_g1 );
				float smoothstepResult28_g1 = smoothstep( ( temp_output_23_0_g1 - temp_output_3_0_g1 ) , temp_output_23_0_g1 , temp_output_20_0_g1);
				float smoothstepResult29_g1 = smoothstep( temp_output_23_0_g1 , temp_output_25_0_g1 , temp_output_20_0_g1);
				float temp_output_16_37 = ( ( smoothstepResult28_g1 * ( 1.0 - smoothstepResult29_g1 ) ) * temp_output_33_0_g1 );
				float mulTime39 = _Time.y * _PulseSpeed;
				clip( ( temp_output_16_0 + temp_output_16_37 ) - 0.5);
				
				
				finalColor = ( ( ( float4( appendResult36 , 0.0 ) * _ViewTint ) * temp_output_16_0 ) + ( ( temp_output_16_37 * _EdgeColor ) * ( ( sin( mulTime39 ) * _PulseAmount ) + 1.0 ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;21;1904;972;952;486;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;17;-3560,-710;Inherit;False;700;330;Borde del portal;2;15;16;;0.95,0.55,0.25,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-4200,-1130;Inherit;False;300;2150;Propiedades;13;1;2;3;4;5;6;7;8;9;10;11;12;13;;0.35,0.35,0.35,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-4160,-675;Inherit;False;Property;_Opening;Apertura;1;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-4160,-570;Inherit;False;Property;_EdgeWidth;Ancho del borde;2;0;Create;True;0;0;0;False;0;False;0.12;0.12;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-4160,-465;Inherit;False;Property;_NoiseScale;Escala del ruido;3;0;Create;True;0;0;0;False;0;False;8;8;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-4160,-360;Inherit;False;Property;_NoiseSpeed;Velocidad del ruido;4;0;Create;True;0;0;0;False;0;False;0.35;0.35;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;15;-3520,-630;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;28;-2440,-455;Inherit;False;1770;650;Ondas;10;18;19;20;21;22;23;24;25;26;27;;0.3,0.55,0.95,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-4160,-75;Inherit;False;Property;_RippleFrequency;Frecuencia de ondas;6;0;Create;True;0;0;0;False;0;False;14;14;1;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-4160,30;Inherit;False;Property;_RippleSpeed;Velocidad de ondas;7;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;-3120,-570;Inherit;False;SF_PortalEdge;-1;;1;d00f8f8ace7a76f4d9f8abb09eef879d;0;5;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;4;FLOAT;0;FLOAT;37;FLOAT;38;FLOAT2;39
Node;AmplifyShaderEditor.SimpleTimeNode;21;-2400,90;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2400,-90;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-2080,-30;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;23;-1840,-30;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4160,-180;Inherit;False;Property;_RippleStrength;Fuerza de ondas;5;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1600,-30;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;18;-2400,-375;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-4160,210;Inherit;False;Property;_Aberration;Aberración cromática;8;0;Create;True;0;0;0;False;0;False;0.006;0.006;0;0.03;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2440,255;Inherit;False;3162;920;Vista con aberracion cromatica;9;29;30;31;32;33;34;35;36;37;;0.3,0.8,0.55,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1360,-30;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1120,-180;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;19;-2080,-375;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2400,575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2080,575;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-880,-330;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;49;-2440,1235;Inherit;False;3962;595;Composicion;10;39;40;41;42;43;44;45;46;47;48;;0.85,0.3,0.55,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-4160,810;Inherit;False;Property;_PulseSpeed;Velocidad del pulso;11;0;Create;True;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-4160,-1050;Inherit;True;Property;_PortalView;Vista del otro lado;0;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;39;-2400,1705;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-560,425;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-560,875;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;40;-2080,1705;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-240,935;Inherit;True;Property;_TextureSample2;Texture Sample 2;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-4160,915;Inherit;False;Property;_PulseAmount;Intensidad del pulso;12;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-240,335;Inherit;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-240,635;Inherit;True;Property;_TextureSample1;Texture Sample 1;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;36;240,635;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;10;-4160,330;Inherit;False;Property;_ViewTint;Tinte de la vista;9;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-4160,570;Inherit;False;Property;_EdgeColor;Color del borde;10;0;Create;True;0;0;0;False;0;False;0,2.5,3,1;0,2.5,3,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1840,1705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;512,635;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1600,1705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;512,1645;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;768,1705;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;768,1315;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;1040,1465;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;1040,1705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;48;1312,1495;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1632,0;Float;False;True;-1;2;ASEMaterialInspector;100;1;Portales/Umbral;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;16;1;15;0
WireConnection;16;2;2;0
WireConnection;16;3;3;0
WireConnection;16;4;4;0
WireConnection;16;5;5;0
WireConnection;21;0;8;0
WireConnection;20;0;16;38
WireConnection;20;1;7;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;23;0;22;0
WireConnection;24;0;23;0
WireConnection;24;1;6;0
WireConnection;25;0;24;0
WireConnection;25;1;16;38
WireConnection;26;0;16;39
WireConnection;26;1;25;0
WireConnection;19;0;18;0
WireConnection;29;0;9;0
WireConnection;29;1;16;38
WireConnection;30;0;16;39
WireConnection;30;1;29;0
WireConnection;27;0;19;0
WireConnection;27;1;26;0
WireConnection;39;0;12;0
WireConnection;31;0;27;0
WireConnection;31;1;30;0
WireConnection;32;0;27;0
WireConnection;32;1;30;0
WireConnection;40;0;39;0
WireConnection;35;0;1;0
WireConnection;35;1;32;0
WireConnection;33;0;1;0
WireConnection;33;1;31;0
WireConnection;34;0;1;0
WireConnection;34;1;27;0
WireConnection;36;0;33;1
WireConnection;36;1;34;2
WireConnection;36;2;35;3
WireConnection;41;0;40;0
WireConnection;41;1;13;0
WireConnection;37;0;36;0
WireConnection;37;1;10;0
WireConnection;42;0;41;0
WireConnection;43;0;16;37
WireConnection;43;1;11;0
WireConnection;44;0;43;0
WireConnection;44;1;42;0
WireConnection;45;0;37;0
WireConnection;45;1;16;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;47;0;16;0
WireConnection;47;1;16;37
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;0;0;48;0
ASEEND*/
//CHKSM=46B147A50ECD44BDAE1E021BED900879846DE5F4