_G.CESAPI = {
    BASE_ENTITY_MASK_SHADER_NAME = "entitymask_base",
    BASE_PP_MASK_SHADER_NAME = "pp_entitymask_base",
    PRINT_PREFIX = "[CESapi] Custom Entity Shaders API - ",
    ERROR_PREFIX = "[CESapi] Custom Entity Shaders API - ERROR! ",
    WARNING_PREFIX = "[CESapi] Custom Entity Shaders API - WARNING! ",
    ENTITY_SHADER_BASE_COLOR_INDEX = { 0.01, 0.01, 0.01 }, -- 0.01 is the minimum
    ENTITY_SHADER_MAX_INDEX = 99 * 99 * 99,
    
    ENTITY_MASKING_SHADERS = {
        -- ["bloom"] = { -- Base game bloom masks are always generated first
        --     i = 0,
        --     modname = "DST",
        --     color = { 0.01, 0.01, 0.01 }
        -- }
    }
}