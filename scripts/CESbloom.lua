table.insert(Assets, Asset("SHADER", "shaders/CESBloom.ksh"))
table.insert(Assets, Asset("SHADER", "shaders/postprocess_CESBloom.ksh"))

AddModShadersInit(function()
    _G.SamplerEffects["CESBloomSampler"] = _G.PostProcessor:AddSamplerEffect(_G.resolvefilepath("shaders/postprocess_CESBloom.ksh"), _G.SamplerSizes.Relative, 1, 1, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.BloomSampler)
    _G.PostProcessor:AddSampler(_G.SamplerEffects["CESBloomSampler"], _G.SamplerEffectBase.PostProcessSampler)
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects["CESBloomSampler"], _G.UniformVariables.SAMPLER_PARAMS)
    _G.PostProcessor:SetSamplerEffectFilter(_G.SamplerEffects["CESBloomSampler"], _G.FILTER_MODE.LINEAR, _G.FILTER_MODE.LINEAR, _G.MIP_FILTER_MODE.NONE)

    _G.SamplerEffects.CESBlurH = _G.PostProcessor:AddSamplerEffect("shaders/blurh.ksh", _G.SamplerSizes.Relative, 0.25, 0.25, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.Shader, _G.SamplerEffects["CESBloomSampler"])
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.CESBlurH, _G.UniformVariables.SAMPLER_PARAMS)

    _G.SamplerEffects.CESBlurV = _G.PostProcessor:AddSamplerEffect("shaders/blurv.ksh", _G.SamplerSizes.Relative, 0.25, 0.25, _G.SamplerColourMode.RGB, _G.SamplerEffectBase.Shader, _G.SamplerEffects.CESBlurH)
    _G.PostProcessor:SetEffectUniformVariables(_G.SamplerEffects.CESBlurV, _G.UniformVariables.SAMPLER_PARAMS)

    _G.PostProcessor:SetSamplerEffectFilter(_G.SamplerEffects.CESBlurV, _G.FILTER_MODE.LINEAR, _G.FILTER_MODE.LINEAR, _G.MIP_FILTER_MODE.NONE)

    _G.PostProcessorEffects.CESBloom = _G.PostProcessor:AddPostProcessEffect("shaders/postprocess_bloom.ksh")
    _G.PostProcessor:AddSampler(_G.PostProcessorEffects.CESBloom, _G.SamplerEffectBase.Shader, _G.SamplerEffects.CESBlurV)
end)

AddModShadersSortAndEnable(function()
    _G.PostProcessor:SetPostProcessEffectBefore(_G.PostProcessorEffects.CESBloom, _G.PostProcessorEffects.Bloom)
    _G.PostProcessor:EnablePostProcessEffect(_G.PostProcessorEffects.CESBloom, true)
end)