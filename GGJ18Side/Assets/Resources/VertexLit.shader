// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Hidden/TerrainEngine/Details/Vertexlit" {
Properties {
	_WavingTint("Fade Color", Color) = (.7,.6,.5, 0)
    _MainTex ("Main Texture", 2D) = "white" {  }
_WaveAndDistance("Wave and distance", Vector) = (12, 3.6, 1, 1)
_Cutoff("Cutoff", float) = 0.5
}
SubShader {
    Tags { 
	
	"Queue" = "Geometry+200"
	"IgnoreProjector" = "True"
	"RenderType" = "Grass"
	"DisableBatching" = "True" }
    LOD 200
	ColorMask RGB

CGPROGRAM
#pragma surface surf Lambert vertex:WavingGrassVert addshadow 
#include "TerrainEngine.cginc"

sampler2D _MainTex;
fixed _Cutoff;

struct Input {
    float2 uv_MainTex;
    fixed4 color : COLOR;
};

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
    o.Albedo = c.rgb;
    o.Alpha = c.a;
	clip(o.Alpha - _Cutoff);
	o.Alpha *= IN.color.a;

}

ENDCG
}
SubShader {
    Tags { "RenderType"="Opaque" }
    Pass {
        Tags { "LightMode" = "Vertex" }
        ColorMaterial AmbientAndDiffuse
        Lighting On
        SetTexture [_MainTex] {
            constantColor (1,1,1,1)
            combine texture * primary DOUBLE, constant // UNITY_OPAQUE_ALPHA_FFP
        }
    }
    Pass {
        Tags { "LightMode" = "VertexLMRGBM" }
        ColorMaterial AmbientAndDiffuse
        BindChannels {
            Bind "Vertex", vertex
            Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
            Bind "texcoord", texcoord1 // main uses 1st uv
        }
        SetTexture [unity_Lightmap] {
            matrix [unity_LightmapMatrix]
            combine texture * texture alpha DOUBLE
        }
        SetTexture [_MainTex] {
            combine texture * previous QUAD, constant // UNITY_OPAQUE_ALPHA_FFP
        }
    }
}

Fallback "VertexLit"
}
