   CESbloom      SAMPLER    +         postprocess_base.vs�   // Vertex shader

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD0;

void main()
{
	gl_Position = vec4(POSITION.xyz, 1.0);
	PS_TEXCOORD0.xy = TEXCOORD0.xy;
}    CESbloom.psp  // Fragment shader

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec4 TIMEPARAMS;

uniform sampler2D SAMPLER[2];
#define SRC_IMAGE      SAMPLER[0]
#define MASKED_SAMPLER SAMPLER[1]

uniform vec4 SCREEN_PARAMS;
#define WINDOW_WIDTH  SCREEN_PARAMS.x
#define WINDOW_HEIGHT SCREEN_PARAMS.y 
#define SCREEN_RATIO WINDOW_WIDTH / WINDOW_HEIGHT

varying vec2 PS_TEXCOORD0;

void main()
{
    vec2 coords = PS_TEXCOORD0;
    vec4 bgColor = texture2D(SRC_IMAGE, coords);
    vec4 textureColor = texture2D(MASKED_SAMPLER, coords);

    gl_FragColor = vec4(bgColor.rgb + textureColor.rgb, 1.0);
}            