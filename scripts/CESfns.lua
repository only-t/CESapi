local shader_file
shader_file = _G.io.open(_G.MODS_ROOT..modname.."/shaders/".._G.CESAPI.BASE_ENTITY_MASK_SHADER_NAME..".ksh", "r")
local BASE_ENTITY_MASK_SHADER_STR = shader_file:read("*all")
shader_file:close()

shader_file = _G.io.open(_G.MODS_ROOT..modname.."/shaders/".._G.CESAPI.BASE_PP_MASK_SHADER_NAME..".ksh", "r")
local BASE_PP_MASK_SHADER_STR = shader_file:read("*all")
shader_file:close()
shader_file = nil

local function GetColorIndex(i)
    local i1 = 1 + i % 99
    local i2 = 1 + math.floor(i / 99) % 99
    local i3 = 1 + math.floor(i / 9999) % 99

    return { _G.CESAPI.ENTITY_SHADER_BASE_COLOR_INDEX[1] * i1, _G.CESAPI.ENTITY_SHADER_BASE_COLOR_INDEX[2] * i2, _G.CESAPI.ENTITY_SHADER_BASE_COLOR_INDEX[3] * i3 }
end

local ENTITY_SHADER_INDEX = -1
_G.CESAPI.GenerateMaskingShaders = function(shadername, assettable)
    _G.assert(shadername ~= nil, _G.CESAPI.ERROR_PREFIX.."Missing shader name!")
    _G.assert(_G.CESAPI.ENTITY_MASKING_SHADERS[shadername] == nil, _G.CESAPI.ERROR_PREFIX.."Duplicate shader name detected ("..shadername..")! Try using a different name.")
    _G.assert(ENTITY_SHADER_INDEX < _G.CESAPI.ENTITY_SHADER_MAX_INDEX, _G.CESAPI.ERROR_PREFIX.."Reached the max ("..tostring(_G.CESAPI.ENTITY_SHADER_MAX_INDEX)..") number of entity masking shaders!")

    local ent_shadername, pp_shadername, shadercode, f

    ENTITY_SHADER_INDEX = ENTITY_SHADER_INDEX + 1
    local color_index = GetColorIndex(ENTITY_SHADER_INDEX)
    local r_index = tostring(color_index[1])..(color_index[1] % 0.1 == 0 and "0" or "")
    local g_index = tostring(color_index[2])..(color_index[2] % 0.1 == 0 and "0" or "")
    local b_index = tostring(color_index[2])..(color_index[3] % 0.1 == 0 and "0" or "")
    local floor = {
        color_index[1] - 0.005,
        color_index[2] - 0.005,
        color_index[3] - 0.005
    }
    local floor_str = "MASK_COLOR_FLOOR vec3("..floor[1]..", "..floor[2]..", "..floor[3].."%)"
    local ceil = {
        color_index[1] + 0.005,
        color_index[2] + 0.005,
        color_index[3] + 0.005
    }
    local ceil_str = "MASK_COLOR_CEIL vec3("..ceil[1]..", "..ceil[2]..", "..ceil[3].."%)"

    -- Entity masking shader
    ent_shadername = shadername.."_mask"
    f = _G.io.open("unsafedata/"..ent_shadername..".ksh", "w")
    _G.assert(f ~= nil, _G.CESAPI.ERROR_PREFIX.."Encountered an error while trying to generate "..ent_shadername..".ksh!")

    shadercode = string.gsub(BASE_ENTITY_MASK_SHADER_STR, "MASK_COLOR vec3%(0%.00, 0%.00, 0%.00%)", "MASK_COLOR vec3%("..r_index..", "..g_index..", "..b_index.."%)", 1)
    shadercode = string.gsub(shadercode, _G.CESAPI.BASE_ENTITY_MASK_SHADER_NAME, ent_shadername, 1)
    shadercode = string.gsub(shadercode, string.char(string.len(_G.CESAPI.BASE_ENTITY_MASK_SHADER_NAME)), string.char(string.len(ent_shadername)), 1)
    f:write(shadercode)
    f:close()

    -- Postprocess masking shader
    pp_shadername = "pp_"..shadername.."_mask"
    f = _G.io.open("unsafedata/"..pp_shadername..".ksh", "w")
    _G.assert(f ~= nil, _G.CESAPI.ERROR_PREFIX.."Encountered an error while trying to generate "..pp_shadername..".ksh!")

    shadercode = string.gsub(BASE_PP_MASK_SHADER_STR, "MASK_COLOR_FLOOR vec3%(0%.000, 0%.000, 0%.000%)", floor_str, 1)
    shadercode = string.gsub(shadercode, "MASK_COLOR_CEIL vec3%(0%.000, 0%.000, 0%.000%)", ceil_str, 1)
    shadercode = string.gsub(shadercode, _G.CESAPI.BASE_PP_MASK_SHADER_NAME, pp_shadername, 1)
    shadercode = string.gsub(shadercode, string.char(string.len(_G.CESAPI.BASE_PP_MASK_SHADER_NAME)), string.char(string.len(pp_shadername)), 1)
    f:write(shadercode)
    f:close()

    _G.CESAPI.ENTITY_MASKING_SHADERS[shadername] = {
        i = ENTITY_SHADER_INDEX,
        color = color_index,
    }

    table.insert(assettable, Asset("SHADER", "unsafedata/"..ent_shadername..".ksh"))
    table.insert(assettable, Asset("SHADER", "unsafedata/"..pp_shadername..".ksh"))

    AddModShadersInit(function()
        _G.SamplerEffects[pp_shadername] = _G.PostProcessor:AddSamplerEffect(_G.resolvefilepath("unsafedata/"..pp_shadername..".ksh"), _G.SamplerSizes.Relative, 1, 1, _G.SamplerColourMode.RGBA, _G.SamplerEffectBase.BloomSampler)
        _G.PostProcessor:AddSampler(_G.SamplerEffects[pp_shadername], _G.SamplerEffectBase.PostProcessSampler)
        _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects[pp_shadername], _G.UniformVariables.SAMPLER_PARAMS)
        _G.PostProcessor:SetSamplerEffectFilter(_G.SamplerEffects[pp_shadername], _G.FILTER_MODE.LINEAR, _G.FILTER_MODE.LINEAR, _G.MIP_FILTER_MODE.NONE)
    end)

    print(_G.CESAPI.PRINT_PREFIX.."Generated entity masking shaders:")
    print("    Entity masking shader: "..ent_shadername)
    print("    Postprocess masking shader: "..pp_shadername)
    print("    Index: "..tostring(ENTITY_SHADER_INDEX))
    print("    Mask: ("..tostring(color_index[1])..", "..tostring(color_index[2])..", "..tostring(color_index[3])..")\n")
end

_G.CESAPI.SetDefaultBloomEffect = function(animstate)
    animstate:SetBloomEffectHandle(_G.resolvefilepath("unsafedata/bloom_mask.ksh"), true)
end

_G.CESAPI.SetCustomEffect = function(animstate, name)
    local path = _G.resolvefilepath("unsafedata/"..name.."_mask.ksh")
    animstate:SetBloomEffectHandle(path, true)
end

_G.CESAPI.ClearCustomEffect = function(animstate)
    animstate:ClearBloomEffectHandle()
end

_G.CESAPI.ClearDefaultBloomEffect = function(animstate)
    animstate:ClearBloomEffectHandle()
end