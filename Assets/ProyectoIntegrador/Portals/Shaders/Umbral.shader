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
				float2 temp_output_17_42 = normalizeResult12_g1;
				float2 break8_g1 = abs( temp_output_6_0_g1 );
				float temp_output_10_0_g1 = ( max( break8_g1.x , break8_g1.y ) * 2.0 );
				float temp_output_17_41 = temp_output_10_0_g1;
				float mulTime23 = _Time.y * _RippleSpeed;
				float2 temp_output_29_0 = ( (ase_screenPosNorm).xy + ( temp_output_17_42 * ( ( sin( ( ( temp_output_17_41 * _RippleFrequency ) - mulTime23 ) ) * _RippleStrength ) * temp_output_17_41 ) ) );
				float2 temp_output_33_0 = ( temp_output_17_42 * ( _Aberration * temp_output_17_41 ) );
				float3 appendResult39 = (float3(tex2D( _PortalView, ( temp_output_29_0 + temp_output_33_0 ) ).r , tex2D( _PortalView, temp_output_29_0 ).g , tex2D( _PortalView, ( temp_output_29_0 - temp_output_33_0 ) ).b));
				float mulTime15_g1 = _Time.y * _NoiseSpeed;
				float simplePerlin2D18_g1 = snoise( ( ( temp_output_1_0_g1 * _NoiseScale ) + mulTime15_g1 ) );
				simplePerlin2D18_g1 = simplePerlin2D18_g1*0.5 + 0.5;
				float temp_output_3_0_g1 = _EdgeWidth;
				float temp_output_21_0_g1 = ( temp_output_10_0_g1 + ( ( simplePerlin2D18_g1 - 0.5 ) * temp_output_3_0_g1 ) );
				float temp_output_2_0_g1 = _Opening;
				float temp_output_25_0_g1 = ( temp_output_2_0_g1 * ( 1.0 - temp_output_3_0_g1 ) );
				float temp_output_27_0_g1 = ( temp_output_25_0_g1 + ( temp_output_3_0_g1 * 0.5 ) );
				float temp_output_35_0_g1 = saturate( ( temp_output_2_0_g1 * 20.0 ) );
				float temp_output_17_0 = ( step( temp_output_21_0_g1 , temp_output_27_0_g1 ) * temp_output_35_0_g1 );
				float smoothstepResult30_g1 = smoothstep( ( temp_output_25_0_g1 - temp_output_3_0_g1 ) , temp_output_25_0_g1 , temp_output_21_0_g1);
				float smoothstepResult31_g1 = smoothstep( temp_output_25_0_g1 , temp_output_27_0_g1 , temp_output_21_0_g1);
				float temp_output_17_40 = ( ( smoothstepResult30_g1 * ( 1.0 - smoothstepResult31_g1 ) ) * temp_output_35_0_g1 );
				float mulTime43 = _Time.y * _PulseSpeed;
				clip( ( temp_output_17_0 + temp_output_17_40 ) - 0.5);
				
				
				finalColor = ( ( ( float4( appendResult39 , 0.0 ) * _ViewTint ) * temp_output_17_0 ) + ( ( temp_output_17_40 * _EdgeColor ) * ( ( sin( mulTime43 ) * _PulseAmount ) + 1.0 ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
1928;25;1904;972;952;486;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;19;-3560,-814;Inherit;False;700;434;Borde del portal;3;16;17;18;;0.95,0.55,0.25,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-4200,-1251;Inherit;False;420;2271;Propiedades;14;1;2;3;4;5;6;7;8;9;10;11;12;13;14;;0.35,0.35,0.35,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-4160,-675;Inherit;False;Property;_Opening;Apertura;1;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-4160,-570;Inherit;False;Property;_EdgeWidth;Ancho del borde;2;0;Create;True;0;0;0;False;0;False;0.12;0.12;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-4160,-465;Inherit;False;Property;_NoiseScale;Escala del ruido;3;0;Create;True;0;0;0;False;0;False;8;8;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-4160,-360;Inherit;False;Property;_NoiseSpeed;Velocidad del ruido;4;0;Create;True;0;0;0;False;0;False;0.35;0.35;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;16;-3520,-630;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;31;-2440,-576;Inherit;False;1770;771;Ondas;11;20;21;22;23;24;25;26;27;28;29;30;;0.3,0.55,0.95,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-4160,-75;Inherit;False;Property;_RippleFrequency;Frecuencia de ondas;6;0;Create;True;0;0;0;False;0;False;14;14;1;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-4160,30;Inherit;False;Property;_RippleSpeed;Velocidad de ondas;7;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;17;-3120,-570;Inherit;False;SF_PortalEdge;-1;;1;d00f8f8ace7a76f4d9f8abb09eef879d;0;5;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;4;FLOAT;0;FLOAT;40;FLOAT;41;FLOAT2;42
Node;AmplifyShaderEditor.SimpleTimeNode;23;-2400,90;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2400,-90;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-2080,-30;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;25;-1840,-30;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4160,-180;Inherit;False;Property;_RippleStrength;Fuerza de ondas;5;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1600,-30;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-4160,210;Inherit;False;Property;_Aberration;Aberración cromática;8;0;Create;True;0;0;0;False;0;False;0.006;0.006;0;0.03;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;20;-2400,-375;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;42;-2440,255;Inherit;False;3162;1041;Vista con aberracion cromatica;10;32;33;34;35;36;37;38;39;40;41;;0.3,0.8,0.55,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1360,-30;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2400,696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-2080,-375;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1120,-180;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-880,-330;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2080,696;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2440,1356;Inherit;False;3962;716;Composicion;11;43;44;45;46;47;48;49;50;51;52;53;;0.85,0.3,0.55,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-4160,810;Inherit;False;Property;_PulseSpeed;Velocidad del pulso;11;0;Create;True;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-560,546;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-560,996;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;43;-2400,1947;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-4160,-1050;Inherit;True;Property;_PortalView;Vista del otro lado;0;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;37;-240,756;Inherit;True;Property;_TextureSample1;Texture Sample 1;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-4160,915;Inherit;False;Property;_PulseAmount;Intensidad del pulso;12;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-240,456;Inherit;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;44;-2080,1947;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-240,1056;Inherit;True;Property;_TextureSample2;Texture Sample 2;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1840,1947;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-4160,570;Inherit;False;Property;_EdgeColor;Color del borde;10;0;Create;True;0;0;0;False;0;False;0,2.5,3,1;0,2.5,3,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-4160,330;Inherit;False;Property;_ViewTint;Tinte de la vista;9;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;39;240,756;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1600,1947;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;512,756;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;512,1887;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;768,1557;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;768,1947;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;1040,1707;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;1040,1947;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;52;1312,1737;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;53;-2400,1436;Inherit;False;340;97;Composicion;;1,1,1,1;Vista adentro de la máscara + borde HDR que respira. Clip descarta todo lo que queda afuera del portal.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;18;-3520,-734;Inherit;False;340;80;Borde del portal;;1,1,1,1;SF_PortalEdge con las UV del quad: devuelve Mask, Rim, Dist y Dir.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;30;-2400,-496;Inherit;False;340;97;Ondas;;1,1,1,1;Posición en pantalla + una onda que nace en el centro. Leer en pantalla mantiene la perspectiva del otro lado.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;14;-4160,-1171;Inherit;False;340;97;Propiedades;;1,1,1,1;Parámetros del material. La vista del otro lado (_PortalView) la carga el script LinkedPortal en cada frame.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;41;-2400,335;Inherit;False;340;97;Vista con aberracion cromatica;;1,1,1,1;Lee la vista 3 veces corrida: R hacia afuera, G en el lugar, B hacia adentro. El corrimiento crece hacia el borde.;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1632,0;Float;False;True;-1;2;ASEMaterialInspector;100;1;Portales/Umbral;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;17;1;16;0
WireConnection;17;2;2;0
WireConnection;17;3;3;0
WireConnection;17;4;4;0
WireConnection;17;5;5;0
WireConnection;23;0;8;0
WireConnection;22;0;17;41
WireConnection;22;1;7;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;25;0;24;0
WireConnection;26;0;25;0
WireConnection;26;1;6;0
WireConnection;27;0;26;0
WireConnection;27;1;17;41
WireConnection;32;0;9;0
WireConnection;32;1;17;41
WireConnection;21;0;20;0
WireConnection;28;0;17;42
WireConnection;28;1;27;0
WireConnection;29;0;21;0
WireConnection;29;1;28;0
WireConnection;33;0;17;42
WireConnection;33;1;32;0
WireConnection;34;0;29;0
WireConnection;34;1;33;0
WireConnection;35;0;29;0
WireConnection;35;1;33;0
WireConnection;43;0;12;0
WireConnection;37;0;1;0
WireConnection;37;1;29;0
WireConnection;36;0;1;0
WireConnection;36;1;34;0
WireConnection;44;0;43;0
WireConnection;38;0;1;0
WireConnection;38;1;35;0
WireConnection;45;0;44;0
WireConnection;45;1;13;0
WireConnection;39;0;36;1
WireConnection;39;1;37;2
WireConnection;39;2;38;3
WireConnection;46;0;45;0
WireConnection;40;0;39;0
WireConnection;40;1;10;0
WireConnection;47;0;17;40
WireConnection;47;1;11;0
WireConnection;49;0;40;0
WireConnection;49;1;17;0
WireConnection;48;0;47;0
WireConnection;48;1;46;0
WireConnection;50;0;49;0
WireConnection;50;1;48;0
WireConnection;51;0;17;0
WireConnection;51;1;17;40
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;0;0;52;0
ASEEND*/
//CHKSM=8B17681A591D35A937C789D880B1671C01670426