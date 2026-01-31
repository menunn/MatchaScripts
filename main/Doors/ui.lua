-- UI Module
local UI = {}

function UI.Init(Config)
    -- Create Window
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
    local ColorSection = Window:CreateSection("Colors", "Visuals")
    
    -- Entity Detection Toggles
    EntitySection:AddToggle("Entity Notifications", Config.entityNotify, function(value)
        Config.entityNotify = value
        Arcane:Notify("Settings", "Entity notifications " .. (value and "enabled" or "disabled"), 3)
    end)
    
    EntitySection:AddToggle("Entity ESP", Config.entityESP, function(value)
        Config.entityESP = value
        if not value then
            for _, esp in pairs(Config.espInstances.entities) do
                if esp and esp.Destroy then
                    esp:Destroy()
                end
            end
            Config.espInstances.entities = {}
        end
        Arcane:Notify("ESP", "Entity ESP " .. (value and "enabled" or "disabled"), 3)
    end)
    
    -- Movement Section
    MovementSection:AddSlider("Speed Boost", {
        Min = 0, 
        Max = 10, 
        Default = 0, 
        Callback = function(value)
            Config.speedBoost = value
            if Config.player.Character then
                Config.player.Character:SetAttribute("SpeedBoost", value)
            end
        end
    })
    
    -- Door ESP Section
    DoorSection:AddToggle("Enable Door ESP", Config.doorESP, function(value)
        Config.doorESP = value
        if not value then
            for _, esp in pairs(Config.espInstances.doors) do
                if esp and esp.Destroy then
                    esp:Destroy()
                end
            end
            Config.espInstances.doors = {}
        end
        Arcane:Notify("ESP", "Door ESP " .. (value and "enabled" or "disabled"), 3)
    end)
    
    -- Key ESP Section
    KeySection:AddToggle("Enable Key ESP", Config.keyESP, function(value)
        Config.keyESP = value
        if not value then
            for _, esp in pairs(Config.espInstances.keys) do
                if esp and esp.Destroy then
                    esp:Destroy()
                end
            end
            Config.espInstances.keys = {}
        end
        Arcane:Notify("ESP", "Key ESP " .. (value and "enabled" or "disabled"), 3)
    end)
    
    -- Color Pickers
    ColorSection:AddColorPicker("Door Color", Config.doorColor, function(color)
        Config.doorColor = color
        -- Recreate door ESP with new color
        for _, esp in pairs(Config.espInstances.doors) do
            if esp and esp.Destroy then
                esp:Destroy()
            end
        end
        Config.espInstances.doors = {}
    end)
    
    ColorSection:AddColorPicker("Key Color", Config.keyColor, function(color)
        Config.keyColor = color
        -- Recreate key ESP with new color
        for _, esp in pairs(Config.espInstances.keys) do
            if esp and esp.Destroy then
                esp:Destroy()
            end
        end
        Config.espInstances.keys = {}
    end)
    
    ColorSection:AddColorPicker("Entity Color", Config.entityColor, function(color)
        Config.entityColor = color
    end)
    
    -- Finalize Window
    Window:Finalize()
    
    Arcane:Log("UI initialized", 2)
end

return UI
