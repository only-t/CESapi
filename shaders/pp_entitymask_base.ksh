   pp_entitymask_base      SAMPLER    +         postprocess_base.vs�   // Vertex shader

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD0;

void main()
{
	gl_Position = vec4(POSITION.xyz, 1.0);
	PS_TEXCOORD0.xy = TEXCOORD0.xy;
}    pp_entitymask_base.ps�  // Fragment shader

#ifdef GL_ES
    precision mediump float;
#endif

uniform vec4 SAMPLER_PARAMS;
#define PIXEL_WIDTH  SAMPLER_PARAMS.z
#define PIXEL_HEIGHT SAMPLER_PARAMS.w

uniform sampler2D SAMPLER[2];
#define BLOOM_SAMPLER       SAMPLER[0]
#define POSTPROCESS_SAMPLER SAMPLER[1]

#define MASK_COLOR_FLOOR vec3(0.000, 0.000, 0.000) // Gets overriden by the generator
#define MASK_COLOR_CEIL vec3(0.000, 0.000, 0.000)  // Gets overriden by the generator

varying vec2 PS_TEXCOORD0;

void main()
{
    vec2 coord = PS_TEXCOORD0;
    vec4 mask = texture2D(BLOOM_SAMPLER, coord);

    if(mask.r > MASK_COLOR_FLOOR.x && mask.r < MASK_COLOR_CEIL.x
    && mask.g > MASK_COLOR_FLOOR.y && mask.g < MASK_COLOR_CEIL.y
    && mask.b > MASK_COLOR_FLOOR.z && mask.b < MASK_COLOR_CEIL.z)
    {
        // int r = 3;
        // float minDist = PIXEL_WIDTH * float(r) * sqrt(2.0);
        // for(int i = -r; i <= r; i++)
        // {
        //     for(int j = -r; j <= r; j++)
        //     {
        //         vec2 offset = vec2(PIXEL_WIDTH * float(i), PIXEL_HEIGHT * float(j));
        //         if(texture2D(BLOOM_SAMPLER, coord + offset).rgb == vec3(0.0, 0.0, 0.0))
        //         {
        //             float dist = length(offset);
        //             if(minDist > dist)
        //             {
        //                 minDist = dist;
        //             }
        //         }
        //     }
        // }

        // gl_FragColor = vec4(minDist / (PIXEL_WIDTH * float(r) * sqrt(2.0)), 0.0, 0.0, 1.0);
        gl_FragColor = vec4(texture2D(POSTPROCESS_SAMPLER, coord).rgb, 1.0);
    }
    else
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}            