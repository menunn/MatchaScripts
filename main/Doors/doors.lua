-- Matcha Doors Script 
-- Libraries
loadstring(game:HttpGet("https://arcanecheats.xyz/api/matcha/uilib"))()
repeat wait() until Arcane

loadstring(game:HttpGet("https://www.arcanecheats.xyz/api/matcha/esplib"))()

task.wait()

-- Services
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local player = players.LocalPlayer
local rooms = workspace:FindFirstChild("CurrentRooms")

-- Global State
local CONFIG = {
    entityNotify = true,
    doorESP = true,
    keyESP = true,
    entityESP = true,
    figureESP = true,
    speedBoost = 0,
    espColor = Color3.fromRGB(127, 107, 188),
    doorColor = Color3.fromRGB(50, 255, 128),
    keyColor = Color3.fromRGB(255, 215, 0),
    entityColor = Color3.fromRGB(255, 0, 0),
    figureColor = Color3.fromRGB(139, 0, 0)
}

local espInstances = {
    doors = {},
    keys = {},
    entities = {}
}

-- Create UI
local Window = Arcane:CreateWindow("Doors ESP", Vector2.new(650, 450), "Synthwave84")

-- Tab Sections
Window:CreateTabSection("Main")
Window:CreateTabSection("Visuals")

-- Tabs
local MainTab = Window:CreateTab("Main")
local VisualsTab = Window:CreateTab("Visuals")

-- Sections
local EntitySection = Window:CreateSection("Entity Detection", "Main")
local MovementSection = Window:CreateSection("Movement", "Main")
local DoorSection = Window:CreateSection("Door ESP", "Visuals")
local KeySection = Window:CreateSection("Key ESP", "Visuals")
local FigureSection = Window:CreateSection("Figure ESP", "Visuals")
local ColorSection = Window:CreateSection("Colors", "Visuals")

-- Entity Detection Toggles
EntitySection:AddToggle("Entity Notifications", CONFIG.entityNotify, function(value)
    CONFIG.entityNotify = value
    Arcane:Notify("Settings", "Entity notifications " .. (value and "enabled" or "disabled"), 3)
end)

EntitySection:AddToggle("Entity ESP", CONFIG.entityESP, function(value)
    CONFIG.entityESP = value
    if not value then
        for _, esp in pairs(espInstances.entities) do
            if esp and esp.Destroy then
                esp:Destroy()
            end
        end
        espInstances.entities = {}
    end
    Arcane:Notify("ESP", "Entity ESP " .. (value and "enabled" or "disabled"), 3)
end)

-- Movement Section
MovementSection:AddSlider("Speed Boost", {
    Min = 0, 
    Max = 10, 
    Default = 0, 
    Callback = function(value)
        CONFIG.speedBoost = value
        if player.Character then
            player.Character:SetAttribute("SpeedBoost", value)
        end
    end
})

-- Door ESP Section
DoorSection:AddToggle("Enable Door ESP", CONFIG.doorESP, function(value)
    CONFIG.doorESP = value
    if not value then
        for _, esp in pairs(espInstances.doors) do
            if esp and esp.Destroy then
                esp:Destroy()
            end
        end
        espInstances.doors = {}
    end
    Arcane:Notify("ESP", "Door ESP " .. (value and "enabled" or "disabled"), 3)
end)

-- Key ESP Section
KeySection:AddToggle("Enable Key ESP", CONFIG.keyESP, function(value)
    CONFIG.keyESP = value
    if not value then
        for _, esp in pairs(espInstances.keys) do
            if esp and esp.Destroy then
                esp:Destroy()
            end
        end
        espInstances.keys = {}
    end
    Arcane:Notify("ESP", "Key ESP " .. (value and "enabled" or "disabled"), 3)
end)

-- Figure ESP Section
FigureSection:AddToggle("Enable Figure ESP", CONFIG.figureESP, function(value)
    CONFIG.figureESP = value
    if not value then
        if espInstances.entities["Figure50"] then
            espInstances.entities["Figure50"]:Destroy()
            espInstances.entities["Figure50"] = nil
        end
        if espInstances.entities["Figure100"] then
            espInstances.entities["Figure100"]:Destroy()
            espInstances.entities["Figure100"] = nil
        end
    end
    Arcane:Notify("ESP", "Figure ESP " .. (value and "enabled" or "disabled"), 3)
end)

-- Color Pickers
ColorSection:AddColorPicker("Door Color", CONFIG.doorColor, function(color)
    CONFIG.doorColor = color
    for _, esp in pairs(espInstances.doors) do
        if esp and esp.Destroy then
            esp:Destroy()
        end
    end
    espInstances.doors = {}
end)

ColorSection:AddColorPicker("Key Color", CONFIG.keyColor, function(color)
    CONFIG.keyColor = color
    for _, esp in pairs(espInstances.keys) do
        if esp and esp.Destroy then
            esp:Destroy()
        end
    end
    espInstances.keys = {}
end)

ColorSection:AddColorPicker("Entity Color", CONFIG.entityColor, function(color)
    CONFIG.entityColor = color
end)

ColorSection:AddColorPicker("Figure Color", CONFIG.figureColor, function(color)
    CONFIG.figureColor = color
    if espInstances.entities["Figure50"] then
        espInstances.entities["Figure50"]:Destroy()
        espInstances.entities["Figure50"] = nil
    end
    if espInstances.entities["Figure100"] then
        espInstances.entities["Figure100"]:Destroy()
        espInstances.entities["Figure100"] = nil
    end
end)

-- Utility Functions
local function getdistance(part)
    if not player.Character or not player.Character.HumanoidRootPart then
        return 0
    end
    local one = player.Character.HumanoidRootPart.Position
    local two = part.Position
    local Vmag = vector.magnitude(vector.create(one.X, one.Y, one.Z) - vector.create(two.X, two.Y, two.Z))
    return math.round(Vmag)
end

local function getrooms()
    if not rooms then return {current = 0, next = 0} end
    
    local highest = 0
    for _, v in pairs(rooms:GetChildren()) do
        local n = tonumber(v.Name)
        if n and n > highest then
            highest = n
        end
    end
    
    return {
        current = highest - 1,
        next = highest
    }
end

local function notifyEntity(entityName)
    if CONFIG.entityNotify then
        Arcane:Notify("ENTITY ALERT", entityName .. " SPAWNED!", 2)
        
        -- Flash Warning
        local vSize = workspace.CurrentCamera.ViewportSize
        local warning = Drawing.new("Text")
        warning.Text = "⚠️ " .. entityName .. " SPAWNED!"
        warning.Size = 80
        warning.Color = Color3.fromRGB(255, 0, 0)
        warning.Outline = true
        warning.Position = Vector2.new(vSize.X / 2 - 250, vSize.Y / 2)
        warning.Visible = true
        
        task.spawn(function()
            task.wait(2)
            warning:Remove()
        end)
    end
end

-- Entity Detection with Arcane ESP
local notifiedEntities = {}
local function EntityDetectionLoop()
    while true do
        task.wait(0.5)
        
        -- Clean up destroyed entities
        for entity in pairs(notifiedEntities) do
            if not entity.Parent then
                notifiedEntities[entity] = nil
                if espInstances.entities[entity] then
                    espInstances.entities[entity]:Destroy()
                    espInstances.entities[entity] = nil
                end
            end
        end
        
        -- Check for Rush
        local rush = workspace:FindFirstChild("RushMoving")
        if rush and not notifiedEntities[rush] then
            notifyEntity("RUSH")
            notifiedEntities[rush] = true
            
            if CONFIG.entityESP then
                espInstances.entities[rush] = ArcaneEsp.new(rush)
                    :AddEsp(CONFIG.entityColor)
                    :AddTitle(Color3.new(1, 1, 1), "RUSH")
                    :AddDistance(Color3.new(1, 1, 1))
                    :AddGlow(CONFIG.entityColor, 10)
            end
        end
        
        -- Check for Ambush
        local ambush = workspace:FindFirstChild("AmbushMoving")
        if ambush and not notifiedEntities[ambush] then
            notifyEntity("AMBUSH")
            notifiedEntities[ambush] = true
            
            if CONFIG.entityESP then
                espInstances.entities[ambush] = ArcaneEsp.new(ambush)
                    :AddEsp(CONFIG.entityColor)
                    :AddTitle(Color3.new(1, 1, 1), "AMBUSH")
                    :AddDistance(Color3.new(1, 1, 1))
                    :AddGlow(CONFIG.entityColor, 10)
            end
        end
        
        -- Check for Eyes
        local eyes = workspace:FindFirstChild("Eyes")
        if eyes and not notifiedEntities[eyes] then
            notifyEntity("EYES")
            notifiedEntities[eyes] = true
            
            if CONFIG.entityESP then
                espInstances.entities[eyes] = ArcaneEsp.new(eyes)
                    :AddEsp(Color3.fromRGB(255, 255, 0))
                    :AddTitle(Color3.new(1, 1, 1), "EYES")
                    :AddDistance(Color3.new(1, 1, 1))
                    :AddGlow(Color3.fromRGB(255, 255, 0), 10)
            end
        end
    end
end

-- Door ESP with Arcane ESP
local function DoorESPLoop()
    while true do
        task.wait(1)
        
        if not CONFIG.doorESP or not rooms then
            continue
        end
        
        local roomInfo = getrooms()
        local currentRoom = roomInfo.current
        local nextRoom = roomInfo.next
        
        -- ESP for current and next door
        for _, roomNum in ipairs({currentRoom, nextRoom}) do
            local room = rooms:FindFirstChild(tostring(roomNum))
            if room then
                local door = room:FindFirstChild("Door")
                if door and door:FindFirstChild("Collision") then
                    local collision = door.Collision
                    
                    -- Create ESP if not exists
                    if not espInstances.doors[roomNum] then
                        local requiresKey = door.Parent:GetAttribute("RequiresKey") == true
                        local doorLabel = "Door " .. roomNum .. (requiresKey and " 🔑" or "")
                        
                        espInstances.doors[roomNum] = ArcaneEsp.new(collision)
                            :AddEsp(CONFIG.doorColor)
                            :AddTitle(Color3.new(1, 1, 1), doorLabel)
                            :AddDistance(Color3.new(1, 1, 1))
                    end
                end
            end
        end
        
        -- Clean up old door ESP
        for roomNum, esp in pairs(espInstances.doors) do
            if roomNum < currentRoom - 1 then
                esp:Destroy()
                espInstances.doors[roomNum] = nil
            end
        end
    end
end

-- Key ESP with Arcane ESP
local function KeyESPLoop()
    while true do
        task.wait(2)
        
        if not CONFIG.keyESP or not rooms then
            continue
        end
        
        local roomInfo = getrooms()
        
        -- Check rooms for keys (wider range)
        for i = roomInfo.current - 1, roomInfo.next + 2 do
            local room = rooms:FindFirstChild(tostring(i))
            if room then
                -- Check in Assets folder for KeyObtain
                local assets = room:FindFirstChild("Assets")
                if assets then
                    local keyObtain = assets:FindFirstChild("KeyObtain")
                    if keyObtain then
                        local hitbox = keyObtain:FindFirstChild("Hitbox")
                        
                        if hitbox and not espInstances.keys[keyObtain] then
                            espInstances.keys[keyObtain] = ArcaneEsp.new(hitbox)
                                :AddEsp(CONFIG.keyColor)
                                :AddTitle(Color3.new(1, 1, 1), "🔑 KEY")
                                :AddDistance(Color3.new(1, 1, 1))
                                :AddGlow(CONFIG.keyColor, 8)
                        end
                    end
                    
                    -- Also check Parts folder (backup)
                    local parts = room:FindFirstChild("Parts")
                    if parts then
                        for _, v in pairs(parts:GetDescendants()) do
                            if v:IsA("Model") and string.find(string.lower(v.Name), "key") then
                                local keyPart = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                                
                                if keyPart and not espInstances.keys[v] then
                                    espInstances.keys[v] = ArcaneEsp.new(keyPart)
                                        :AddEsp(CONFIG.keyColor)
                                        :AddTitle(Color3.new(1, 1, 1), "🔑 KEY")
                                        :AddDistance(Color3.new(1, 1, 1))
                                        :AddGlow(CONFIG.keyColor, 8)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Cleanup collected keys
        for key, esp in pairs(espInstances.keys) do
            if not key.Parent then
                esp:Destroy()
                espInstances.keys[key] = nil
            end
        end
    end
end

-- Figure ESP Loop (Simplified)
local function FigureESPLoop()
    while true do
        task.wait(0.5)
        
        if not CONFIG.figureESP or not rooms then
            continue
        end
        
        local roomInfo = getrooms()
        local currentRoom = roomInfo.current
        
        -- Check Room 50
        if currentRoom >= 49 and currentRoom <= 51 then
            local room50 = rooms:FindFirstChild("50")
            if room50 then
                local figureSetup = room50:FindFirstChild("FigureSetup")
                if figureSetup then
                    local figureRig = figureSetup:FindFirstChild("FigureRig")
                    if figureRig and not espInstances.entities["Figure50"] then
                        notifyEntity("FIGURE")
                        
                        local figurePart = figureRig:FindFirstChild("HumanoidRootPart") or figureRig:FindFirstChildWhichIsA("BasePart")
                        if figurePart then
                            espInstances.entities["Figure50"] = ArcaneEsp.new(figurePart)
                                :AddEsp(CONFIG.figureColor)
                        end
                    end
                end
            end
        else
            if espInstances.entities["Figure50"] then
                espInstances.entities["Figure50"]:Destroy()
                espInstances.entities["Figure50"] = nil
            end
        end
        
        -- Check Room 100
        if currentRoom >= 99 and currentRoom <= 101 then
            local room100 = rooms:FindFirstChild("100")
            if room100 then
                local figureSetup = room100:FindFirstChild("FigureSetup")
                if figureSetup then
                    local figureRig = figureSetup:FindFirstChild("FigureRig")
                    if figureRig and not espInstances.entities["Figure100"] then
                        notifyEntity("FIGURE")
                        
                        local figurePart = figureRig:FindFirstChild("HumanoidRootPart") or figureRig:FindFirstChildWhichIsA("BasePart")
                        if figurePart then
                            espInstances.entities["Figure100"] = ArcaneEsp.new(figurePart)
                                :AddEsp(CONFIG.figureColor)
                        end
                    end
                end
            end
        else
            if espInstances.entities["Figure100"] then
                espInstances.entities["Figure100"]:Destroy()
                espInstances.entities["Figure100"] = nil
            end
        end
    end
end

-- Finalize Window
Window:Finalize()

-- Start all loops
spawn(EntityDetectionLoop)
spawn(DoorESPLoop)
spawn(KeyESPLoop)
spawn(FigureESPLoop)

-- Initial notifications
Arcane:Log("Doors ESP initialized successfully!", 3)
Arcane:Notify("Welcome", "Doors ESP Loaded!", 5)

print("[Matcha Doors] Script loaded - Optimized")
