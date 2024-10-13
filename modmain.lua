env._G = GLOBAL._G
GLOBAL.setfenv(1, env) -- Sets the mods environment to the games'

local CESAPI_DEBUG_MODE = true

Assets = {  }

local old_CreateEntity = _G.CreateEntity
_G.CreateEntity = function(name, ...)
    local ent = old_CreateEntity(name, ...)

    if name == "TheGlobalInstance" then
        local ent_metatable_index = _G.getmetatable(ent.entity).__index
        local old_AddPostProcessor = ent_metatable_index.AddPostProcessor
        ent_metatable_index.AddPostProcessor = function(...)
            local postprocessor = old_AddPostProcessor(...)
            local postprocessor_metatable_index = _G.getmetatable(postprocessor).__index
            local old_SetBloomSamplerParams = postprocessor_metatable_index.SetBloomSamplerParams
            postprocessor_metatable_index.SetBloomSamplerParams = function(self, sampler_size, size_x, size_w, sampler_colour_mode, ...)
                if sampler_size == _G.SamplerSizes.Relative then
                    size_x = 1
                    size_w = 1
                end

                sampler_colour_mode = _G.SamplerColourMode.RGBA

                return old_SetBloomSamplerParams(self, sampler_size, size_x, size_w, sampler_colour_mode, ...)
            end

            return postprocessor
        end

        _G.CreateEntity = old_CreateEntity
    end

    return ent
end

modimport("scripts/CESconstants")
modimport("scripts/CESfns")
modimport("scripts/CESbloom")

if CESAPI_DEBUG_MODE then
    modimport("scripts/CESdebugging")
end