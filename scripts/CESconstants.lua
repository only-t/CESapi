_G.CESAPI_BASE_ENTITY_MASK_SHADER_NAME = "entitymask_base"
_G.CESAPI_BASE_POSTPROCESS_MASKED_SHADER_NAME = "postprocess_entitymasked_base"
_G.CESAPI_PRINT_PREFIX = "[CESapi] Custom Entity Shaders API - "
_G.CESAPI_ERROR_PREFIX = "[CESapi] Custom Entity Shaders API - ERROR! "
_G.CESAPI_ENTITY_SHADER_BASE_COLOR_INDEX = { 0.01, 0.01, 0.01 } -- 0.01 is the minimum, 1.0 is reserved for bloom
_G.CESAPI_ENTITY_SHADER_MAX_INDEX = 99 * 99 * 99 -- 970299 different unique masks, should be enough

_G.CESAPI_ENTITY_MASKING_SHADERS = {
    ["bloommask"] = {
        i = 0,
        modname = "DST",
        color = { 1.0, 1.0, 1.0 }
    }
}