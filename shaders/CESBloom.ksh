   CESBloom      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                SAMPLER    +         PARAMS                            default_base.vsa  // Vertex shader

uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

attribute vec4 POS2D_UV; // x, y, u + samplerIndex * 2, v

varying vec3 PS_POS;
varying vec3 PS_TEXCOORD;

void main()
{
	vec3 POSITION = vec3(POS2D_UV.xy, 0.0);
	float samplerIndex = floor(POS2D_UV.z / 2.0);
	vec3 TEXCOORD0 = vec3(POS2D_UV.z - 2.0 * samplerIndex, POS2D_UV.w, samplerIndex);

	vec3 object_pos = POSITION.xyz;
	vec4 world_pos = MatrixW * vec4(object_pos, 1.0);

	mat4 mtxPV = MatrixP * MatrixV;
	gl_Position = mtxPV * world_pos;

	PS_TEXCOORD = TEXCOORD0;
	PS_POS = world_pos.xyz;
}    CESBloom.ps�  // Fragment shader

#ifdef GL_ES
    precision mediump float;
#endif

#ifdef TRIPLE_ATLAS
    uniform sampler2D SAMPLER[6];
#else
    uniform sampler2D SAMPLER[2];
#endif

uniform vec3 PARAMS;
#define BLOOM_TOGGLE PARAMS.z
#define ALPHA_TEST 0.05

varying vec3 PS_TEXCOORD;

void main()
{
    vec4 textureColor;
    vec2 coord = PS_TEXCOORD.xy;

    #ifdef TRIPLE_ATLAS
        if(PS_TEXCOORD.z < 0.5)
        {
            textureColor = texture2D(SAMPLER[0], coord);
        }
        else if(PS_TEXCOORD.z < 1.5)
        {
            textureColor = texture2D(SAMPLER[1], coord);
        }
        else
        {
            textureColor = texture2D(SAMPLER[5], coord);
        }
    #else
        if(PS_TEXCOORD.z < 0.5)
        {
            textureColor = texture2D(SAMPLER[0], coord);
        }
        else
        {
            textureColor = texture2D(SAMPLER[1], coord);
        }
    #endif

	if(BLOOM_TOGGLE == 1.0)
	{
		gl_FragColor.rgba = vec4(0.0, 0.0, 0.0, textureColor.a);
		return;
	}

    if(textureColor.a > ALPHA_TEST)
    {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    }
    else
    {
        discard;
    }
}                       