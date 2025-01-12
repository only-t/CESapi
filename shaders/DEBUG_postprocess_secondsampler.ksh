   DEBUG_postprocess_secondsampler      SAMPLER    +         postprocess_base.vs�   // Vertex shader

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD0;

void main()
{
	gl_Position = vec4(POSITION.xyz, 1.0);
	PS_TEXCOORD0.xy = TEXCOORD0.xy;
} "   DEBUG_postprocess_secondsampler.pst  // Fragment shader

#ifdef GL_ES
    precision highp float;
#endif

uniform sampler2D SAMPLER[2];
#define SRC_IMAGE        SAMPLER[0]
#define BLOOM_SAMPLER    SAMPLER[1]

varying vec2 PS_TEXCOORD0;

void main()
{
    vec4 src = texture2D(SRC_IMAGE, PS_TEXCOORD0.xy);
    vec4 mask = texture2D(BLOOM_SAMPLER, PS_TEXCOORD0.xy);

    gl_FragColor = mask;
}            