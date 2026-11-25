// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Portales/Abismo"
{
	Properties
	{
		_ColorA("Color A", Color) = (0.1,0.9,0.9,1)
		_ColorB("Color B", Color) = (0.5,0.1,0.9,1)
		_ColorC("Color C", Color) = (1,0.2,0.7,1)
		_PaletteSpeed("Velocidad de paleta", Float) = 0.15
		_Depth("Profundidad", Float) = 0.15
		_LayerIntensity("Intensidad de capas", Float) = 1
		_StarDensity("Densidad de estrellas", Float) = 12
		_SwirlSpeed("Velocidad de giro", Float) = 0.2
		_SwirlTwist("Torsión del remolino", Float) = 3
		_TwinkleSpeed("Velocidad de parpadeo", Float) = 3
		_TwinkleAmount("Intensidad de parpadeo", Float) = 0.6
		_EdgeColor("Color del borde", Color) = (1.5,0.4,3,1)
		_EdgeWidth("Ancho del borde", Float) = 0.08
		_NoiseScale("Escala del ruido", Float) = 8
		_NoiseSpeed("Velocidad del ruido", Float) = 0.35
		_Opening("Apertura", Float) = 1

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _StarDensity;
			uniform float _Depth;
			uniform float _SwirlSpeed;
			uniform float4 _ColorA;
			uniform float4 _ColorB;
			uniform float4 _ColorC;
			uniform float _TwinkleAmount;
			uniform float _TwinkleSpeed;
			uniform float _LayerIntensity;
			uniform float _SwirlTwist;
			uniform float _PaletteSpeed;
			uniform float _NoiseScale;
			uniform float _NoiseSpeed;
			uniform float _EdgeWidth;
			uniform float _Opening;
			uniform float4 _EdgeColor;
					float2 voronoihash24_g2( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi24_g2( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash24_g2( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash24_g3( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi24_g3( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash24_g3( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash24_g4( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi24_g4( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash24_g4( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
					float2 voronoihash24_g5( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi24_g5( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash24_g5( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
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

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
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
				float temp_output_3_0_g2 = 1.0;
				float time24_g2 = 0.0;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float3 temp_output_2_0_g2 = ase_tanViewDir;
				float mulTime16_g2 = _Time.y * _SwirlSpeed;
				float cos19_g2 = cos( ( mulTime16_g2 * ( temp_output_3_0_g2 * 0.3 ) ) );
				float sin19_g2 = sin( ( mulTime16_g2 * ( temp_output_3_0_g2 * 0.3 ) ) );
				float2 rotator19_g2 = mul( ( i.ase_texcoord1.xy - ( ( (temp_output_2_0_g2).xy / max( (temp_output_2_0_g2).z , 0.2 ) ) * ( _Depth * temp_output_3_0_g2 ) ) ) - float2( 0.5,0.5 ) , float2x2( cos19_g2 , -sin19_g2 , sin19_g2 , cos19_g2 )) + float2( 0.5,0.5 );
				float2 coords24_g2 = rotator19_g2 * ( _StarDensity * ( ( temp_output_3_0_g2 * 0.5 ) + 1.0 ) );
				float2 id24_g2 = 0;
				float2 uv24_g2 = 0;
				float voroi24_g2 = voronoi24_g2( coords24_g2, time24_g2, id24_g2, uv24_g2, 0 );
				float temp_output_3_0_g3 = 2.0;
				float time24_g3 = 0.0;
				float3 temp_output_2_0_g3 = ase_tanViewDir;
				float mulTime16_g3 = _Time.y * _SwirlSpeed;
				float cos19_g3 = cos( ( mulTime16_g3 * ( temp_output_3_0_g3 * 0.3 ) ) );
				float sin19_g3 = sin( ( mulTime16_g3 * ( temp_output_3_0_g3 * 0.3 ) ) );
				float2 rotator19_g3 = mul( ( i.ase_texcoord1.xy - ( ( (temp_output_2_0_g3).xy / max( (temp_output_2_0_g3).z , 0.2 ) ) * ( _Depth * temp_output_3_0_g3 ) ) ) - float2( 0.5,0.5 ) , float2x2( cos19_g3 , -sin19_g3 , sin19_g3 , cos19_g3 )) + float2( 0.5,0.5 );
				float2 coords24_g3 = rotator19_g3 * ( _StarDensity * ( ( temp_output_3_0_g3 * 0.5 ) + 1.0 ) );
				float2 id24_g3 = 0;
				float2 uv24_g3 = 0;
				float voroi24_g3 = voronoi24_g3( coords24_g3, time24_g3, id24_g3, uv24_g3, 0 );
				float temp_output_3_0_g4 = 3.0;
				float time24_g4 = 0.0;
				float3 temp_output_2_0_g4 = ase_tanViewDir;
				float mulTime16_g4 = _Time.y * _SwirlSpeed;
				float cos19_g4 = cos( ( mulTime16_g4 * ( temp_output_3_0_g4 * 0.3 ) ) );
				float sin19_g4 = sin( ( mulTime16_g4 * ( temp_output_3_0_g4 * 0.3 ) ) );
				float2 rotator19_g4 = mul( ( i.ase_texcoord1.xy - ( ( (temp_output_2_0_g4).xy / max( (temp_output_2_0_g4).z , 0.2 ) ) * ( _Depth * temp_output_3_0_g4 ) ) ) - float2( 0.5,0.5 ) , float2x2( cos19_g4 , -sin19_g4 , sin19_g4 , cos19_g4 )) + float2( 0.5,0.5 );
				float2 coords24_g4 = rotator19_g4 * ( _StarDensity * ( ( temp_output_3_0_g4 * 0.5 ) + 1.0 ) );
				float2 id24_g4 = 0;
				float2 uv24_g4 = 0;
				float voroi24_g4 = voronoi24_g4( coords24_g4, time24_g4, id24_g4, uv24_g4, 0 );
				float temp_output_3_0_g5 = 4.0;
				float time24_g5 = 0.0;
				float3 temp_output_2_0_g5 = ase_tanViewDir;
				float mulTime16_g5 = _Time.y * _SwirlSpeed;
				float cos19_g5 = cos( ( mulTime16_g5 * ( temp_output_3_0_g5 * 0.3 ) ) );
				float sin19_g5 = sin( ( mulTime16_g5 * ( temp_output_3_0_g5 * 0.3 ) ) );
				float2 rotator19_g5 = mul( ( i.ase_texcoord1.xy - ( ( (temp_output_2_0_g5).xy / max( (temp_output_2_0_g5).z , 0.2 ) ) * ( _Depth * temp_output_3_0_g5 ) ) ) - float2( 0.5,0.5 ) , float2x2( cos19_g5 , -sin19_g5 , sin19_g5 , cos19_g5 )) + float2( 0.5,0.5 );
				float2 coords24_g5 = rotator19_g5 * ( _StarDensity * ( ( temp_output_3_0_g5 * 0.5 ) + 1.0 ) );
				float2 id24_g5 = 0;
				float2 uv24_g5 = 0;
				float voroi24_g5 = voronoi24_g5( coords24_g5, time24_g5, id24_g5, uv24_g5, 0 );
				float mulTime59 = _Time.y * _TwinkleSpeed;
				float simplePerlin2D61 = snoise( ( ( i.ase_texcoord1.xy * float2( 20,20 ) ) + mulTime59 ) );
				simplePerlin2D61 = simplePerlin2D61*0.5 + 0.5;
				float2 break31 = ( i.ase_texcoord1.xy - float2( 0.5,0.5 ) );
				float2 temp_output_1_0_g1 = i.ase_texcoord1.xy;
				float2 temp_output_6_0_g1 = ( temp_output_1_0_g1 - float2( 0.5,0.5 ) );
				float2 break8_g1 = abs( temp_output_6_0_g1 );
				float temp_output_10_0_g1 = ( max( break8_g1.x , break8_g1.y ) * 2.0 );
				float temp_output_19_38 = temp_output_10_0_g1;
				float mulTime34 = _Time.y * _SwirlSpeed;
				float temp_output_36_0 = ( ( atan2( break31.y , break31.x ) + ( temp_output_19_38 * _SwirlTwist ) ) - mulTime34 );
				float2 appendResult39 = (float2(cos( temp_output_36_0 ) , sin( temp_output_36_0 )));
				float2 temp_output_40_0 = ( appendResult39 * temp_output_19_38 );
				float simplePerlin2D43 = snoise( ( temp_output_40_0 * float2( 3,3 ) ) );
				simplePerlin2D43 = simplePerlin2D43*0.5 + 0.5;
				float simplePerlin2D44 = snoise( ( temp_output_40_0 * float2( 6,6 ) ) );
				simplePerlin2D44 = simplePerlin2D44*0.5 + 0.5;
				float temp_output_47_0 = ( ( simplePerlin2D43 * 0.6 ) + ( simplePerlin2D44 * 0.4 ) );
				float4 lerpResult52 = lerp( _ColorA , _ColorB , temp_output_47_0);
				float mulTime48 = _Time.y * _PaletteSpeed;
				float4 lerpResult53 = lerp( lerpResult52 , _ColorC , ( ( sin( mulTime48 ) * 0.5 ) + 0.5 ));
				float smoothstepResult54 = smoothstep( 0.0 , 0.6 , temp_output_19_38);
				float mulTime14_g1 = _Time.y * _NoiseSpeed;
				float simplePerlin2D17_g1 = snoise( ( ( temp_output_1_0_g1 * _NoiseScale ) + mulTime14_g1 ) );
				simplePerlin2D17_g1 = simplePerlin2D17_g1*0.5 + 0.5;
				float temp_output_3_0_g1 = _EdgeWidth;
				float temp_output_20_0_g1 = ( temp_output_10_0_g1 + ( ( simplePerlin2D17_g1 - 0.5 ) * temp_output_3_0_g1 ) );
				float temp_output_2_0_g1 = _Opening;
				float temp_output_23_0_g1 = ( temp_output_2_0_g1 * ( 1.0 - temp_output_3_0_g1 ) );
				float temp_output_25_0_g1 = ( temp_output_23_0_g1 + ( temp_output_3_0_g1 * 0.5 ) );
				float temp_output_33_0_g1 = saturate( ( temp_output_2_0_g1 * 20.0 ) );
				float temp_output_19_0 = ( step( temp_output_20_0_g1 , temp_output_25_0_g1 ) * temp_output_33_0_g1 );
				float smoothstepResult28_g1 = smoothstep( ( temp_output_23_0_g1 - temp_output_3_0_g1 ) , temp_output_23_0_g1 , temp_output_20_0_g1);
				float smoothstepResult29_g1 = smoothstep( temp_output_23_0_g1 , temp_output_25_0_g1 , temp_output_20_0_g1);
				float temp_output_19_37 = ( ( smoothstepResult28_g1 * ( 1.0 - smoothstepResult29_g1 ) ) * temp_output_33_0_g1 );
				clip( ( temp_output_19_0 + temp_output_19_37 ) - 0.5);
				
				
				finalColor = ( ( ( float4( ( ( ( ( ( ( pow( saturate( ( 1.0 - ( voroi24_g2 * 3.0 ) ) ) , 18.0 ) * _ColorA.rgb ) / temp_output_3_0_g2 ) + ( ( pow( saturate( ( 1.0 - ( voroi24_g3 * 3.0 ) ) ) , 18.0 ) * _ColorB.rgb ) / temp_output_3_0_g3 ) ) + ( ( ( pow( saturate( ( 1.0 - ( voroi24_g4 * 3.0 ) ) ) , 18.0 ) * _ColorC.rgb ) / temp_output_3_0_g4 ) + ( ( pow( saturate( ( 1.0 - ( voroi24_g5 * 3.0 ) ) ) , 18.0 ) * _ColorA.rgb ) / temp_output_3_0_g5 ) ) ) * ( ( 1.0 - _TwinkleAmount ) + ( simplePerlin2D61 * _TwinkleAmount ) ) ) * _LayerIntensity ) , 0.0 ) + ( ( lerpResult53 * temp_output_47_0 ) * smoothstepResult54 ) ) * temp_output_19_0 ) + ( temp_output_19_37 * _EdgeColor ) );
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
Node;AmplifyShaderEditor.CommentaryNode;20;-4200,370;Inherit;False;700;330;Borde del portal;2;18;19;;0.95,0.55,0.25,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-3560,760;Inherit;False;3930;750;Nebulosa en remolino;27;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;54;55;56;;0.65,0.35,0.9,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-4840,-1430;Inherit;False;280;2225;Propiedades;16;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;;0.35,0.35,0.35,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;-4160,450;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-3520,840;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-4800,375;Inherit;False;Property;_EdgeWidth;Ancho del borde;12;0;Create;True;0;0;0;False;0;False;0.08;0.08;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-4800,480;Inherit;False;Property;_NoiseScale;Escala del ruido;13;0;Create;True;0;0;0;False;0;False;8;8;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-4800,585;Inherit;False;Property;_NoiseSpeed;Velocidad del ruido;14;0;Create;True;0;0;0;False;0;False;0.35;0.35;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-4800,690;Inherit;False;Property;_Opening;Apertura;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;31;-3280,840;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;19;-3760,510;Inherit;False;SF_PortalEdge;-1;;1;d00f8f8ace7a76f4d9f8abb09eef879d;0;5;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;4;FLOAT;0;FLOAT;37;FLOAT;38;FLOAT2;39
Node;AmplifyShaderEditor.RangedFloatNode;9;-4800,-180;Inherit;False;Property;_SwirlTwist;Torsión del remolino;8;0;Create;True;0;0;0;False;0;False;3;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3040,1035;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;32;-3040,840;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-4800,-285;Inherit;False;Property;_SwirlSpeed;Velocidad de giro;7;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;-3040,1200;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-2800,915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2560,975;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;38;-2320,1065;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;37;-2320,885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-2080,975;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1840,975;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2360,1570;Inherit;False;1290;425;Parpadeo;7;58;59;60;61;62;63;64;;0.3,0.8,0.55,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1600,1095;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;6,6;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1600,885;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;3,3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-4800,-75;Inherit;False;Property;_TwinkleSpeed;Velocidad de parpadeo;9;0;Create;True;0;0;0;False;0;False;3;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-4800,-720;Inherit;False;Property;_PaletteSpeed;Velocidad de paleta;3;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;43;-1360,885;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-2320,1830;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;48;-1600,1305;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2320,1650;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;20,20;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;29;-3800,-1505;Inherit;False;1690;1214;Capas de estrellas (parallax);8;21;22;23;24;25;26;27;28;;0.95,0.8,0.3,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-1360,1095;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1040,1095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-4800,-1140;Inherit;False;Property;_ColorB;Color B;1;0;Create;True;0;0;0;False;0;False;0.5,0.1,0.9,1;0.5,0.1,0.9,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-4800,-1350;Inherit;False;Property;_ColorA;Color A;0;0;Create;True;0;0;0;False;0;False;0.1,0.9,0.9,1;0.1,0.9,0.9,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-4800,-600;Inherit;False;Property;_Depth;Profundidad;4;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-4800,-390;Inherit;False;Property;_StarDensity;Densidad de estrellas;6;0;Create;True;0;0;0;False;0;False;12;12;3;60;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;49;-1360,1305;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-2080,1710;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;21;-3760,-1200;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;3;-4800,-930;Inherit;False;Property;_ColorC;Color C;2;0;Create;True;0;0;0;False;0;False;1,0.2,0.7,1;1,0.2,0.7,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1040,885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-800,975;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1120,1305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;61;-1840,1710;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-4800,30;Inherit;False;Property;_TwinkleAmount;Intensidad de parpadeo;10;0;Create;True;0;0;0;False;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;25;-3120,-525;Inherit;False;SF_StarLayer;-1;;5;261077d5c8865f14889ee19670049422;0;7;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;4;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;24;-3120,-825;Inherit;False;SF_StarLayer;-1;;4;261077d5c8865f14889ee19670049422;0;7;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;3;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;23;-3120,-1125;Inherit;False;SF_StarLayer;-1;;3;261077d5c8865f14889ee19670049422;0;7;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;2;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;22;-3120,-1425;Inherit;False;SF_StarLayer;-1;;2;261077d5c8865f14889ee19670049422;0;7;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1520,1710;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-2560,-720;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2560,-1320;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-880,1305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;52;-560,975;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;63;-1520,1890;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1280,1770;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;74;440,-830;Inherit;False;1498;1330;Composicion;8;66;67;68;69;70;71;72;73;;0.85,0.3,0.55,1;0;0
Node;AmplifyShaderEditor.LerpOp;53;-320,1125;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2320,-1020;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-80,1125;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;54;-560,1365;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4800,-495;Inherit;False;Property;_LayerIntensity;Intensidad de capas;5;0;Create;True;0;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;480,-750;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;720,-690;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;160,1215;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;-4800,165;Inherit;False;Property;_EdgeColor;Color del borde;11;0;Create;True;0;0;0;False;0;False;1.5,0.4,3,1;1.5,0.4,3,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;68;960,-300;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;1200,-150;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;960,375;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;1440,75;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;1440,375;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;73;1728,180;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2048,0;Float;False;True;-1;2;ASEMaterialInspector;100;1;Portales/Abismo;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;30;0;18;0
WireConnection;31;0;30;0
WireConnection;19;1;18;0
WireConnection;19;2;16;0
WireConnection;19;3;13;0
WireConnection;19;4;14;0
WireConnection;19;5;15;0
WireConnection;33;0;19;38
WireConnection;33;1;9;0
WireConnection;32;0;31;1
WireConnection;32;1;31;0
WireConnection;34;0;8;0
WireConnection;35;0;32;0
WireConnection;35;1;33;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;38;0;36;0
WireConnection;37;0;36;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;40;0;39;0
WireConnection;40;1;19;38
WireConnection;42;0;40;0
WireConnection;41;0;40;0
WireConnection;43;0;41;0
WireConnection;59;0;10;0
WireConnection;48;0;4;0
WireConnection;58;0;18;0
WireConnection;44;0;42;0
WireConnection;46;0;44;0
WireConnection;49;0;48;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;45;0;43;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;50;0;49;0
WireConnection;61;0;60;0
WireConnection;25;1;18;0
WireConnection;25;2;21;0
WireConnection;25;4;5;0
WireConnection;25;5;7;0
WireConnection;25;6;8;0
WireConnection;25;7;1;0
WireConnection;24;1;18;0
WireConnection;24;2;21;0
WireConnection;24;4;5;0
WireConnection;24;5;7;0
WireConnection;24;6;8;0
WireConnection;24;7;3;0
WireConnection;23;1;18;0
WireConnection;23;2;21;0
WireConnection;23;4;5;0
WireConnection;23;5;7;0
WireConnection;23;6;8;0
WireConnection;23;7;2;0
WireConnection;22;1;18;0
WireConnection;22;2;21;0
WireConnection;22;4;5;0
WireConnection;22;5;7;0
WireConnection;22;6;8;0
WireConnection;22;7;1;0
WireConnection;62;0;61;0
WireConnection;62;1;11;0
WireConnection;27;0;24;0
WireConnection;27;1;25;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;51;0;50;0
WireConnection;52;0;1;0
WireConnection;52;1;2;0
WireConnection;52;2;47;0
WireConnection;63;0;11;0
WireConnection;64;0;63;0
WireConnection;64;1;62;0
WireConnection;53;0;52;0
WireConnection;53;1;3;0
WireConnection;53;2;51;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;55;0;53;0
WireConnection;55;1;47;0
WireConnection;54;0;19;38
WireConnection;66;0;28;0
WireConnection;66;1;64;0
WireConnection;67;0;66;0
WireConnection;67;1;6;0
WireConnection;56;0;55;0
WireConnection;56;1;54;0
WireConnection;68;0;67;0
WireConnection;68;1;56;0
WireConnection;69;0;68;0
WireConnection;69;1;19;0
WireConnection;70;0;19;37
WireConnection;70;1;12;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;72;0;19;0
WireConnection;72;1;19;37
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;0;0;73;0
ASEEND*/
//CHKSM=F83EC64FDD17301E58337A6E934B2FEAD81769F3