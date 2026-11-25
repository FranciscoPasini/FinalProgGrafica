// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OutlineCard"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_MainTexture("MainTexture", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		_OutlineWidth("OutlineWidth", Float) = 0.1
		_Float0("Float 0", Float) = 6.283185
		_Speed("Speed", Float) = 1.5
		_Sharpness("Sharpness", Float) = 8
		_Color0("Color 0", Color) = (0,0.8009291,0.990566,0)
		_MirrorSpeed("MirrorSpeed", Float) = 0.8
		_MirrorWidth("MirrorWidth", Float) = 12
		_MirrorSharpness("MirrorSharpness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform sampler2D _TextureSample0;
			uniform float _OutlineWidth;
			uniform sampler2D _TextureSample1;
			uniform sampler2D _TextureSample2;
			uniform sampler2D _TextureSample3;
			uniform float _Float0;
			uniform float _Speed;
			uniform float _Sharpness;
			uniform float4 _Color0;
			uniform float _MirrorSpeed;
			uniform float _MirrorWidth;
			uniform float _MirrorSharpness;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_MainTexture = IN.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTexture, uv_MainTexture );
				float2 texCoord18 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break56 = ( texCoord18 - float2( 0.5,0.5 ) );
				float2 break74 = texCoord18;
				float4 color86 = IsGammaSpace() ? float4(0,0,0,1) : float4(0,0,0,1);
				
				fixed4 c = ( ( ( ( tex2DNode2 * IN.color ) * ( tex2DNode2.a * IN.color.a ) ) + ( ( saturate( ( ( tex2D( _TextureSample0, ( texCoord18 + ( _OutlineWidth * float2( 0,1 ) ) ) ).a + tex2D( _TextureSample1, ( texCoord18 + ( _OutlineWidth * float2( 0,-1 ) ) ) ).a + tex2D( _TextureSample2, ( texCoord18 + ( _OutlineWidth * float2( 1,0 ) ) ) ).a + tex2D( _TextureSample3, ( texCoord18 + ( _OutlineWidth * float2( -1,0 ) ) ) ).a ) - tex2DNode2.a ) ) * pow( saturate( cos( ( ( ( atan2( break56.y , break56.x ) / _Float0 ) + ( _Time.y * _Speed ) ) * _Float0 ) ) ) , _Sharpness ) ) * _Color0 ) ) + ( pow( saturate( cos( ( ( ( break74.x + break74.y ) - ( _Time.y * _MirrorSpeed ) ) * _MirrorWidth ) ) ) , _MirrorSharpness ) * color86 ) );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
383;73;1178;704;884.083;666.1706;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;90;-371.5206,1089.524;Inherit;False;1646.408;564.9978;Luz giratoria sobre el borde;17;53;52;56;59;60;58;54;57;61;64;62;63;65;66;68;67;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1087.507,111.2846;Inherit;False;1872.316;858.6086;Máscara del outline;22;18;32;34;35;33;31;37;40;39;38;42;43;44;41;45;46;48;47;49;51;50;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;53;-321.5206,1231.89;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-635.4666,639.1974;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;52;-142.145,1140.375;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;56;4.385612,1139.524;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;33;-1032.498,304.2844;Inherit;False;Constant;_Down;Down;3;0;Create;True;0;0;0;False;0;False;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ATan2OpNode;54;160.8792,1140.589;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-69.92996,1446.884;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-50.35226,1539.361;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;141.3856,1278.524;Inherit;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;6.283185;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1037.507,697.0051;Inherit;False;Property;_OutlineWidth;OutlineWidth;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;34;-1032.784,428.2844;Inherit;False;Constant;_Right;Right;3;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;35;-1031.498,552.2847;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;32;-1030.498,185.2846;Inherit;False;Constant;_Top;Top;3;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-740.4984,262.2844;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-742.4984,370.2844;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-747.4984,161.2846;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;91;-618.3093,1783.077;Inherit;False;1600.166;638.9152;Efecto de espejo diagonal;15;76;78;74;75;77;80;79;81;82;83;85;86;84;87;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;326.3857,1139.524;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-737.4984,502.2846;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;147.6478,1468.361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-567.0005,2064.686;Inherit;False;Property;_MirrorSpeed;MirrorSpeed;10;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-368.9469,521.0463;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-370.9469,410.0464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-365.9469,196.0465;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;470.6478,1306.361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;64;463.6478,1417.361;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-365.9469,301.0464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-539.5206,1833.077;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;76;-568.3093,1945.612;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-189.2891,739.8932;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;2115d9153108e3e4db79bd7b010e2018;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;16;-891.63,-337.2749;Inherit;False;803.3148;439.8446;Color Base y Transparencia;5;2;5;6;7;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;47;-194.7072,552.0677;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;2115d9153108e3e4db79bd7b010e2018;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;-200.1252,362.4354;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;2115d9153108e3e4db79bd7b010e2018;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;658.6478,1304.361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-198.3194,169.1921;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;2115d9153108e3e4db79bd7b010e2018;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-353.7118,1833.078;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-358.9459,1987.484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-165.2841,2079.081;Inherit;False;Property;_MirrorWidth;MirrorWidth;11;0;Create;True;0;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-145.6564,1907.664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;260.5052,417.2589;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-841.63,-287.2749;Inherit;True;Property;_MainTexture;MainTexture;0;0;Create;True;0;0;0;False;0;False;-1;2115d9153108e3e4db79bd7b010e2018;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;65;806.6478,1310.361;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;25.75978,1997.951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;453.3193,451.0488;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;934.6478,1308.361;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;945.6478,1419.361;Inherit;False;Property;_Sharpness;Sharpness;8;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;67;1097.648,1301.361;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;5;-723.8276,-100.2303;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;51;613.2292,450.5514;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;82;194.5591,2009.728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;83;330.6197,2004.977;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;292.5811,2144.907;Inherit;False;Property;_MirrorSharpness;MirrorSharpness;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-466.7256,-176.133;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;70;1546.573,979.5398;Inherit;False;Property;_Color0;Color 0;9;0;Create;True;0;0;0;False;0;False;0,0.8009291,0.990566,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-463.7559,-46.41788;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;1499.546,731.2804;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;86;547.9831,2214.192;Inherit;False;Constant;_Color1;Color 1;13;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-255.8552,-94.92791;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;84;522.1712,2052.526;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;1755.294,908.2023;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;814.3166,2145.342;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;1946.605,881.4407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;95;-477.083,-515.1706;Inherit;False;385;174;;;1,1,1,1;desplaza las coordenadas UV en las 4 direcciones (Up, Down, Left, Right) escaladas por OutlineSize, muestrea el alfa en cada dirección, suma los 4 alfas, resta el alfa original de la textura y satura el resultado entre 0 y 1 para aislar solo el borde.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;94;352.917,741.8294;Inherit;False;402;152;;;1,1,1,1;desplaza las coordenadas UV en las 4 direcciones (Up, Down, Left, Right) escaladas por OutlineSize, muestrea el alfa en cada dirección, suma los 4 alfas, resta el alfa original de la textura y satura el resultado entre 0 y 1 para aislar solo el borde.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;92;242.7551,1830.708;Inherit;False;582;138;;;1,1,1,1;Suma las coordenadas X + Y de las UV para obtener un eje diagonal, lo desplaza en el tiempo restando Time * MirrorSpeed, lo escala con MirrorWidth, le aplica Cos -> Saturate -> Power(MirrorSharpness) para formar la franja de reflejo y lo multiplica por Color 1 antes de sumarlo al resultado final.;0;0
Node;AmplifyShaderEditor.StickyNoteNode;93;576.8765,1130.693;Inherit;False;561;146;;;1,1,1,1;centra las UV restando (0.5, 0.5), calcula el ángulo polar con ATan2 dividido por 2π, lo anima sumando Time * Speed, genera un pulso periódico con Cos + Saturate y lo afina con Power(Sharpness). Luego multiplica ese pulso por la máscara del borde y por Color 0 (celeste) antes de sumarlo al sprite base.;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;2051.387,1284.69;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;14;2251.167,1210.559;Float;False;True;-1;2;ASEMaterialInspector;0;6;OutlineCard;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;52;0;18;0
WireConnection;52;1;53;0
WireConnection;56;0;52;0
WireConnection;54;0;56;1
WireConnection;54;1;56;0
WireConnection;38;0;31;0
WireConnection;38;1;33;0
WireConnection;39;0;31;0
WireConnection;39;1;34;0
WireConnection;37;0;31;0
WireConnection;37;1;32;0
WireConnection;57;0;54;0
WireConnection;57;1;58;0
WireConnection;40;0;31;0
WireConnection;40;1;35;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;44;0;18;0
WireConnection;44;1;40;0
WireConnection;43;0;18;0
WireConnection;43;1;39;0
WireConnection;41;0;18;0
WireConnection;41;1;37;0
WireConnection;62;0;57;0
WireConnection;62;1;61;0
WireConnection;64;0;58;0
WireConnection;42;0;18;0
WireConnection;42;1;38;0
WireConnection;74;0;18;0
WireConnection;48;1;44;0
WireConnection;47;1;43;0
WireConnection;46;1;42;0
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;45;1;41;0
WireConnection;75;0;74;0
WireConnection;75;1;74;1
WireConnection;77;0;76;0
WireConnection;77;1;78;0
WireConnection;79;0;75;0
WireConnection;79;1;77;0
WireConnection;49;0;45;4
WireConnection;49;1;46;4
WireConnection;49;2;47;4
WireConnection;49;3;48;4
WireConnection;65;0;63;0
WireConnection;81;0;79;0
WireConnection;81;1;80;0
WireConnection;50;0;49;0
WireConnection;50;1;2;4
WireConnection;66;0;65;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;51;0;50;0
WireConnection;82;0;81;0
WireConnection;83;0;82;0
WireConnection;6;0;2;0
WireConnection;6;1;5;0
WireConnection;7;0;2;4
WireConnection;7;1;5;4
WireConnection;69;0;51;0
WireConnection;69;1;67;0
WireConnection;15;0;6;0
WireConnection;15;1;7;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;87;0;84;0
WireConnection;87;1;86;0
WireConnection;72;0;15;0
WireConnection;72;1;71;0
WireConnection;88;0;72;0
WireConnection;88;1;87;0
WireConnection;14;0;88;0
ASEEND*/
//CHKSM=CE31A4C060EB1A18C2C8E186B0F51A141F7A7E5B