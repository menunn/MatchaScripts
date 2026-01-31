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
    

    -- Figure ESP Loop (NUEVO)
    spawn(function()
        while true do
            task.wait(0.5)
            
            if not Config.entityESP or not Config.rooms then
                continue
            end
            
            local roomInfo = Config.getRooms()
            local currentRoom = roomInfo.current
            
            -- Check if we're in room 50 or 100
            if currentRoom >= 49 and currentRoom <= 51 then
                local room50 = Config.rooms:FindFirstChild("50")
                if room50 then
                    local figureSetup = room50:FindFirstChild("FigureSetup")
                    if figureSetup then
                        local figureRig = figureSetup:FindFirstChild("FigureRig")
                        if figureRig and not Config.espInstances.entities["Figure50"] then
                            Config.notifyEntity("FIGURE")
                            
                            local figurePart = figureRig:FindFirstChild("HumanoidRootPart") or figureRig:FindFirstChildWhichIsA("BasePart")
                            if figurePart then
                                Config.espInstances.entities["Figure50"] = ArcaneEsp.new(figurePart)
                                    :AddEsp(Color3.fromRGB(139, 0, 0))
                                    :AddTitle(Color3.new(1, 1, 1), "⚠️ FIGURE")
                                    :AddDistance(Color3.new(1, 0, 0))
                                    :AddGlow(Color3.fromRGB(139, 0, 0), 15)
                            end
                        end
                    end
                end
            else
                -- Clean up Figure ESP when leaving room 50
                if Config.espInstances.entities["Figure50"] then
                    Config.espInstances.entities["Figure50"]:Destroy()
                    Config.espInstances.entities["Figure50"] = nil
                end
            end
            
            -- Check for room 100 Figure
            if currentRoom >= 99 and currentRoom <= 101 then
                local room100 = Config.rooms:FindFirstChild("100")
                if room100 then
                    local figureSetup = room100:FindFirstChild("FigureSetup")
                    if figureSetup then
                        local figureRig = figureSetup:FindFirstChild("FigureRig")
                        if figureRig and not Config.espInstances.entities["Figure100"] then
                            Config.notifyEntity("FIGURE")
                            
                            local figurePart = figureRig:FindFirstChild("HumanoidRootPart") or figureRig:FindFirstChildWhichIsA("BasePart")
                            if figurePart then
                                Config.espInstances.entities["Figure100"] = ArcaneEsp.new(figurePart)
                                    :AddEsp(Color3.fromRGB(139, 0, 0))
                                    :AddTitle(Color3.new(1, 1, 1), "⚠️ FIGURE")
                                    :AddDistance(Color3.new(1, 0, 0))
                                    :AddGlow(Color3.fromRGB(139, 0, 0), 15)
                            end
                        end
                    end
                end
            else
                -- Clean up Figure ESP when leaving room 100
                if Config.espInstances.entities["Figure100"] then
                    Config.espInstances.entities["Figure100"]:Destroy()
                    Config.espInstances.entities["Figure100"] = nil
                end
            end
        end
    end)
    
    -- Books ESP Loop (NUEVO)
    spawn(function()
        while true do
            task.wait(1)
            
            if not Config.keyESP or not Config.rooms then
                continue
            end
            
            local roomInfo = Config.getRooms()
            local currentRoom = roomInfo.current
            
            -- Check if we're in room 50 (Library)
            if currentRoom >= 49 and currentRoom <= 51 then
                local room50 = Config.rooms:FindFirstChild("50")
                if room50 then
                    local assets = room50:FindFirstChild("Assets")
                    if assets then
                        -- Find books in the library
                        for _, v in pairs(assets:GetDescendants()) do
                            if v:IsA("Model") and (string.find(string.lower(v.Name), "book") or v.Name == "LibraryHintPaper") then
                                -- Find the main part of the book
                                local bookPart = v:FindFirstChild("Base") or v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                                
                                if bookPart and not Config.espInstances.keys[v] then
                                    -- Check if book has Transparency to see if it's been collected
                                    if bookPart.Transparency < 1 then
                                        Config.espInstances.keys[v] = ArcaneEsp.new(bookPart)
                                            :AddEsp(Color3.fromRGB(255, 165, 0))
                                            :AddTitle(Color3.new(1, 1, 1), "📖 BOOK")
                                            :AddDistance(Color3.new(1, 1, 1))
                                            :AddGlow(Color3.fromRGB(255, 165, 0), 6)
                                    end
                                end
                            end
                            
                            -- Also check for the Solution Paper on the desk
                            if v.Name == "LibraryHintPaper" and not Config.espInstances.keys["SolutionPaper"] then
                                local paper = v:FindFirstChildWhichIsA("BasePart")
                                if paper then
                                    Config.espInstances.keys["SolutionPaper"] = ArcaneEsp.new(paper)
                                        :AddEsp(Color3.fromRGB(255, 255, 255))
                                        :AddTitle(Color3.new(1, 1, 1), "📄 SOLUTION")
                                        :AddDistance(Color3.new(1, 1, 1))
                                        :AddGlow(Color3.fromRGB(255, 255, 255), 8)
                                end
                            end
                        end
                    end
                end
            else
                -- Clean up books ESP when leaving room 50
                for key, esp in pairs(Config.espInstances.keys) do
                    if type(key) == "string" or (type(key) == "userdata" and key.Name and string.find(string.lower(key.Name), "book")) then
                        esp:Destroy()
                        Config.espInstances.keys[key] = nil
                    end
                end
            end
            
            -- Cleanup collected books
            for key, esp in pairs(Config.espInstances.keys) do
                if type(key) == "userdata" and not key.Parent then
                    esp:Destroy()
                    Config.espInstances.keys[key] = nil
                end
            end
        end
    end)

    Arcane:Log("ESP started", 2)
end

return ESP
