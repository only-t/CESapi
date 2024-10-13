local shader_file
shader_file = _G.io.open(_G.MODS_ROOT..modname.."/shaders/".._G.CESAPI_BASE_ENTITY_MASK_SHADER_NAME..".ksh", "r")
local BASE_ENTITY_MASK_SHADER_STRING = shader_file:read("*all")
shader_file:close()

shader_file = _G.io.open(_G.MODS_ROOT..modname.."/shaders/".._G.CESAPI_BASE_POSTPROCESS_MASKED_SHADER_NAME..".ksh", "r")
local BASE_POSTPROCESS_MASKED_SHADER_STRING = shader_file:read("*all")
shader_file:close()
shader_file = nil

local function GetColorIndex(i)
    i = i - 1 -- Covering for the index offset
    local i1 = 1 + i % 100
    local i2 = 1 + math.floor(i / 100)
    local i3 = 1 + math.floor(i / 10000)

    return { _G.CESAPI_ENTITY_SHADER_BASE_COLOR_INDEX[1] * i1, _G.CESAPI_ENTITY_SHADER_BASE_COLOR_INDEX[2] * i2, _G.CESAPI_ENTITY_SHADER_BASE_COLOR_INDEX[3] * i3 }
end

-- Recommended to have "mask" and "postprocess" in the respective shaders names
local ENTITY_SHADER_INDEX = 0
-- modname - required to access the shaders folder of the mod
-- maskshadername - the name of the mask shader, applied as a bloom shader using SetBloomEffectHandle
-- postprocess_maskedshadername - the name of the post processing shader that "cuts out" the entity sprite using the BloomSampler with a color masked
-- assettable - required to insert the masking shaders assets into the mod asset table
_G.GenerateEntityMaskingShaders = function(modname, maskshadername, postprocess_maskedshadername, assettable)
    _G.assert(maskshadername ~= nil, _G.CESAPI_ERROR_PREFIX.."Missing masking shader name!")
    _G.assert(postprocess_maskedshadername ~= nil, _G.CESAPI_ERROR_PREFIX.."Missing postprocess masking shader name!")
    _G.assert(ENTITY_SHADER_INDEX < _G.CESAPI_ENTITY_SHADER_MAX_INDEX, _G.CESAPI_ERROR_PREFIX.."Reached the max ("..tostring(_G.CESAPI_ENTITY_SHADER_MAX_INDEX)..") number of entity masking shaders!")

    local shadercode, f, path, color_index

    -- Entity masking shader
    ENTITY_SHADER_INDEX = ENTITY_SHADER_INDEX + 1
    color_index = GetColorIndex(ENTITY_SHADER_INDEX)
    path = _G.MODS_ROOT..modname.."/shaders/"..maskshadername..".ksh"
    f = _G.io.open(path, "w")
    _G.assert(f ~= nil, _G.CESAPI_ERROR_PREFIX.."Encountered an error when trying to generate a masking shader file!")

    local r_index = tostring(color_index[1])..(color_index[1] % 0.1 == 0 and "0" or "")
    local g_index = tostring(color_index[2])..(color_index[2] % 0.1 == 0 and "0" or "")
    local b_index = tostring(color_index[2])..(color_index[3] % 0.1 == 0 and "0" or "")
    shadercode = string.gsub(BASE_ENTITY_MASK_SHADER_STRING, "MASK_COLOR vec3%(0%.00, 0%.00, 0%.00%)", "MASK_COLOR vec3%("..r_index..", "..g_index..", "..b_index.."%)", 1)
    shadercode = string.gsub(shadercode, _G.CESAPI_BASE_ENTITY_MASK_SHADER_NAME, maskshadername, 1)
    shadercode = string.gsub(shadercode, string.char(string.len(_G.CESAPI_BASE_ENTITY_MASK_SHADER_NAME)), string.char(string.len(maskshadername)), 1)
    f:write(shadercode)
    f:close()

    _G.CESAPI_ENTITY_MASKING_SHADERS[maskshadername] = {
        i = ENTITY_SHADER_INDEX,
        modname = modname,
        color = color_index
    }

    -- Postprocess masking shader
    local floor = {
        color_index[1] - 0.005,
        color_index[2] - 0.005,
        color_index[3] - 0.005
    }

    local ceil = {
        color_index[1] + 0.005,
        color_index[2] + 0.005,
        color_index[3] + 0.005
    }

    path = _G.MODS_ROOT..modname.."/shaders/"..postprocess_maskedshadername..".ksh"
    f = _G.io.open(path, "w")
    shadercode = BASE_POSTPROCESS_MASKED_SHADER_STRING
    shadercode = string.gsub(shadercode, _G.CESAPI_BASE_POSTPROCESS_MASKED_SHADER_NAME, postprocess_maskedshadername, 1)
    shadercode = string.gsub(shadercode, string.char(string.len(_G.CESAPI_BASE_POSTPROCESS_MASKED_SHADER_NAME)), string.char(string.len(postprocess_maskedshadername)), 1)
    local floor_str = "MASK_COLOR_FLOOR vec3("..floor[1]..", "..floor[2]..", "..floor[3].."%)"
    shadercode = string.gsub(shadercode, "MASK_COLOR_FLOOR vec3%(0%.000, 0%.000, 0%.000%)", floor_str, 1)
    local ceil_str = "MASK_COLOR_CEIL vec3("..ceil[1]..", "..ceil[2]..", "..ceil[3].."%)"
    shadercode = string.gsub(shadercode, "MASK_COLOR_CEIL vec3%(0%.000, 0%.000, 0%.000%)", ceil_str, 1)
    f:write(shadercode)
    f:close()

    table.insert(assettable, Asset("SHADER", "shaders/"..maskshadername..".ksh"))
    table.insert(assettable, Asset("SHADER", "shaders/"..postprocess_maskedshadername..".ksh"))

    AddModShadersInit(function()
        _G.SamplerEffects[postprocess_maskedshadername] = _G.PostProcessor:AddSamplerEffect(_G.resolvefilepath("shaders/"..postprocess_maskedshadername..".ksh"), _G.SamplerSizes.Relative, 1, 1, _G.SamplerColourMode.RGBA, _G.SamplerEffectBase.BloomSampler)
        _G.PostProcessor:AddSampler(_G.SamplerEffects[postprocess_maskedshadername], _G.SamplerEffectBase.PostProcessSampler)
        _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects[postprocess_maskedshadername], _G.UniformVariables.SAMPLER_PARAMS)
        _G.PostProcessor:SetSamplerEffectFilter(_G.SamplerEffects[postprocess_maskedshadername], _G.FILTER_MODE.LINEAR, _G.FILTER_MODE.LINEAR, _G.MIP_FILTER_MODE.NONE)
    end)

    print(_G.CESAPI_PRINT_PREFIX.."Generated entity masking shaders")
    print("    Modname: "..modname)
    print("    Entity masking shader name: "..maskshadername)
    print("    Postprocess masking shader name: "..postprocess_maskedshadername)
    print("    Index: "..tostring(ENTITY_SHADER_INDEX))
    print("    Mask: ("..tostring(color_index[1])..", "..tostring(color_index[2])..", "..tostring(color_index[3])..")\n")
end