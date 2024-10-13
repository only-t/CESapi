name = "[CESapi] Custom Entity Shaders API DEV"
description = [[
Custom Entity Shaders API is a tool designed to give modders more control over entity shaders.
CESapi allows you to create custom uniform variables and samplers and pass them into entity shaders.

This API is still in BETA so some bugs may be showing!
]]
author = "LukaS"
version = "0.1.0"
forumthread = ""
icon_atlas = "icon.xml"
icon = "icon.tex"
client_only_mod = true -- Custom shaders should always be created and loaded locally
all_clients_require_mod = false
dst_compatible = true
reign_of_giants_compatible = false
dont_starve_compatible = false
priority = 999999999 -- Load as early as possible
api_version = 10