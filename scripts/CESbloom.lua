_G.CESAPI.GenerateMaskingShaders("bloom", Assets)

local bloom_enabled = false
AddModShadersInit(function()
    local pp_mt_index = _G.getmetatable(_G.PostProcessor).__index
    local old_SetBloomEnabled = pp_mt_index.SetBloomEnabled
    pp_mt_index.SetBloomEnabled = function(self, enabled, ...)
        old_SetBloomEnabled(self, enabled, ...)

        bloom_enabled = enabled
        self:EnablePostProcessEffect(_G.PostProcessorEffects.Bloom, false)
        self:EnablePostProcessEffect(_G.PostProcessorEffects.CESBloom, enabled)
    end

    _G.SamplerEffects.CESBloomBlurH = _G.PostProcessor:AddSamplerEffect("shaders/blurh.ksh", _G.SamplerSizes.Relative, 0.25, 0.25, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.Shader, _G.SamplerEffects["pp_bloom_mask"])
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.CESBloomBlurH, _G.UniformVariables.SAMPLER_PARAMS)

    _G.SamplerEffects.CESBloomBlurV = _G.PostProcessor:AddSamplerEffect("shaders/blurv.ksh", _G.SamplerSizes.Relative, 0.25, 0.25, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.Shader, _G.SamplerEffects.CESBloomBlurH)
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.CESBloomBlurV, _G.UniformVariables.SAMPLER_PARAMS)
    
    _G.PostProcessor:SetSamplerEffectFilter(_G.SamplerEffects.CESBloomBlurV, _G.FILTER_MODE.LINEAR, _G.FILTER_MODE.LINEAR, _G.MIP_FILTER_MODE.NONE)

    _G.PostProcessorEffects.CESBloom = _G.PostProcessor:AddPostProcessEffect(_G.resolvefilepath("shaders/CESbloom.ksh"))
    _G.PostProcessor:AddSampler(_G.PostProcessorEffects.CESBloom, _G.SamplerEffectBase.Shader, _G.SamplerEffects.CESBloomBlurV)
end)

AddModShadersSortAndEnable(function()
    _G.PostProcessor:SetPostProcessEffectBefore(_G.PostProcessorEffects.CESBloom, _G.PostProcessorEffects.Bloom)
    _G.PostProcessor:EnablePostProcessEffect(_G.PostProcessorEffects.CESBloom, true)
end)