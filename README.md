`modfolder/README.txt`:

# [CESapi] Custom Entity Shaders API

## What is CESapi?
CESapi is a tool for modders to easily create more interesting shaders for entities. It opens a way for entity shaders to use custom
uniform variables and texture/shader samplers. This api is fully client sided and must always be loaded BEFORE every mod using it.
If you're planning on using this API make sure your mods priority is LOWER then this APIs (current priority = 999999999).

## How to use CESapi?
While CESapi does most of the heavy lifting when it comes to managing shaders, SOME knowledge about how shaders are created is required
and it's recommended to have MEDIUM knowledge about GLSL ES 1.0 (the shading language used by DST) and the PostProcessor.
Check the examplemod (`modfolder/examplemod/`) for a detailed explanation of how to use CESapi and examples of shaders that can be created using it.


# ! Below is some information for those who are extra interested !

## Why you might need CESapi?
Shaders are a powerful tool for creating visual effects that would normally by impossible to do using simple animations.
Don't Starve Together uses shaders for things such as: insanity distortions, bloom or the erosion effect for when entities die.
What makes working with shaders in DST difficult is how limited modders are when it comes to what they can make. The rendering part
of Don't Starve Together is present in the engine of the game itself meaning it is inaccessible to modders and the few functions wrapping
to the rendering there are are not nearly sufficient enough. Currently, there are only 2 "types" of shaders that modders can create, these being
the "default" entity shader, which can be hooked up to any entity with AnimState using SetDefaultEffectHandle() and the "post processing"
shader, which can be created using the PostProcessor and its functions.

While "post processing" shaders can define their own uniform variables and samplers (basically a necessity when trying to create
a more complex shader) they lack the ability to differentiate the "background" from the entities present in the scene making them useful
only in the context of altering the entire screen.
Default entity shaders have the same problem, but in reverse. They know about the entity they're hooked to but have no access to any
other screen info. They also cannot use any custom uniforms or samplers limiting their usefulness to, pretty much, just altering
the color of entities they're hooked to.

CESapi allows modders to create a "post processing" shader with the ability to hook up a custom sampler holding color information about
affected entities, effectively combining the "default" entity shader with the ability to use custom uniform variables and samplers.

### <b> ! For examples of what CESapi can do check the examplemod provided with this mod ! </b>

## How does CESapi work?
### Short answer:
CESapi works by creating a sampler containing only the entities affected by a custom shader from everything else. This sampler
can then be used inside "post processing" shaders.

### Long answer:
DST has a sampler (SamplerEffectBase.BloomSampler) specifically desinged to only hold color information about entities affected by bloom,
that is, entities that run SetBloomEffectHandle(). CESapi works by hijacking this sampler and using it to create masking shaders for entities.
Then, using these masks, it "cuts out" the appropriate areas of the rendered screen and puts them inside a custom sampler that can then
be fed into a custom "post processing" shader.
As all custom entity shaders take in from the same BloomSampler masking shaders and "cut out" samplers use color values to determine
which pixel belongs to which shader. The color values for custom entity shaders start at 0.01 for all RGB values and go up,
one by one, by 0.01, that is, a custom entity shader with index 0 would have color values { 0.01, 0.01, 0.01 }, then a shader with
index 1 would have { 0.02, 0.01, 0.01 } and so on until { 0.99, 0.99, 0.99 }. The maximum amount of custom entity shaders that can be present in a single game
is 970299 (99 * 99 * 99) (realistically impossible to reach).

<b>! THE API DOES NOT GUARANTEE THAT THE SAME SHADERS WILL HAVE THE SAME COLOR INDEX BETWEEN PLAY SESSIONS !</b>

This is a result of the fact that different mods can be loaded at different times based on their priority and whether the user
has them enabled or not. However this is not a problem as the api automatically recompiles masking shaders during server launch, filling in
the correct color values according to the order they were created in. CESapi has 2 template shaders it uses to generate masking shader,
entitymask_base.ksh and pp_entitymask_base.ksh. The first one is applied as a bloom shader and generates a color mask for the
entity. The second one is used as a "post processing" shader, using the BloomSampler and reading from it only areas color coded with
the correct color. It then uses the PostProcessSampler to output the "cut out" area that can later be used in a custom shader.
Because this API needs BloomSampler to work the default bloom effect cannot be applied to entities. That is also not a problem though as CESapi creates its own bloom shader and applies it wherever the default bloom would be added. This CESapi bloom is always created first with the color index of { 0.1, 0.1, 0.1 }.

## What can CESapi NOT do?
While CESapi does achieve the goal I set for it to do it is still highly experimental. There are certain things CESapi cannot do and
certain "quirks" this method of creating shaders has that still limits what can be created using it.

### Known issues:
- Entity shader scale does not change based on the distance from the camera view to the entity: (High priority, fixable)
- Only 1 entity shader can be present on a single entity at a time: (Low priority, potentially unfixable)
- Entity shaders cannot hold transparency of the entity: (Low priority, potentially unfixable)
- Entity shaders do not replace the original entity causing any positional modification to create a duplicate: (Low priority, potentially unfixable)
- Entity shaders are incapable of possessing any physical properties of entities they're affecting: (Low priority, potentially unfixable)