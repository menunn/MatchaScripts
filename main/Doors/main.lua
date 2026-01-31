-- Doors ESP Loader
-- Load libraries
loadstring(game:HttpGet("https://arcanecheats.xyz/api/matcha/uilib"))()
repeat wait() until Arcane

loadstring(game:HttpGet("https://www.arcanecheats.xyz/api/matcha/esplib"))()
repeat wait() until ArcaneEsp

-- Load modules
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/main/Doors/config.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/main/Doors/ui.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/main/Doors/esp.lua"))()

-- Initialize
Arcane:Log("Loading Doors ESP...", 2)

UI.Init(Config)
ESP.Init(Config)

Arcane:Notify("Success", "Doors ESP Loaded!", 5)
print("[Matcha Doors] All modules loaded successfully")
