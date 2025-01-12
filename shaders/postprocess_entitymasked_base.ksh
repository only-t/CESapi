   postprocess_entitymasked_base      SAMPLER_PARAMS                                SAMPLER    +         postprocess_base.vs�   // Vertex shader

attribute vec3 POSITION;
attribute vec2 TEXCOORD0;

varying vec2 PS_TEXCOORD0;

void main()
{
	gl_Position = vec4(POSITION.xyz, 1.0);
	PS_TEXCOORD0.xy = TEXCOORD0.xy;
}     postprocess_entitymasked_base.ps2  // Fragment shader

#ifdef GL_ES
    precision highp float;
#endif

uniform vec4 SAMPLER_PARAMS;
#define PIXEL_WIDTH  SAMPLER_PARAMS.z
#define PIXEL_HEIGHT SAMPLER_PARAMS.w

uniform sampler2D SAMPLER[1];
#define BLOOM_SAMPLER       SAMPLER[0]
// #define POSTPROCESS_SAMPLER SAMPLER[1]

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
        int r = 3;
        float fr = float(r);
        float minDist = fr * sqrt(2.0);
        for(int i = -r; i <= r; i++)
        {
            for(int j = -r; j <= r; j++)
            {
                vec2 offset = vec2(PIXEL_WIDTH * float(i), PIXEL_HEIGHT * float(j));
                if(texture2D(BLOOM_SAMPLER, coord + offset).rgb == vec3(0.0, 0.0, 0.0))
                {
                    float dist = length(offset);
                    if(dist < minDist)
                    {
                        minDist = dist;
                    }
                }
            }
        }

        float h = 1.0 - (minDist / (PIXEL_HEIGHT * fr * sqrt(2.0)));
        float w = 1.0 - (minDist / (PIXEL_WIDTH  * fr * sqrt(2.0)));

        gl_FragColor = vec4(h, 0.0, 0.0, 1.0);

        // int dist = 0;
        // for(int i = -1; i <= 1; i++)
        // {
        //     for(int j = -1; j <= 1; j++)
        //     {
        //         if(texture2D(BLOOM_SAMPLER,
        //                         vec2(coord.x + float(i) * PIXEL_SIZE_W,
        //                              coord.y - float(j) * PIXEL_SIZE_H)).rgb == vec3(0.0, 0.0, 0.0))
        //         {
        //             dist = 1;
        //         }
        //     }
        // }

        // if(dist == 0)
        // {
        //     for(int i = -2; i <= 2; i++)
        //     {
        //         for(int j = -2; j <= 2; j++)
        //         {
        //             if(texture2D(BLOOM_SAMPLER,
        //                             vec2(coord.x + float(i) * PIXEL_SIZE_W,
        //                                  coord.y - float(j) * PIXEL_SIZE_H)).rgb == vec3(0.0, 0.0, 0.0))
        //             {
        //                 dist = 2;
        //             }
        //         }
        //     }
        // }

        // if(dist == 0)
        // {
        //     for(int i = -3; i <= 3; i++)
        //     {
        //         for(int j = -3; j <= 3; j++)
        //         {
        //             if(texture2D(BLOOM_SAMPLER,
        //                             vec2(coord.x + float(i) * PIXEL_SIZE_W,
        //                                  coord.y - float(j) * PIXEL_SIZE_H)).rgb == vec3(0.0, 0.0, 0.0))
        //             {
        //                 dist = 3;
        //             }
        //         }
        //     }
        // }

        // if(dist == 1)
        // {
        //     gl_FragColor = vec4(texture2D(POSTPROCESS_SAMPLER, coord).rgb * 0.5, 0.5);
        // }
        // else if(dist == 2)
        // {
        //     gl_FragColor = vec4(texture2D(POSTPROCESS_SAMPLER, coord).rgb * 0.8, 0.8);
        // }
        // else if(dist == 3)
        // {
        //     gl_FragColor = vec4(texture2D(POSTPROCESS_SAMPLER, coord).rgb * 0.9, 0.9);
        // }
        // else
        // {
        //     gl_FragColor = vec4(texture2D(POSTPROCESS_SAMPLER, coord).rgb      , 1.0);
        // }
    }
    else
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}               