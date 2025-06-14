env._G = GLOBAL._G
GLOBAL.setfenv(1, env)

local CESAPI_DEBUG_MODE = true

if CESAPI_DEBUG_MODE then
    _G.inspect = require("inspect")
end

Assets = {
    Asset("SHADER", "shaders/CESbloom.ksh")
}

local old_CreateEntity = _G.CreateEntity
_G.CreateEntity = function(name, ...)
    local ent = old_CreateEntity(name, ...)

    if name == "TheGlobalInstance" then -- Modify userdata fns using TheGlobalInstance
        local ent_mt_index = _G.getmetatable(ent.entity).__index

        -- [ AddPostProcessor ] --
        local modified_AddPostProcessor = false
        local old_AddPostProcessor = ent_mt_index.AddPostProcessor
        ent_mt_index.AddPostProcessor = function(...)
            if modified_AddPostProcessor then
                return old_AddPostProcessor(...)
            end

            local pp = old_AddPostProcessor(...)
            local pp_mt_index = _G.getmetatable(pp).__index
            local old_SetBloomSamplerParams = pp_mt_index.SetBloomSamplerParams
            pp_mt_index.SetBloomSamplerParams = function(self, sampler_size, size_x, size_w, sampler_colour_mode, ...)
                if sampler_size == _G.SamplerSizes.Relative then -- Increase the resolution of the bloom sampler
                    size_x = 1
                    size_w = 1
                end

                sampler_colour_mode = _G.SamplerColourMode.RGBA

                return old_SetBloomSamplerParams(self, sampler_size, size_x, size_w, sampler_colour_mode, ...)
            end

            modified_AddPostProcessor = true

            return pp
        end
        
        -- [ AddAnimState ] --
        local modified_AddAnimState = false
        local old_AddAnimState = ent_mt_index.AddAnimState
        ent_mt_index.AddAnimState = function(...)
            if modified_AddAnimState then
                return old_AddAnimState(...)
            end

            local animstate = old_AddAnimState(...)
            local animstate_mt_index = _G.getmetatable(animstate).__index
            local old_SetBloomEffectHandle = animstate_mt_index.SetBloomEffectHandle
            animstate_mt_index.SetBloomEffectHandle = function(self, path, modded, ...) -- Changed for the games use, should not be used by mods
                if modded then                                                          -- Use CESAPI.SetDefaultBloomEffect(animstate) for the default bloom effect
                    old_SetBloomEffectHandle(self, path, ...)
                else
                    _G.CESAPI.SetDefaultBloomEffect(self)
                end
            end

            modified_AddAnimState = true

            return animstate
        end
    end

    return ent
end

modimport("scripts/CESconstants")
modimport("scripts/CESfns")
modimport("scripts/CESbloom")

local CESapiSettingsTab = require("widgets/cesapisettingstab")
local OptionsScreen = require("screens/redux/optionsscreen")
local old_OptionsScreen_BuildMenu = OptionsScreen._BuildMenu
OptionsScreen._BuildMenu = function(self, subscreener, ...)
    subscreener.sub_screens["cesapi"] = self.panel_root:AddChild(CESapiSettingsTab(self))
    local menu = old_OptionsScreen_BuildMenu(self, subscreener, ...)
    
    for i = #menu.items, #menu.items - 1, -1 do
        local pos = _G.Vector3(0, 0, 0)
        pos.y = pos.y + menu.offset * (i)
        menu.items[i]:SetPosition(pos)
    end

	local cesapi_button = subscreener:MenuButton(_G.CESAPI.SETTINGS.NAME, "cesapi", _G.CESAPI.SETTINGS.TOOLTIP, self.tooltip)
    menu:AddCustomItem(cesapi_button)
    local pos = _G.Vector3(0, 0, 0)
    pos.y = pos.y + menu.offset * (#menu.items - 3) -- Move CESapi down into position
    cesapi_button:SetPosition(pos)
    
    return menu
end

local function EnabledOptionsIndex(enabled)
    return enabled and 2 or 1
end

if _G.Profile:GetValue(_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR) == nil then
    _G.Profile:SetValue(_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR, true) -- true is the default value
end

local old_OptionsScreen_DoInit = OptionsScreen.DoInit
OptionsScreen.DoInit = function(self, ...)
    self.options[_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR] = _G.Profile:GetValue(_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR)
    self.working[_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR] = _G.Profile:GetValue(_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR)

    old_OptionsScreen_DoInit(self, ...)
end

local old_OptionsScreen_Apply = OptionsScreen.Apply
OptionsScreen.Apply = function(self, ...)
    _G.Profile:SetValue(_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR, self.working[_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR])

    old_OptionsScreen_Apply(self, ...)
end

local old_OptionsScreen_InitializeSpinners = OptionsScreen.InitializeSpinners
OptionsScreen.InitializeSpinners = function(self, ...)
    self.subscreener.sub_screens["cesapi"].shadersSpinner:SetSelectedIndex(EnabledOptionsIndex(self.working[_G.CESAPI.SETTINGS.OPTIONS.SHADERS.OPTIONS_STR]))

    old_OptionsScreen_InitializeSpinners(self, ...)
end