-- ESP Module
local ESP = {}

function ESP.Init(Config)
    -- Entity Detection Loop
    spawn(function()
        while true do
            task.wait(0.5)
            
            -- Clean up destroyed entities
            for entity in pairs(Config.notifiedEntities) do
                if not entity.Parent then
                    Config.notifiedEntities[entity] = nil
                    if Config.espInstances.entities[entity] then
                        Config.espInstances.entities[entity]:Destroy()
                        Config.espInstances.entities[entity] = nil
                    end
                end
            end
            
            -- Check for Rush
            local rush = Config.workspace:FindFirstChild("RushMoving")
            if rush and not Config.notifiedEntities[rush] then
                Config.notifyEntity("RUSH")
                Config.notifiedEntities[rush] = true
                
                if Config.entityESP then
                    Config.espInstances.entities[rush] = ArcaneEsp.new(rush)
                        :AddEsp(Config.entityColor)
                        :AddTitle(Color3.new(1, 1, 1), "RUSH")
                        :AddDistance(Color3.new(1, 1, 1))
                        :AddGlow(Config.entityColor, 10)
                end
            end
            
            -- Check for Ambush
            local ambush = Config.workspace:FindFirstChild("AmbushMoving")
            if ambush and not Config.notifiedEntities[ambush] then
                Config.notifyEntity("AMBUSH")
                Config.notifiedEntities[ambush] = true
                
                if Config.entityESP then
                    Config.espInstances.entities[ambush] = ArcaneEsp.new(ambush)
                        :AddEsp(Config.entityColor)
                        :AddTitle(Color3.new(1, 1, 1), "AMBUSH")
                        :AddDistance(Color3.new(1, 1, 1))
                        :AddGlow(Config.entityColor, 10)
                end
            end
            
            -- Check for Eyes
            local eyes = Config.workspace:FindFirstChild("Eyes")
            if eyes and not Config.notifiedEntities[eyes] then
                Config.notifyEntity("EYES")
                Config.notifiedEntities[eyes] = true
                
                if Config.entityESP then
                    Config.espInstances.entities[eyes] = ArcaneEsp.new(eyes)
                        :AddEsp(Color3.fromRGB(255, 255, 0))
                        :AddTitle(Color3.new(1, 1, 1), "EYES")
                        :AddDistance(Color3.new(1, 1, 1))
                        :AddGlow(Color3.fromRGB(255, 255, 0), 10)
                end
            end
        end
    end)
    
    -- Door ESP Loop
    spawn(function()
        while true do
            task.wait(1)
            
            if not Config.doorESP or not Config.rooms then
                continue
            end
            
            local roomInfo = Config.getRooms()
            local currentRoom = roomInfo.current
            local nextRoom = roomInfo.next
            
            -- ESP for current and next door
            for _, roomNum in ipairs({currentRoom, nextRoom}) do
                local room = Config.rooms:FindFirstChild(tostring(roomNum))
                if room then
                    local door = room:FindFirstChild("Door")
                    if door and door:FindFirstChild("Collision") then
                        local collision = door.Collision
                        
                        -- Create ESP if not exists
                        if not Config.espInstances.doors[roomNum] then
                            local requiresKey = door.Parent:GetAttribute("RequiresKey") == true
                            local doorLabel = "Door " .. roomNum .. (requiresKey and " 🔑" or "")
                            
                            Config.espInstances.doors[roomNum] = ArcaneEsp.new(collision)
                                :AddEsp(Config.doorColor)
                                :AddTitle(Color3.new(1, 1, 1), doorLabel)
                                :AddDistance(Color3.new(1, 1, 1))
                        end
                    end
                end
            end
            
            -- Clean up old door ESP
            for roomNum, esp in pairs(Config.espInstances.doors) do
                if roomNum < currentRoom - 1 then
                    esp:Destroy()
                    Config.espInstances.doors[roomNum] = nil
                end
            end
        end
    end)
    
    -- Key ESP Loop
    spawn(function()
        while true do
            task.wait(2)
            
            if not Config.keyESP or not Config.rooms then
                continue
            end
            
            local roomInfo = Config.getRooms()
            
            -- Check rooms for keys
            for i = roomInfo.current, roomInfo.next + 1 do
                local room = Config.rooms:FindFirstChild(tostring(i))
                if room then
                    local parts = room:FindFirstChild("Parts")
                    if parts then
                        for _, v in pairs(parts:GetDescendants()) do
                            if v:IsA("Model") and string.find(string.lower(v.Name), "key") then
                                local keyPart = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                                
                                if keyPart and not Config.espInstances.keys[v] then
                                    Config.espInstances.keys[v] = ArcaneEsp.new(keyPart)
                                        :AddEsp(Config.keyColor)
                                        :AddTitle(Color3.new(1, 1, 1), "🔑 KEY")
                                        :AddDistance(Color3.new(1, 1, 1))
                                        :AddGlow(Config.keyColor, 8)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Cleanup collected keys
            for key, esp in pairs(Config.espInstances.keys) do
                if not key.Parent then
                    esp:Destroy()
                    Config.espInstances.keys[key] = nil
                end
            end
        end
    end)
    
    Arcane:Log("ESP loops started", 2)
end

return ESP
