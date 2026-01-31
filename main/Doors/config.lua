-- Config Module
local Config = {
    -- Services
    workspace = game:GetService("Workspace"),
    players = game:GetService("Players"),
    player = game:GetService("Players").LocalPlayer,
    rooms = game:GetService("Workspace"):FindFirstChild("CurrentRooms"),
    
    -- Settings
    entityNotify = true,
    doorESP = true,
    keyESP = true,
    entityESP = true,
    speedBoost = 0,
    
    -- Colors
    doorColor = Color3.fromRGB(50, 255, 128),
    keyColor = Color3.fromRGB(255, 215, 0),
    entityColor = Color3.fromRGB(255, 0, 0),
    
    -- ESP Instances Storage
    espInstances = {
        doors = {},
        keys = {},
        entities = {}
    },
    
    -- Notified entities tracking
    notifiedEntities = {}
}

-- Utility Functions
function Config.getDistance(part)
    if not Config.player.Character or not Config.player.Character.HumanoidRootPart then
        return 0
    end
    local one = Config.player.Character.HumanoidRootPart.Position
    local two = part.Position
    local Vmag = vector.magnitude(vector.create(one.X, one.Y, one.Z) - vector.create(two.X, two.Y, two.Z))
    return math.round(Vmag)
end

function Config.getRooms()
    if not Config.rooms then return {current = 0, next = 0} end
    
    local highest = 0
    for _, v in pairs(Config.rooms:GetChildren()) do
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

function Config.notifyEntity(entityName)
    if Config.entityNotify then
        Arcane:Notify("ENTITY ALERT", entityName .. " SPAWNED!", 5)
        
        -- Flash Warning
        local vSize = Config.workspace.CurrentCamera.ViewportSize
        local warning = Drawing.new("Text")
        warning.Text = "⚠️ " .. entityName .. " SPAWNED! ⚠️"
        warning.Size = 200
        warning.Color = Color3.fromRGB(255, 0, 0)
        warning.Outline = true
        warning.Position = Vector2.new(vSize.X / 2 - 250, vSize.Y / 2)
        warning.Visible = true
        
        task.spawn(function()
            task.wait(3)
            warning:Remove()
        end)
    end
end

return Config
