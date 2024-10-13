table.insert(Assets, Asset("SHADER", "shaders/DEBUG_postprocess_secondsampler.ksh"))

-- PostProcessor:EnablePostProcessEffect(PostProcessorEffects.ColourCube, false)
-- PostProcessor:EnablePostProcessEffect(PostProcessorEffects.BloomSampler, false)
-- PostProcessor:EnablePostProcessEffect(PostProcessorEffects.CESBloomSampler, false)

AddModShadersInit(function()
    -- Bloom sampler view
    _G.PostProcessorEffects.BloomSampler = _G.PostProcessor:AddPostProcessEffect(_G.resolvefilepath("shaders/DEBUG_postprocess_secondsampler.ksh"))
    _G.PostProcessor:AddSampler(_G.PostProcessorEffects.BloomSampler, _G.SamplerEffectBase.BloomSampler)

    -- CESBLoom sampler view
    _G.PostProcessorEffects.CESBloomSampler = _G.PostProcessor:AddPostProcessEffect(_G.resolvefilepath("shaders/DEBUG_postprocess_secondsampler.ksh"))
    _G.PostProcessor:AddSampler(_G.PostProcessorEffects.CESBloomSampler, _G.SamplerEffectBase.Shader, _G.SamplerEffects["CESBloomSampler"])
end)

AddModShadersSortAndEnable(function()
    -- Bloom sampler view
    _G.PostProcessor:SetPostProcessEffectAfter(_G.PostProcessorEffects.BloomSampler, _G.PostProcessorEffects.Bloom)
    _G.PostProcessor:EnablePostProcessEffect(_G.PostProcessorEffects.BloomSampler, false)

    -- CESBLoom sampler view
    _G.PostProcessor:SetPostProcessEffectAfter(_G.PostProcessorEffects.CESBloomSampler, _G.PostProcessorEffects.Bloom)
    _G.PostProcessor:EnablePostProcessEffect(_G.PostProcessorEffects.CESBloomSampler, false)
end)