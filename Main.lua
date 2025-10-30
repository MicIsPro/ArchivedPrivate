local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local tpwalking = false
local speedMultiplier = 5
local noclipping = false
local infJumping = false
local autoDropActive = false
local infJump, noclipLoop, speedConnection
local espEnabled = false
local espShowDistance = true
local espShowHP = true
local espShowTracers = true
local npcEspEnabled = false
local npcEspShowHP = true
local npcEspShowTracers = true
local espConnections = {}
local npcEspConnections = {}
local Camera = workspace.CurrentCamera
local specialUsers = {
    ["CropCollector"] = true,
    ["Devotion_M"] = true,
    ["AzrisKitten"] = true,
    ["jcsseai"] = true
}
local friendsList = {}

local Window = Library:CreateWindow({
    Title = "Archived",
    Footer = "Private Gui - Devotion_M on discord",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ESP = Window:AddTab("ESP", "eye"),
    LCorp = Window:AddTab("L.Corp", "building"),
    AutoDrop = Window:AddTab("Auto Drop", "trash-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local teleportPositions = {
    {name = "Bar", pos = Vector3.new(441, -7, 438)},
    {name = "Syndicate Office", pos = Vector3.new(-658, -8, 971)},
    {name = "Darius", pos = Vector3.new(130, 30, 851)},
    {name = "Subway", pos = Vector3.new(48, 0, 681)},
    {name = "Dumpster Guy", pos = Vector3.new(298, 64, -149)},
    {name = "Stranger", pos = Vector3.new(-181, -200, 576)}
}

local questtps = {
    {name = "Docks Delivery", npc = "Twinhook Pirate"},
    {name = "L.Corp", pos = Vector3.new(1005, 27, 1150)},
    {name = "Warp Train", pos = Vector3.new(620, -7, 408)},
}
local mainAreas = {
    {name = "Main", pos = Vector3.new(-6, 980, 198)},
    {name = "Boss Arena", pos = Vector3.new(50, 980, 367)},
    {name = "Storage", pos = Vector3.new(269, 980, -212)},
    {name = "Extraction Machine", pos = Vector3.new(132, 980, -31)},
    {name = "Exit", pos = Vector3.new(88, 980, -84)},
    {name = "Spawn", pos = Vector3.new(-197, 967, -232)},
}

local gates = {
    {name = "Orange Gate", pos = Vector3.new(-234, 980, 187)},
    {name = "Purple Gate", pos = Vector3.new(-36, 980, 28)},
    {name = "Green Gate", pos = Vector3.new(244, 980, 62)},
    {name = "Yellow Gate", pos = Vector3.new(48, 980, -308)},
    {name = "Mirror Shard", pos = Vector3.new(-338, 980, 0)},
}

local generators = {
    {name = "Generator 1", pos = Vector3.new(283, 980, -180)},
    {name = "Generator 2", pos = Vector3.new(205, 980, 43)},
    {name = "Generator 3", pos = Vector3.new(60, 980, 126)},
    {name = "Generator 4", pos = Vector3.new(-165, 980, -85)},
}

local lootItems = {
    {name = "L.Corp Chest 1", pos = Vector3.new(330, 987, -229)},
    {name = "L.Corp Chest 2", pos = Vector3.new(95, 1016, 216)},
    {name = "L.Corp Chest 3", pos = Vector3.new(104, 1016, 216)},
    {name = "L.Corp Chest 4", pos = Vector3.new(28, 1005, 145)},
    {name = "Heavy Shelf 1", pos = Vector3.new(337, 987, -224)},
    {name = "Heavy Shelf 2", pos = Vector3.new(337, 987, -203)},
    {name = "Heavy Shelf 3", pos = Vector3.new(282, 980, -197)},
    {name = "Heavy Crate 1", pos = Vector3.new(301, 987, -223)},
    {name = "Heavy Crate 2", pos = Vector3.new(301, 987, -187)},
    {name = "Heavy Crate 3", pos = Vector3.new(302, 987, -202)},
    {name = "Heavy Crate 4", pos = Vector3.new(318, 987, -161)},
}

local medicalItems = {
    {name = "Medical 1", pos = Vector3.new(-6, 980, -258)},
    {name = "Medical 2", pos = Vector3.new(276, 983, -282)},
    {name = "Medical 3", pos = Vector3.new(332, 999, -235)},
    {name = "Medical 4", pos = Vector3.new(273, 980, -52)},
    {name = "Medical 5", pos = Vector3.new(249, 980, 155)},
    {name = "Medical 6", pos = Vector3.new(17, 980, 267)},
    {name = "Medical 7", pos = Vector3.new(-328, 980, -156)},
    {name = "Medical 8", pos = Vector3.new(-218, 980, -10)},
    {name = "Medical 9", pos = Vector3.new(-173, 980, 67)},
    {name = "Medical 10", pos = Vector3.new(95, 980, -10)},
    {name = "Medical 11", pos = Vector3.new(-127, 968, -200)},
}

local barrels = {
    {name = "Barrel 1", pos = Vector3.new(316, 987, -202)},
    {name = "Barrel 2", pos = Vector3.new(306, 980, 32)},
    {name = "Barrel 3", pos = Vector3.new(102, 980, 261)},
    {name = "Barrel 4", pos = Vector3.new(60, 1005, 131)},
    {name = "Barrel 5", pos = Vector3.new(-132, 980, -169)},
    {name = "Barrel 6", pos = Vector3.new(-181, 980, 170)},
}

local itemsToDrop = {
    "Makeshift Handle", "Rope", "Low Quality Blade", "Book", "Organs", "Wiring",
    "Book Of a Grade 9 Fixer", "Book Of a Grade 7 Fixer", "Book Of Zwei Association",
    "Book Of Hana Association", "Book Of Shi Association", "Book Of Stray Dogs",
    "Scrap Metal", "Gun Parts", "Heavy Handle", "Gears", "Handle", "Light Handle", "Dual Handle"
}

local function teleportToPosition(position)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
end

local function instantTeleport(position)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    humanoidRootPart.CFrame = CFrame.new(position)
end

local function addTeleportButtons(groupBox, positions)
    for _, pos in ipairs(positions) do
        groupBox:AddButton({
            Text = pos.name,
            Func = function() teleportToPosition(pos.pos) end,
            Tooltip = "Teleport to " .. pos.name,
        })
    end
end

local function addToggleWithKeybind(groupBox, id, text, keyId, onFunc, offFunc)
    local toggle = groupBox:AddToggle(id, {
        Text = text,
        Default = false,
        Callback = function(Value)
            if Value then onFunc() else offFunc() end
        end,
    })
    toggle:AddKeyPicker(keyId, {
        Text = text,
        Mode = "Toggle",
        Callback = function()
            toggle:SetValue(not Toggles[id].Value)
        end,
    })
end

local function startTpWalk()
    tpwalking = true
    if speedConnection then speedConnection:Disconnect() end
    
    speedConnection = RunService.Heartbeat:Connect(function(delta)
        if not tpwalking then return end
        
        local chr = LocalPlayer.Character
        if not chr then return end
        
        local hum = chr:FindFirstChildWhichIsA("Humanoid")
        local hrp = chr:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * speedMultiplier * delta * 10)
        end
    end)
end

local function stopTpWalk()
    tpwalking = false
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end

local function startNoclip()
    noclipping = true
    wait(0.1)
    if noclipLoop then noclipLoop:Disconnect() end
    noclipLoop = RunService.Stepped:Connect(function()
        if noclipping and LocalPlayer.Character then
            for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    noclipping = false
    if noclipLoop then
        noclipLoop:Disconnect()
        noclipLoop = nil
    end
    local character = LocalPlayer.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") and not child.Parent:IsA("Accessory") and not child.Parent:IsA("Model") and child.Name ~= "HumanoidRootPart" then
                child.CanCollide = true
            end
        end
    end
end

local function startInfJump()
    infJumping = true
    if infJump then infJump:Disconnect() end
    infJump = UserInputService.JumpRequest:Connect(function()
        if infJumping then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

local function stopInfJump()
    infJumping = false
    if infJump then
        infJump:Disconnect()
        infJump = nil
    end
end

local function autoDrop()
    local character = LocalPlayer.Character
    if not character then return end
    local backpack = LocalPlayer.Backpack
    local function findAllItems(itemName)
        local items = {}
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name == itemName then
                table.insert(items, item)
            end
        end
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == itemName then
                table.insert(items, item)
            end
        end
        return items
    end
    local DropItem = ReplicatedStorage.Events.DropItem
    for _, itemName in ipairs(itemsToDrop) do
        local items = findAllItems(itemName)
        for _, item in ipairs(items) do
            DropItem:FireServer(item)
            wait(0)
        end
    end
end

local function loadRobloxFriends()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local success, isFriend = pcall(function()
                return LocalPlayer:IsFriendsWith(player.UserId)
            end)
            if success and isFriend then
                friendsList[player.Name] = true
            end
        end
    end
end

local function getPlayerColor(player)
    if specialUsers[player.Name] then
        return Color3.fromRGB(200, 100, 255)
    elseif friendsList[player.Name] then
        return Color3.fromRGB(100, 200, 255)
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

local function getDistance(player)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

local function _getNPCDistance(npc)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local npcHRP = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
    if not npcHRP then return 0 end
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - npcHRP.Position).Magnitude
    return math.floor(distance)
end

local function getDistanceColor(distance)
    if distance < 100 then
        return Color3.fromRGB(255, 50, 50)
    elseif distance < 300 then
        return Color3.fromRGB(255, 165, 0)
    else
        return Color3.fromRGB(50, 255, 50)
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    if espConnections[player.Name] then return end
    
    local function createESPGui()
        if not player.Character or not player.Character:FindFirstChild("Head") then return end
        
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "ESP_" .. player.Name
        espGui.Parent = player.Character.Head
        espGui.Size = UDim2.new(0, 250, 0, 80)
        espGui.StudsOffset = Vector3.new(0, 3, 0)
        espGui.AlwaysOnTop = true
        
        local playerColor = getPlayerColor(player)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = playerColor
        nameLabel.TextSize = 18
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.Parent = espGui
        
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Name = "HPLabel"
        hpLabel.Size = UDim2.new(1, -10, 0, 22)
        hpLabel.Position = UDim2.new(0, 5, 0, 30)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        hpLabel.TextSize = 16
        hpLabel.Font = Enum.Font.GothamBold
        hpLabel.TextStrokeTransparency = 0.3
        hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        hpLabel.TextXAlignment = Enum.TextXAlignment.Center
        hpLabel.Visible = espShowHP
        hpLabel.Parent = espGui
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Size = UDim2.new(1, -10, 0, 20)
        distanceLabel.Position = UDim2.new(0, 5, 0, 55)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        distanceLabel.TextSize = 16
        distanceLabel.Font = Enum.Font.GothamBold
        distanceLabel.TextStrokeTransparency = 0.2
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        distanceLabel.Visible = espShowDistance
        distanceLabel.Parent = espGui
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 2
        tracer.Transparency = 0.8
        
        local function updateInfo()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character.Humanoid
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local healthPercent = (health / maxHealth) * 100
                
                if espShowHP then
                    if healthPercent > 66 then
                        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    elseif healthPercent > 33 then
                        hpLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                    else
                        hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                    hpLabel.Text = "❤ " .. health .. "/" .. maxHealth
                    hpLabel.Visible = true
                else
                    hpLabel.Visible = false
                end
                
                local distance = getDistance(player)
                if espShowDistance then
                    distanceLabel.Text = "📍 " .. distance .. " studs"
                    local distColor = getDistanceColor(distance)
                    distanceLabel.TextColor3 = distColor
                    distanceLabel.Visible = true
                else
                    distanceLabel.Visible = false
                end
                
                if espShowTracers and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = player.Character.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    local distColor = getDistanceColor(distance)
                    
                    if onScreen then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = distColor
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end
        
        updateInfo()
        
        local updateConnection = RunService.Heartbeat:Connect(updateInfo)
        
        return espGui, updateConnection, tracer
    end
    
    local espGui, updateConnection, tracer = createESPGui()
    
    local charConnection = player.CharacterAdded:Connect(function()
        if espGui then espGui:Destroy() end
        if updateConnection then updateConnection:Disconnect() end
        if tracer then tracer:Remove() end
        wait(1)
        espGui, updateConnection, tracer = createESPGui()
        if espConnections[player.Name] then
            espConnections[player.Name].updateConnection = updateConnection
            espConnections[player.Name].espGui = espGui
            espConnections[player.Name].tracer = tracer
        end
    end)
    
    espConnections[player.Name] = {
        charConnection = charConnection,
        updateConnection = updateConnection,
        espGui = espGui,
        tracer = tracer
    }
end

local function removeESP(player)
    if espConnections[player.Name] then
        local connections = espConnections[player.Name]
        if connections.charConnection then connections.charConnection:Disconnect() end
        if connections.updateConnection then connections.updateConnection:Disconnect() end
        if connections.espGui then connections.espGui:Destroy() end
        if connections.tracer then connections.tracer:Remove() end
        espConnections[player.Name] = nil
    end
end

local function removeAllESP()
    for playerName, _ in pairs(espConnections) do
        local player = Players:FindFirstChild(playerName)
        if player then
            removeESP(player)
        end
    end
end

local function startESP()
    loadRobloxFriends()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
end

local function updateESPVisibility()
    for playerName, connections in pairs(espConnections) do
        if connections.espGui then
            local hpLabel = connections.espGui:FindFirstChild("HPLabel")
            local distLabel = connections.espGui:FindFirstChild("DistanceLabel")
            if hpLabel then hpLabel.Visible = espShowHP end
            if distLabel then distLabel.Visible = espShowDistance end
        end
    end
end

local function createNPCESP(npc)
    local npcId = tostring(npc)
    if npcEspConnections[npcId] then return end
    
    local function createNPCESPGui()
        local head = npc:FindFirstChild("Head")
        if not head then return end
        
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "NPCESP_" .. npc.Name
        espGui.Parent = head
        espGui.Size = UDim2.new(0, 200, 0, 50)
        espGui.StudsOffset = Vector3.new(0, 3, 0)
        espGui.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 20)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = npc.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        nameLabel.TextSize = 16
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.Parent = espGui
        
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Name = "HPLabel"
        hpLabel.Size = UDim2.new(1, -10, 0, 20)
        hpLabel.Position = UDim2.new(0, 5, 0, 25)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        hpLabel.TextSize = 14
        hpLabel.Font = Enum.Font.GothamBold
        hpLabel.TextStrokeTransparency = 0.3
        hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        hpLabel.TextXAlignment = Enum.TextXAlignment.Center
        hpLabel.Visible = npcEspShowHP
        hpLabel.Parent = espGui
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 2
        tracer.Transparency = 0.8
        tracer.Color = Color3.fromRGB(255, 100, 100)
        
        local function updateInfo()
            if npc and npc:FindFirstChild("Humanoid") then
                local humanoid = npc.Humanoid
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local healthPercent = (health / maxHealth) * 100
                
                if npcEspShowHP then
                    if healthPercent > 66 then
                        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    elseif healthPercent > 33 then
                        hpLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                    else
                        hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                    hpLabel.Text = "❤ " .. health .. "/" .. maxHealth
                    hpLabel.Visible = true
                else
                    hpLabel.Visible = false
                end
                
                if npcEspShowTracers and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                    if npcHRP then
                        local vector, onScreen = Camera:WorldToViewportPoint(npcHRP.Position)
                        
                        if onScreen then
                            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            tracer.To = Vector2.new(vector.X, vector.Y)
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end
        
        updateInfo()
        
        local updateConnection = RunService.Heartbeat:Connect(updateInfo)
        
        return espGui, updateConnection, tracer
    end
    
    local espGui, updateConnection, tracer = createNPCESPGui()
    
    npcEspConnections[npcId] = {
        updateConnection = updateConnection,
        espGui = espGui,
        tracer = tracer,
        npc = npc
    }
end

local function removeNPCESP(npc)
    local npcId = tostring(npc)
    if npcEspConnections[npcId] then
        local connections = npcEspConnections[npcId]
        if connections.updateConnection then connections.updateConnection:Disconnect() end
        if connections.espGui then connections.espGui:Destroy() end
        if connections.tracer then connections.tracer:Remove() end
        npcEspConnections[npcId] = nil
    end
end

local function removeAllNPCESP()
    for npcId, connections in pairs(npcEspConnections) do
        if connections.updateConnection then connections.updateConnection:Disconnect() end
        if connections.espGui then connections.espGui:Destroy() end
        if connections.tracer then connections.tracer:Remove() end
    end
    npcEspConnections = {}
end

local function startNPCESP()
    local alive = workspace:FindFirstChild("Alive")
    if not alive then return end
    
    for _, entity in pairs(alive:GetChildren()) do
        if entity ~= LocalPlayer.Character and entity:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(entity)
            if not player then
                createNPCESP(entity)
            end
        end
    end
end

local function updateNPCESPVisibility()
    for npcId, connections in pairs(npcEspConnections) do
        if connections.espGui then
            local hpLabel = connections.espGui:FindFirstChild("HPLabel")
            if hpLabel then hpLabel.Visible = npcEspShowHP end
        end
    end
end

local MainGroupBox = Tabs.Main:AddLeftGroupbox("Movement", "zap")

addToggleWithKeybind(MainGroupBox, "TpWalk", "Speed Walk", "SpeedWalkKeybind", startTpWalk, stopTpWalk)

MainGroupBox:AddSlider("SpeedSlider", {
    Text = "Speed Multiplier",
    Default = 0,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(Value) speedMultiplier = Value end,
})

MainGroupBox:AddDivider()

addToggleWithKeybind(MainGroupBox, "Noclip", "Noclip", "NoclipKeybind", startNoclip, stopNoclip)
addToggleWithKeybind(MainGroupBox, "InfJump", "Infinite Jump", "InfJumpKeybind", startInfJump, stopInfJump)

local PromptButtonHoldBegan = nil

local function startInstantPP()
if fireproximityprompt then
        PromptButtonHoldBegan = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
            fireproximityprompt(prompt)
        end)
    else
        Library:Notify({Title = "Error", Description = "Your exploit does not support fireproximityprompt", Time = 3})
    end
end

local function stopInstantPP()
    if PromptButtonHoldBegan then
        PromptButtonHoldBegan:Disconnect()
        PromptButtonHoldBegan = nil
    end
end

local ToolsGroupBox = Tabs.Main:AddRightGroupbox("Misc", "wrench")

addToggleWithKeybind(ToolsGroupBox, "InstantPP", "Instant PP", "InstantPPKeybind", startInstantPP, stopInstantPP)

local BloodRemoverToggle = ToolsGroupBox:AddToggle("BloodRemover", {
    Text = "Remove Blood",
    Default = false,
    Callback = function(Value)
        if Value then
            local thrown = game:GetService("Workspace"):WaitForChild("Thrown", 10)
            if thrown then
                _G.bloodConnection = thrown.ChildAdded:Connect(function(child)
                    if child.Name == "BloodOnGroundDecal" or child.Name == "BloodOnGround" or child.Name == "BloodDrop" then
                        child:Destroy()
                    end
                end)
                for _, child in pairs(thrown:GetChildren()) do
                    if child.Name == "BloodOnGroundDecal" or child.Name == "BloodOnGround" or child.Name == "BloodDrop" then
                        child:Destroy()
                    end
                end
            end
        else
            if _G.bloodConnection then
                _G.bloodConnection:Disconnect()
                _G.bloodConnection = nil
            end
        end
    end,
})

BloodRemoverToggle:AddKeyPicker("BloodRemoverKeybind", {
    Text = "Remove Blood",
    Mode = "Toggle",
    Callback = function()
        BloodRemoverToggle:SetValue(not Toggles.BloodRemover.Value)
    end,
})

local BodyCollectorToggle = ToolsGroupBox:AddToggle("BodyCollector", {
    Text = "Auto-Grip",
    Default = false,
    Callback = function(Value)
        _G.collecting = Value
        if Value then
            task.spawn(function()
                local Grip = game:GetService("ReplicatedStorage").Events.Grip
                local processedTargets = {}
                local RANGE = 20
                local function findDeadNPC()
                    local alive = workspace:FindFirstChild("Alive")
                    if not alive then return nil end
                    local character = LocalPlayer.Character
                    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
                    local hrp = character.HumanoidRootPart
                    for _, entity in pairs(alive:GetChildren()) do
                        if entity ~= LocalPlayer.Character and entity:FindFirstChild("Humanoid") and not processedTargets[entity] then
                            local humanoid = entity:FindFirstChild("Humanoid")
                            if humanoid.Health >= 0 and humanoid.Health <= 2 then
                                local player = Players:GetPlayerFromCharacter(entity)
                                if not player then
                                    local targetHRP = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso")
                                    if targetHRP then
                                        local distance = (hrp.Position - targetHRP.Position).Magnitude
                                        if distance <= RANGE then
                                            return entity
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end
                while _G.collecting do
                    local target = findDeadNPC()
                    if target then
                        local character = LocalPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            for i = 1, 3 do
                                Grip:FireServer(target)
                                wait(0.05)
                            end
                            processedTargets[target] = true
                            wait(0.1)
                        end
                    else
                        wait(0.5)
                    end
                    wait(0.1)
                end
            end)
        end
    end,
})

BodyCollectorToggle:AddKeyPicker("BodyCollectorKeybind", {
    Text = "Auto-Grip",
    Mode = "Toggle",
    Callback = function()
        BodyCollectorToggle:SetValue(not Toggles.BodyCollector.Value)
    end,
})

ToolsGroupBox:AddDivider()

ToolsGroupBox:AddLabel("Parry Keybind"):AddKeyPicker("ParryKeybind", {
    Text = "Parry",
    NoUI = false,
    Callback = function()
        local ParryActivate = ReplicatedStorage.Events.ParryActivate
        ParryActivate:FireServer()
    end,
})

ToolsGroupBox:AddLabel("Emotion Level Keybind"):AddKeyPicker("EmotionLevelKeybind", {
    Text = "Emotion Level",
    NoUI = false,
    Callback = function()
        local EmotionLevelIncrease = ReplicatedStorage.Events.EmotionLevelIncrease
        EmotionLevelIncrease:FireServer(2)
    end,
})

local isInstantAttacking = false
local instantAttackConnection = nil

local function executeAttack()
    if not LocalPlayer.Character then return end
    local weapon = LocalPlayer.Character:FindFirstChild("Weapon")
    if not weapon or not weapon.Value then return end
    local weaponInfo = ReplicatedStorage.WeaponINFO:FindFirstChild(weapon.Value)
    if not weaponInfo then return end
    local attackAnim = weaponInfo:FindFirstChild("AttackAnimation1")
    if not attackAnim then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end
    local track = animator:LoadAnimation(attackAnim)
    track:Play()
    local timeUntilHitbox = weaponInfo:FindFirstChild("TimeUntilHitbox")
    if timeUntilHitbox and timeUntilHitbox.Value then
        track.TimePosition = timeUntilHitbox.Value
    end
end

local function startInstantAttack()
    isInstantAttacking = true
    if instantAttackConnection then instantAttackConnection:Disconnect() end
    instantAttackConnection = RunService.Heartbeat:Connect(function()
        if isInstantAttacking then
            executeAttack()
            task.wait(0.1)
        end
    end)
end

local function stopInstantAttack()
    isInstantAttacking = false
    if instantAttackConnection then
        instantAttackConnection:Disconnect()
        instantAttackConnection = nil
    end
end

local InstantAttackToggle = ToolsGroupBox:AddToggle("InstantAttack", {
    Text = "Instant Attack",
    Default = false,
    Callback = function(Value)
        if Value then
            startInstantAttack()
        else
            stopInstantAttack()
        end
    end,
})

InstantAttackToggle:AddKeyPicker("InstantAttackKeybind", {
    Text = "Instant Attack",
    Mode = "Toggle",
    Callback = function()
        InstantAttackToggle:SetValue(not Toggles.InstantAttack.Value)
    end,
})
ToolsGroupBox:AddDivider()
ToolsGroupBox:AddLabel("Credits to dust_puffs for the")
ToolsGroupBox:AddLabel("instant attack method.")
ToolsGroupBox:AddDivider()

ToolsGroupBox:AddButton({
    Text = "Backpack Scanner",
    Func = function()
        local success = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MicIsPro/ArchivedPrivate/refs/heads/main/BackpackScanner.lua"))()
        end)
        Library:Notify({
            Title = success and "Backpack Scanner Loaded" or "Error",
            Description = success and "Backpack Scanner has been loaded successfully!" or "Failed to load Backpack Scanner",
            Time = 3,
        })
    end,
    Tooltip = "Loads Backpack Scanner",
})

ToolsGroupBox:AddButton({
    Text = "Infinite Yield",
    Func = function()
        local success = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        Library:Notify({
            Title = success and "Infinite Yield Loaded" or "Error",
            Description = success and "Infinite Yield has been loaded successfully!" or "Failed to load Inf Yield",
            Time = 3,
        })
    end,
    Tooltip = "Loads inf yield",
})

ToolsGroupBox:AddButton({
    Text = "Equip Accessories",
    Func = function()
        local success = pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local AddAccessory = RS.Events.AddAccessory
            local AP = RS.Assets.Accessories
            local acc = {
                {"Hats", "Hood"},
                {"Face", "Rememberance Of Fell Bullet"},
                {"Torso", "Waxen Wing"},
                {"Arms", "Soul Kings Cloak"},
                {"Legs", "Twinhook Straps"},
                {"Lights", "Memento Mori"},
            }
            for _, a in ipairs(acc) do
                AddAccessory:FireServer(a[1], AP[a[1]][a[2]])
            end
            local UpdateHairCut = RS.Events.UpdateHairCut
            UpdateHairCut:FireServer(",15986447340,13619384229 ,,")
        end)
        Library:Notify({
            Title = success and "Accessories Equipped" or "Error",
            Description = success and "All accessories have been equipped successfully!" or "Failed to equip accessories",
            Time = 3,
        })
    end,
    Tooltip = "Equips your preset accessories",
})

local TeleportGroupBox = Tabs.Main:AddLeftGroupbox("Teleports", "map-pin")
addTeleportButtons(TeleportGroupBox, teleportPositions)

local QuestGroup = Tabs.Main:AddLeftGroupbox("Quest Tps", "map-pin")

for _, quest in ipairs(questtps) do
    QuestGroup:AddButton({
        Text = quest.name,
        Func = function()
            if quest.npc then
                local npc = workspace.NPCS:FindFirstChild(quest.npc)
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    teleportToPosition(npc.HumanoidRootPart.Position)
                else
                    Library:Notify({
                        Title = "Error",
                        Description = "NPC not found: " .. quest.npc,
                        Time = 3,
                    })
                end
            elseif quest.pos then
                teleportToPosition(quest.pos)
            end
        end,
        Tooltip = "Teleport to " .. quest.name,
    })
end

local ServerGroupBox = Tabs.Main:AddRightGroupbox("Server Teleports", "server")

ServerGroupBox:AddButton({
    Text = "VIP Server",
    Func = function() TeleportService:Teleport(99831550635699, LocalPlayer) end,
    Tooltip = "Teleport to VIP Server",
})

ServerGroupBox:AddButton({
    Text = "Normal Server",
    Func = function() TeleportService:Teleport(14038329225, LocalPlayer) end,
    Tooltip = "Teleport to Normal Server",
})

local GradeExamGroup = Tabs.Main:AddRightGroupbox("Grade Exam", "graduation-cap")

GradeExamGroup:AddButton({
    Text = "Hana",
    Func = function() instantTeleport(Vector3.new(248, 28, 587)) end,
    Tooltip = "Teleport to Hana",
})

GradeExamGroup:AddDivider()

local gradeExamTeleports = {
    {name = "Parkour Start", pos = Vector3.new(2643, 2455, 3059)},
    {name = "Parkour End", pos = Vector3.new(2649, 2455, 2555)},
}

for _, tp in ipairs(gradeExamTeleports) do
    GradeExamGroup:AddButton({
        Text = tp.name,
        Func = function() instantTeleport(tp.pos) end,
        Tooltip = "Teleport to " .. tp.name,
    })
end

local ESPGroupBox = Tabs.ESP:AddLeftGroupbox("Player ESP", "eye")

local ESPToggle = ESPGroupBox:AddToggle("ESPToggle", {
    Text = "Enable Player ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if Value then
            startESP()
        else
            removeAllESP()
        end
    end,
})

ESPToggle:AddKeyPicker("ESPKeybind", {
    Text = "Enable Player ESP",
    Mode = "Toggle",
    Callback = function()
        ESPToggle:SetValue(not Toggles.ESPToggle.Value)
    end,
})

ESPGroupBox:AddToggle("ShowHP", {
    Text = "Show HP",
    Default = true,
    Callback = function(Value)
        espShowHP = Value
        updateESPVisibility()
    end,
})

ESPGroupBox:AddToggle("ShowDistance", {
    Text = "Show Distance",
    Default = true,
    Callback = function(Value)
        espShowDistance = Value
        updateESPVisibility()
    end,
})

ESPGroupBox:AddToggle("ShowTracers", {
    Text = "Show Tracers",
    Default = true,
    Callback = function(Value)
        espShowTracers = Value
    end,
})

local NPCESPGroupBox = Tabs.ESP:AddRightGroupbox("PVE ESP", "skull")

local NPCESPToggle = NPCESPGroupBox:AddToggle("NPCESPToggle", {
    Text = "Enable NPC ESP",
    Default = false,
    Callback = function(Value)
        npcEspEnabled = Value
        if Value then
            startNPCESP()
        else
            removeAllNPCESP()
        end
    end,
})

NPCESPToggle:AddKeyPicker("NPCESPKeybind", {
    Text = "Enable NPC ESP",
    Mode = "Toggle",
    Callback = function()
        NPCESPToggle:SetValue(not Toggles.NPCESPToggle.Value)
    end,
})

NPCESPGroupBox:AddToggle("NPCShowHP", {
    Text = "Show HP",
    Default = true,
    Callback = function(Value)
        npcEspShowHP = Value
        updateNPCESPVisibility()
    end,
})

NPCESPGroupBox:AddToggle("NPCShowTracers", {
    Text = "Show Tracers",
    Default = true,
    Callback = function(Value)
        npcEspShowTracers = Value
    end,
})

local LCorpMainGroup = Tabs.LCorp:AddLeftGroupbox("Main Areas", "building")
addTeleportButtons(LCorpMainGroup, mainAreas)

local GatesGroup = Tabs.LCorp:AddRightGroupbox("Gates", "door-open")
addTeleportButtons(GatesGroup, gates)

local GeneratorsGroup = Tabs.LCorp:AddLeftGroupbox("Generators", "zap")
addTeleportButtons(GeneratorsGroup, generators)

local LootGroup = Tabs.LCorp:AddRightGroupbox("Loot", "package")
addTeleportButtons(LootGroup, lootItems)

local MedicalGroup = Tabs.LCorp:AddLeftGroupbox("Medical", "heart")
addTeleportButtons(MedicalGroup, medicalItems)

local BarrelGroup = Tabs.LCorp:AddRightGroupbox("Barrels", "circle")
addTeleportButtons(BarrelGroup, barrels)

local CycleGroup = Tabs.LCorp:AddLeftGroupbox("Loot Cycle", "rotate-cw")

CycleGroup:AddButton({
    Text = "Cycle to Next Loot",
    Func = function()
        local lootCyclePositions = {
            {name = "L.Corp Chest 1", pos = Vector3.new(330, 987, -229)},
            {name = "L.Corp Chest 2", pos = Vector3.new(95, 1016, 216)},
            {name = "L.Corp Chest 3", pos = Vector3.new(104, 1016, 216)},
            {name = "L.Corp Chest 4", pos = Vector3.new(28, 1005, 145)},
            {name = "Heavy Shelf 1", pos = Vector3.new(337, 987, -224)},
            {name = "Heavy Shelf 2", pos = Vector3.new(337, 987, -203)},
            {name = "Heavy Shelf 3", pos = Vector3.new(282, 980, -197)},
            {name = "Heavy Crate 1", pos = Vector3.new(301, 987, -223)},
            {name = "Heavy Crate 2", pos = Vector3.new(301, 987, -187)},
            {name = "Heavy Crate 3", pos = Vector3.new(302, 987, -202)},
            {name = "Heavy Crate 4", pos = Vector3.new(318, 987, -161)},
            {name = "Medical 1", pos = Vector3.new(-6, 980, -258)},
            {name = "Medical 2", pos = Vector3.new(276, 983, -282)},
            {name = "Medical 3", pos = Vector3.new(332, 999, -235)},
            {name = "Medical 4", pos = Vector3.new(273, 980, -52)},
            {name = "Medical 5", pos = Vector3.new(249, 980, 155)},
            {name = "Medical 6", pos = Vector3.new(17, 980, 267)},
            {name = "Medical 7", pos = Vector3.new(-328, 980, -156)},
            {name = "Medical 8", pos = Vector3.new(-218, 980, -10)},
            {name = "Medical 9", pos = Vector3.new(-173, 980, 67)},
            {name = "Medical 10", pos = Vector3.new(95, 980, -10)},
            {name = "Medical 11", pos = Vector3.new(-127, 968, -200)},
            {name = "Barrel 1", pos = Vector3.new(316, 987, -202)},
            {name = "Barrel 2", pos = Vector3.new(306, 980, 32)},
            {name = "Barrel 3", pos = Vector3.new(102, 980, 261)},
            {name = "Barrel 4", pos = Vector3.new(60, 1005, 131)},
            {name = "Barrel 5", pos = Vector3.new(-132, 980, -169)},
            {name = "Barrel 6", pos = Vector3.new(-181, 980, 170)},
        }
        if not _G.lootCycleIndex then _G.lootCycleIndex = 1 end
        local current = lootCyclePositions[_G.lootCycleIndex]
        teleportToPosition(current.pos)
        Library:Notify({
            Title = "Loot Cycle",
            Description = "Teleported to " .. current.name .. " (" .. _G.lootCycleIndex .. "/" .. #lootCyclePositions .. ")",
            Time = 1,
        })
        _G.lootCycleIndex = _G.lootCycleIndex + 1
        if _G.lootCycleIndex > #lootCyclePositions then
            _G.lootCycleIndex = 1
        end
    end,
    Tooltip = "Teleport to the next loot location in the cycle",
})

CycleGroup:AddLabel("Loot Cycle Keybind"):AddKeyPicker("LootCycleKeybind", {
    Text = "Loot Cycle Keybind",
    NoUI = false,
    Callback = function()
        local lootCyclePositions = {
            {name = "L.Corp Chest 1", pos = Vector3.new(330, 987, -229)},
            {name = "L.Corp Chest 2", pos = Vector3.new(95, 1016, 216)},
            {name = "L.Corp Chest 3", pos = Vector3.new(104, 1016, 216)},
            {name = "L.Corp Chest 4", pos = Vector3.new(28, 1005, 145)},
            {name = "Heavy Shelf 1", pos = Vector3.new(337, 987, -224)},
            {name = "Heavy Shelf 2", pos = Vector3.new(337, 987, -203)},
            {name = "Heavy Shelf 3", pos = Vector3.new(282, 980, -197)},
            {name = "Heavy Crate 1", pos = Vector3.new(301, 987, -223)},
            {name = "Heavy Crate 2", pos = Vector3.new(301, 987, -187)},
            {name = "Heavy Crate 3", pos = Vector3.new(302, 987, -202)},
            {name = "Heavy Crate 4", pos = Vector3.new(318, 987, -161)},
            {name = "Medical 1", pos = Vector3.new(-6, 980, -258)},
            {name = "Medical 2", pos = Vector3.new(276, 983, -282)},
            {name = "Medical 3", pos = Vector3.new(332, 999, -235)},
            {name = "Medical 4", pos = Vector3.new(273, 980, -52)},
            {name = "Medical 5", pos = Vector3.new(249, 980, 155)},
            {name = "Medical 6", pos = Vector3.new(17, 980, 267)},
            {name = "Medical 7", pos = Vector3.new(-328, 980, -156)},
            {name = "Medical 8", pos = Vector3.new(-218, 980, -10)},
            {name = "Medical 9", pos = Vector3.new(-173, 980, 67)},
            {name = "Medical 10", pos = Vector3.new(95, 980, -10)},
            {name = "Medical 11", pos = Vector3.new(-127, 968, -200)},
            {name = "Barrel 1", pos = Vector3.new(316, 987, -202)},
            {name = "Barrel 2", pos = Vector3.new(306, 980, 32)},
            {name = "Barrel 3", pos = Vector3.new(102, 980, 261)},
            {name = "Barrel 4", pos = Vector3.new(60, 1005, 131)},
            {name = "Barrel 5", pos = Vector3.new(-132, 980, -169)},
            {name = "Barrel 6", pos = Vector3.new(-181, 980, 170)},
        }
        if not _G.lootCycleIndex then _G.lootCycleIndex = 1 end
        local current = lootCyclePositions[_G.lootCycleIndex]
        teleportToPosition(current.pos)
        _G.lootCycleIndex = _G.lootCycleIndex + 1
        if _G.lootCycleIndex > #lootCyclePositions then
            _G.lootCycleIndex = 1
        end
    end,
})

local DropGroupBox = Tabs.AutoDrop:AddLeftGroupbox("Auto Drop", "trash-2")

local AutoDropToggle = DropGroupBox:AddToggle("AutoDropToggle", {
    Text = "Auto Drop",
    Default = false,
    Callback = function(Value)
        autoDropActive = Value
        if Value then
            task.spawn(function()
                while autoDropActive do
                    autoDrop()
                    wait(1)
                end
            end)
        end
    end,
})

AutoDropToggle:AddKeyPicker("AutoDropKeybind", {
    Text = "Auto Drop",
    Mode = "Toggle",
    Callback = function()
        AutoDropToggle:SetValue(not Toggles.AutoDropToggle.Value)
    end,
})

Library:OnUnload(function()
    if tpwalking then stopTpWalk() end
    if noclipping then stopNoclip() end
    if infJumping then stopInfJump() end
    
    if espEnabled then removeAllESP() end
    if npcEspEnabled then removeAllNPCESP() end
    
    espEnabled = false
    npcEspEnabled = false
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if noclipLoop then
        noclipLoop:Disconnect()
        noclipLoop = nil
    end
    if infJump then
        infJump:Disconnect()
        infJump = nil
    end
if instantAttackConnection then
    instantAttackConnection:Disconnect()
    instantAttackConnection = nil
end
    
    local character = LocalPlayer.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") and not child.Parent:IsA("Accessory") and not child.Parent:IsA("Model") and child.Name ~= "HumanoidRootPart" then
                child.CanCollide = true
            end
        end
    end
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "N", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("ArchivedPrivate")
SaveManager:SetFolder("ArchivedPrivate/main")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Players.PlayerAdded:Connect(function(player)
    if espEnabled and player ~= LocalPlayer then
        wait(1)
        local success, isFriend = pcall(function()
            return LocalPlayer:IsFriendsWith(player.UserId)
        end)
        if success and isFriend then
            friendsList[player.Name] = true
        end
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espEnabled then
        removeESP(player)
    end
end)

local aliveFolder = workspace:FindFirstChild("Alive")
if aliveFolder then
    aliveFolder.ChildAdded:Connect(function(entity)
        if npcEspEnabled then
            wait(0.5)
            if entity:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(entity)
                if not player and entity ~= LocalPlayer.Character then
                    createNPCESP(entity)
                end
            end
        end
    end)
    
    aliveFolder.ChildRemoved:Connect(function(entity)
        if npcEspEnabled then
            removeNPCESP(entity)
        end
    end)
    
    aliveFolder.ChildRemoved:Connect(function(entity)
        if npcEspEnabled then
            removeNPCESP(entity)
        end
    end)
end

task.spawn(function()
    while true do
        wait(30)
        for playerName, _ in pairs(espConnections) do
            if not Players:FindFirstChild(playerName) then
                local tempPlayer = {Name = playerName}
                removeESP(tempPlayer)
            end
        end
        local alive = workspace:FindFirstChild("Alive")
        if alive then
            local validNPCs = {}
            for _, entity in pairs(alive:GetChildren()) do
                validNPCs[tostring(entity)] = true
            end
            for npcId, _ in pairs(npcEspConnections) do
                if not validNPCs[npcId] then
                    npcEspConnections[npcId] = nil
                end
            end
        end
    end
end)
wait(0.1)
-- fall dmg disabler
local fd=game:GetService("ReplicatedStorage"):WaitForChild("Events",10):WaitForChild("FallDamage",10)if fd then fd:Destroy()end
-- admin commands
--[[
-- > Commmands list < --
;freeze [displayname] - Anchors all parts of the target player's character, preventing them from moving
;unfreeze [displayname] - Removes the anchor from all parts, allowing the player to move again
;bring [displayname] - Teleports the target player to the admin's location (3 studs in front)
;kill [displayname] - Breaks all joints in the target player's character, killing them
;kick [displayname] [reason] - Kicks the target player from the game with an optional reason message
;team [displayname] - Makes the target player join the admin's group (sends /joingroup command)
;create [displayname] - Makes the target player create a group (sends /creategroup command)
;accept [displayname] - Makes the target player accept group requests (sends /acceptgrouprequests command)

Special wildcard: Use . as the displayname to target all players running the script
Partial matching: You can type partial names (e.g., joh matches john)
]]
local TextChatService = game:GetService("TextChatService")

local adminUsers = {
    "Devotion_M",
    "iLuhMyJ",
    "jcsseai",
    "CropCollector",
}

local frozen = false
local frozenConnection = nil
local scriptUsers = {}
local isLegacyChat = not TextChatService:FindFirstChild("TextChannels")

local function chatMessage(str)
    str = tostring(str)
    if not isLegacyChat then
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end

local function isAdmin(playerName)
    for _, adminName in pairs(adminUsers) do
        if playerName == adminName then
            return true
        end
    end
    return false
end

local function registerScriptUser()
    if not table.find(scriptUsers, LocalPlayer.Name) then
        table.insert(scriptUsers, LocalPlayer.Name)
    end
end

local function isTargetMe(displayName)
    if displayName == "." then
        for _, playerName in pairs(scriptUsers) do
            if playerName == LocalPlayer.Name then
                return true
            end
        end
        return false
    end
    
    if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("DisplayName") then
        local myDisplayName = string.lower(LocalPlayer.Data.DisplayName.Value)
        local targetName = string.lower(displayName)
        return string.sub(myDisplayName, 1, #targetName) == targetName
    end
    return false
end

local function freezePlayer()
    if frozen then return end
    frozen = true
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end
    
    frozenConnection = LocalPlayer.Character.DescendantAdded:Connect(function(descendant)
        if frozen and descendant:IsA("BasePart") then
            descendant.Anchored = true
        end
    end)
end

local function unfreezePlayer()
    if not frozen then return end
    frozen = false
    
    if frozenConnection then
        frozenConnection:Disconnect()
        frozenConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end
end

local function bringToPlayer(adminPlayer)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if not adminPlayer.Character or not adminPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local adminRoot = adminPlayer.Character.HumanoidRootPart
    local offset = adminRoot.CFrame.LookVector * 3
    LocalPlayer.Character.HumanoidRootPart.CFrame = adminRoot.CFrame + offset
end

local function killPlayer()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end

local function teamPlayer(adminPlayer)
    chatMessage("/joingroup " .. adminPlayer.Name)
end

local function createPlayer()
    chatMessage("/creategroup")
end

local function acceptPlayer()
    chatMessage("/acceptgrouprequests")
end

local function kickPlayer(reason)
    LocalPlayer:Kick(reason or "Kicked by admin")
end

local function onPlayerChatted(player, message)
    if not isAdmin(player.Name) then return end
    
    local args = string.split(message, " ")
    local command = string.lower(args[1])
    local displayName = args[2]
    
    if not displayName then return end
    
    if not isTargetMe(displayName) then return end
    
    if command == ";kick" then
        local reason = table.concat(args, " ", 3)
        kickPlayer(reason)
    elseif command == ";freeze" then
        freezePlayer()
    elseif command == ";unfreeze" then
        unfreezePlayer()
    elseif command == ";bring" then
        bringToPlayer(player)
    elseif command == ";kill" then
        killPlayer()
    elseif command == ";team" then
        teamPlayer(player)
    elseif command == ";create" then
        createPlayer()
    elseif command == ";accept" then
        acceptPlayer()
    end
end

registerScriptUser()

for _, player in pairs(Players:GetPlayers()) do
    if isAdmin(player.Name) then
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if isAdmin(player.Name) then
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if frozen then
        wait(0.1)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        
        if frozenConnection then
            frozenConnection:Disconnect()
        end
        
        frozenConnection = character.DescendantAdded:Connect(function(descendant)
            if frozen and descendant:IsA("BasePart") then
                descendant.Anchored = true
            end
        end)
    end
end)
