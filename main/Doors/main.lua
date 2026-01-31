-- Doors ESP Loader
print("[Matcha Doors] Starting loader...")

-- Load libraries
loadstring(game:HttpGet("https://arcanecheats.xyz/api/matcha/uilib"))()
repeat task.wait() until Arcane
print("[Matcha Doors] Arcane UI loaded")

loadstring(game:HttpGet("https://www.arcanecheats.xyz/api/matcha/esplib"))()
repeat task.wait() until ArcaneEsp
print("[Matcha Doors] Arcane ESP loaded")

task.wait(0.5)

-- Load modules
print("[Matcha Doors] Loading config...")
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/refs/heads/main/main/Doors/config.lua"))()

if not Config then
    warn("[Matcha Doors] Failed to load Config module")
    return
end
print("[Matcha Doors] Config loaded")

print("[Matcha Doors] Loading UI...")
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/refs/heads/main/main/Doors/ui.lua"))()

if not UI then
    warn("[Matcha Doors] Failed to load UI module")
    return
end
print("[Matcha Doors] UI loaded")

print("[Matcha Doors] Loading ESP...")
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/menunn/MatchaScripts/refs/heads/main/main/Doors/esp.lua"))()

if not ESP then
    warn("[Matcha Doors] Failed to load ESP module")
    return
end
print("[Matcha Doors] ESP loaded")

-- Initialize
Arcane:Log("Initializing Doors ESP...", 2)

UI.Init(Config)
ESP.Init(Config)

Arcane:Notify("Success", "Doors ESP Loaded!", 5)
print("[Matcha Doors] All modules loaded successfully")
