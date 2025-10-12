local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

wait(1)

local tpwalking = false
local speedMultiplier = 5
local noclipping = false
local infJumping = false
local f3xLoaded = false
local infJump
local noclipLoop
local lootedItems = {}
local speedConnection
local lootCycleIndex = 1

local lootCyclePositions = {
    {name = "L.Corp Chest 1", pos = Vector3.new(330, 987, -229), type = "loot"},
    {name = "L.Corp Chest 2", pos = Vector3.new(95, 1016, 216), type = "loot"},
    {name = "L.Corp Chest 3", pos = Vector3.new(104, 1016, 216), type = "loot"},
    {name = "L.Corp Chest 4", pos = Vector3.new(28, 1005, 145), type = "loot"},
    {name = "Heavy Shelf 1", pos = Vector3.new(337, 987, -224), type = "loot"},
    {name = "Heavy Shelf 2", pos = Vector3.new(337, 987, -203), type = "loot"},
    {name = "Heavy Shelf 3", pos = Vector3.new(282, 980, -197), type = "loot"},
    {name = "Heavy Crate 1", pos = Vector3.new(301, 987, -223), type = "loot"},
    {name = "Heavy Crate 2", pos = Vector3.new(301, 987, -187), type = "loot"},
    {name = "Heavy Crate 3", pos = Vector3.new(302, 987, -202), type = "loot"},
    {name = "Heavy Crate 4", pos = Vector3.new(318, 987, -161), type = "loot"},
    {name = "Medical 1", pos = Vector3.new(-6, 980, -258), type = "medical"},
    {name = "Medical 2", pos = Vector3.new(276, 983, -282), type = "medical"},
    {name = "Medical 3", pos = Vector3.new(332, 999, -235), type = "medical"},
    {name = "Medical 4", pos = Vector3.new(273, 980, -52), type = "medical"},
    {name = "Medical 5", pos = Vector3.new(249, 980, 155), type = "medical"},
    {name = "Medical 6", pos = Vector3.new(17, 980, 267), type = "medical"},
    {name = "Medical 7", pos = Vector3.new(-328, 980, -156), type = "medical"},
    {name = "Medical 8", pos = Vector3.new(-218, 980, -10), type = "medical"},
    {name = "Medical 9", pos = Vector3.new(-173, 980, 67), type = "medical"},
    {name = "Medical 10", pos = Vector3.new(95, 980, -10), type = "medical"},
    {name = "Medical 11", pos = Vector3.new(-127, 968, -200), type = "medical"},
    {name = "Barrel 1", pos = Vector3.new(316, 987, -202), type = "barrel"},
    {name = "Barrel 2", pos = Vector3.new(306, 980, 32), type = "barrel"},
    {name = "Barrel 3", pos = Vector3.new(102, 980, 261), type = "barrel"},
    {name = "Barrel 4", pos = Vector3.new(60, 1005, 131), type = "barrel"},
    {name = "Barrel 5", pos = Vector3.new(-132, 980, -169), type = "barrel"},
    {name = "Barrel 6", pos = Vector3.new(-181, 980, 170), type = "barrel"},
}

local hb = RunService.Heartbeat

local Window = Library:CreateWindow({
    Title = "Archived",
    Footer = "V1 - Devotion_M",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    NPCTargetter = Window:AddTab("NPC Targetter", "target"),
    LCorp = Window:AddTab("L.Corp", "building"),
    AutoDrop = Window:AddTab("Auto Drop", "trash-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
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

local function startTpWalk()
    tpwalking = true
    local chr = LocalPlayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = hb:Connect(function(delta)
        if tpwalking and chr and hum and hum.Parent then
            if hum.MoveDirection.Magnitude > 0 then
                chr:TranslateBy(hum.MoveDirection * speedMultiplier * delta * 10)
            end
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
    
    if noclipLoop then
        noclipLoop:Disconnect()
    end

    noclipLoop = RunService.Stepped:Connect(function()
        if noclipping == true and LocalPlayer.Character ~= nil then
            for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
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
            if child:IsA("BasePart") and child.Parent:IsA("Accessory") == false and child.Parent:IsA("Model") == false and child.Name ~= "HumanoidRootPart" then
                child.CanCollide = true
            end
        end
    end
end

local function startInfJump()
    infJumping = true
    
    if infJump then
        infJump:Disconnect()
    end
    
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

local function loadF3X()
    if f3xLoaded then return end
    
    local function Load(Obj, Url)
        local function GiveOwnGlobals(Func, Script)
            local Fenv = {}
            local RealFenv = {script = Script}
            local FenvMt = {
                __index = function(a, b)
                    return RealFenv[b] == nil and getfenv()[b] or RealFenv[b]
                end,
                __newindex = function(a, b, c)
                    if RealFenv[b] == nil then 
                        getfenv()[b] = c 
                    else 
                        RealFenv[b] = c 
                    end
                end
            }
            setmetatable(Fenv, FenvMt)
            setfenv(Func, Fenv)
            return Func
        end
        
        local function LoadScripts(Script)
            if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
                task.spawn(GiveOwnGlobals(loadstring(Script.Source), Script))
            end
            for i,v in pairs(Script:GetChildren()) do
                LoadScripts(v)
            end
        end
        
        LoadScripts(Obj)
    end

    local function LoadF3X()
        local btrtool = game:GetObjects("rbxassetid://6695644299")[1]
        btrtool.Parent = LocalPlayer.Backpack
        Load(btrtool, btrtool)
        f3xLoaded = true
    end

    pcall(LoadF3X)
end

local function unloadF3X()
    f3xLoaded = false
    if LocalPlayer.Backpack:FindFirstChild("Building Tools by F3X (Plugin)") then
        LocalPlayer.Backpack["Building Tools by F3X (Plugin)"]:Destroy()
    end
    if LocalPlayer.Character:FindFirstChild("Building Tools by F3X (Plugin)") then
        LocalPlayer.Character["Building Tools by F3X (Plugin)"]:Destroy()
    end
end

local function cycleLootTeleports()
    if #lootCyclePositions == 0 then return end
    
    local currentTeleport = lootCyclePositions[lootCycleIndex]
    teleportToPosition(currentTeleport.pos)
    
    local posKey = tostring(currentTeleport.pos)
    if not lootedItems[posKey] then
        lootedItems[posKey] = true
        Library:Notify({
            Title = currentTeleport.type:gsub("^%l", string.upper) .. " Collected",
            Description = currentTeleport.name .. " has been marked as looted",
            Time = 2,
        })
    end
    
    Library:Notify({
        Title = "Loot Cycle",
        Description = "Teleported to " .. currentTeleport.name .. " (" .. lootCycleIndex .. "/" .. #lootCyclePositions .. ")",
        Time = 1,
    })
    
    lootCycleIndex = lootCycleIndex + 1
    if lootCycleIndex > #lootCyclePositions then
        lootCycleIndex = 1
    end
end

local MainGroupBox = Tabs.Main:AddLeftGroupbox("Movement", "zap")

local SpeedToggle = MainGroupBox:AddToggle("TpWalk", {
    Text = "Speed Walk",
    Default = false,
    Callback = function(Value)
        if Value then
            startTpWalk()
        else
            stopTpWalk()
        end
    end,
})

SpeedToggle:AddKeyPicker("SpeedWalkKeybind", {
    Text = "Speed Walk",
    Mode = "Toggle",
    Callback = function()
        SpeedToggle:SetValue(not Toggles.TpWalk.Value)
    end,
})

MainGroupBox:AddSlider("SpeedSlider", {
    Text = "Speed Multiplier",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        speedMultiplier = Value
    end,
})

MainGroupBox:AddDivider()

local NoclipToggle = MainGroupBox:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            startNoclip()
        else
            stopNoclip()
        end
    end,
})

NoclipToggle:AddKeyPicker("NoclipKeybind", {
    Text = "Noclip",
    Mode = "Toggle",
    Callback = function()
        NoclipToggle:SetValue(not Toggles.Noclip.Value)
    end,
})

local InfJumpToggle = MainGroupBox:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if Value then
            startInfJump()
        else
            stopInfJump()
        end
    end,
})

InfJumpToggle:AddKeyPicker("InfJumpKeybind", {
    Text = "Infinite Jump",
    Mode = "Toggle",
    Callback = function()
        InfJumpToggle:SetValue(not Toggles.InfJump.Value)
    end,
})

local instantPPActive = false
local PromptButtonHoldBegan = nil

local function startInstantPP()
    if fireproximityprompt then
        PromptButtonHoldBegan = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
            fireproximityprompt(prompt)
        end)
    else
        Library:Notify({
            Title = "Error",
            Description = "Your exploit does not support fireproximityprompt",
            Time = 3,
        })
    end
end

local function stopInstantPP()
    if PromptButtonHoldBegan ~= nil then
        PromptButtonHoldBegan:Disconnect()
        PromptButtonHoldBegan = nil
    end
end

local InstantPPToggle = MainGroupBox:AddToggle("InstantPP", {
    Text = "Instant PP",
    Default = false,
    Callback = function(Value)
        instantPPActive = Value
        if Value then
            startInstantPP()
        else
            stopInstantPP()
        end
    end,
})

InstantPPToggle:AddKeyPicker("InstantPPKeybind", {
    Text = "Instant PP",
    Mode = "Toggle",
    Callback = function()
        InstantPPToggle:SetValue(not Toggles.InstantPP.Value)
    end,
})

MainGroupBox:AddDivider()
local BloodRemoverToggle = MainGroupBox:AddToggle("BloodRemover", {
    Text = "Remove Blood",
    Default = false,
    Callback = function(Value)
        if Value then
            local workspace = game:GetService("Workspace")
            local thrown = workspace:WaitForChild("Thrown", 10)
            
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

local BodyCollectorToggle = MainGroupBox:AddToggle("BodyCollector", {
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

MainGroupBox:AddDivider()
MainGroupBox:AddLabel("Parry Keybind"):AddKeyPicker("ParryKeybind", {
    Text = "Parry",
    NoUI = false,
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ParryActivate = ReplicatedStorage.Events.ParryActivate
        ParryActivate:FireServer()
    end,
})

local ToolsGroupBox = Tabs.Main:AddRightGroupbox("Misc", "wrench")

ToolsGroupBox:AddButton({
    Text = "Load F3X",
    Func = function()
        loadF3X()
        Library:Notify({
            Title = "F3X Loaded",
            Description = "F3X Building Tools have been loaded successfully!",
            Time = 3,
        })
    end,
    Tooltip = "Loads F3X Building Tools",
})

ToolsGroupBox:AddButton({
    Text = "Backpack Scanner",
    Func = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MicIsPro/ArchivedPrivate/refs/heads/main/BackpackScanner.lua"))()
        end)
        
        if success then
            Library:Notify({
                Title = "Backpack Scanner Loaded",
                Description = "Backpack Scanner has been loaded successfully!",
                Time = 3,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Failed to load Backpack Scanner",
                Time = 3,
            })
        end
    end,
    Tooltip = "Loads Backpack Scanner",
})

ToolsGroupBox:AddButton({
    Text = "Infinite Yield",
    Func = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        
        if success then
            Library:Notify({
                Title = "Infinite Yield Loaded",
                Description = "Infinite Yield has been loaded succesfully!",
                Time = 3,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Failed to load Inf Yield",
                Time = 3,
            })
        end
    end,
    Tooltip = "Loads inf yield",
})

ToolsGroupBox:AddButton({
    Text = "Equip Accessories",
    Func = function()
        local success = pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local AddAccessory = ReplicatedStorage.Events.AddAccessory
            local AccessoriesPath = ReplicatedStorage.Assets.Accessories
            
            local Hood = AccessoriesPath.Hats.Hood
            AddAccessory:FireServer("Hats", Hood)
            
            local RememberanceOfFellBullet = AccessoriesPath.Face["Rememberance Of Fell Bullet"]
            AddAccessory:FireServer("Face", RememberanceOfFellBullet)
            
            local WaxenWing = AccessoriesPath.Torso["Waxen Wing"]
            AddAccessory:FireServer("Torso", WaxenWing)
            
            local SoulKingsCloak = AccessoriesPath.Arms["Soul Kings Cloak"]
            AddAccessory:FireServer("Arms", SoulKingsCloak)
            
            local TwinhookStraps = AccessoriesPath.Legs["Twinhook Straps"]
            AddAccessory:FireServer("Legs", TwinhookStraps)
            
            local MementoMori = AccessoriesPath.Lights["Memento Mori"]
            AddAccessory:FireServer("Lights", MementoMori)
        end)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateHairCut = ReplicatedStorage.Events.UpdateHairCut
UpdateHairCut:FireServer(
    ",15986447340,13619384229 ,,"
)
        if success then
            Library:Notify({
                Title = "Accessories Equipped",
                Description = "All accessories have been equipped successfully!",
                Time = 3,
            })
        else
            Library:Notify({
                Title = "Error",
                Description = "Failed to equip accessories",
                Time = 3,
            })
        end
    end,
    Tooltip = "Equips your preset accessories",
})

local TeleportGroupBox = Tabs.Main:AddLeftGroupbox("Teleports", "map-pin")

local teleportPositions = {
    {name = "Bar", pos = Vector3.new(441, -7, 438)},
    {name = "Syntheza", pos = Vector3.new(-658, -8, 971)},
    {name = "Docks", pos = Vector3.new(-1230, -11, 951)},
    {name = "Subway", pos = Vector3.new(48, 0, 681)},
    {name = "Dumpster Guy", pos = Vector3.new(298, 64, -149)}
}

for _, teleport in ipairs(teleportPositions) do
    TeleportGroupBox:AddButton({
        Text = teleport.name,
        Func = function()
            teleportToPosition(teleport.pos)
        end,
        Tooltip = "Teleport to " .. teleport.name,
    })
end

local QuestGroup = Tabs.Main:AddLeftGroupbox("Quest Tps", "map-pin")
local questtps = {
    {name = "L.Corp", pos = Vector3.new(1005, 27, 1150)},
    {name = "Warp Train", pos = Vector3.new(620, -7, 408)},
}
for _, teleport in ipairs(questtps) do
QuestGroup:AddButton({
    Text = teleport.name,
    Func = function()
    teleportToPosition(teleport.pos)
    end,
    Tooltip = "Teleport to " .. teleport.name,
})
end

local ServerGroupBox = Tabs.Main:AddRightGroupbox("Server Teleports", "server")

ServerGroupBox:AddButton({
    Text = "VIP Server",
    Func = function()
        TeleportService:Teleport(99831550635699, LocalPlayer)
    end,
    Tooltip = "Teleport to VIP Server",
})

ServerGroupBox:AddButton({
    Text = "Normal Server",
    Func = function()
        TeleportService:Teleport(14038329225, LocalPlayer)
    end,
    Tooltip = "Teleport to Normal Server",
})

local GradeExamGroup = Tabs.Main:AddRightGroupbox("Grade Exam", "graduation-cap")

GradeExamGroup:AddButton({
    Text = "Hana",
    Func = function()
        instantTeleport(Vector3.new(248, 28, 587))
    end,
    Tooltip = "Teleport to Hana",
})

GradeExamGroup:AddDivider()

local gradeExamTeleports = {
    {name = "Parkour Start", pos = Vector3.new(2643, 2455, 3059)},
    {name = "Parkour End", pos = Vector3.new(2649, 2455, 2555)},
}
for _, teleport in ipairs(gradeExamTeleports) do
    GradeExamGroup:AddButton({
        Text = teleport.name,
        Func = function()
            instantTeleport(teleport.pos)
        end,
        Tooltip = "Teleport to " .. teleport.name,
    })
end


local autoDropActive = false

local function autoDrop()
    local character = LocalPlayer.Character
    if not character then return end
    
    local backpack = LocalPlayer.Backpack
    local itemsToDrop = {
        "Makeshift Handle",
        "Rope",
        "Low Quality Blade",
        "Book",
        "Organs",
        "Wiring",
        "Book Of a Grade 9 Fixer",
        "Book Of a Grade 7 Fixer",
        "Book Of Zwei Association",
        "Book Of Hana Association",
        "Book Of Shi Association",
        "Book Of Stray Dogs",
        "Scrap Metal",
        "Gun Parts",
  
    }
    
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
    
    local DropItem = game:GetService("ReplicatedStorage").Events.DropItem
    for _, itemName in ipairs(itemsToDrop) do
        local items = findAllItems(itemName)
        
        for _, item in ipairs(items) do
            DropItem:FireServer(item)
            wait(0)
        end
    end
end

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

local LCorpMainGroup = Tabs.LCorp:AddLeftGroupbox("Main Areas", "building")

local mainAreas = {
    {name = "Main", pos = Vector3.new(-6, 980, 198)},
    {name = "Boss Arena", pos = Vector3.new(50, 980, 367)},
    {name = "Storage", pos = Vector3.new(269, 980, -212)},
    {name = "Extraction Machine", pos = Vector3.new(132, 980, -31)},
    {name = "Exit", pos = Vector3.new(88, 980, -84)},
    {name = "Spawn", pos = Vector3.new(-197, 967, -232)},
}

for _, area in ipairs(mainAreas) do
    LCorpMainGroup:AddButton({
        Text = area.name,
        Func = function()
            teleportToPosition(area.pos)
        end,
        Tooltip = "Teleport to " .. area.name,
    })
end

local GatesGroup = Tabs.LCorp:AddRightGroupbox("Gates", "door-open")

local gates = {
    {name = "Orange Gate", pos = Vector3.new(-234, 980, 187)},
    {name = "Purple Gate", pos = Vector3.new(-36, 980, 28)},
    {name = "Green Gate", pos = Vector3.new(244, 980, 62)},
    {name = "Yellow Gate", pos = Vector3.new(48, 980, -308)},
    {name = "Mirror Shard", pos = Vector3.new(-338, 980, 0)},
}

for _, gate in ipairs(gates) do
    GatesGroup:AddButton({
        Text = gate.name,
        Func = function()
            teleportToPosition(gate.pos)
        end,
        Tooltip = "Teleport to " .. gate.name,
    })
end

local GeneratorsGroup = Tabs.LCorp:AddLeftGroupbox("Generators", "zap")

local generators = {
    {name = "Generator 1", pos = Vector3.new(283, 980, -180)},
    {name = "Generator 2", pos = Vector3.new(205, 980, 43)},
    {name = "Generator 3", pos = Vector3.new(60, 980, 126)},
    {name = "Generator 4", pos = Vector3.new(-165, 980, -85)},
}

for _, gen in ipairs(generators) do
    GeneratorsGroup:AddButton({
        Text = gen.name,
        Func = function()
            teleportToPosition(gen.pos)
        end,
        Tooltip = "Teleport to " .. gen.name,
    })
end

local LootGroup = Tabs.LCorp:AddRightGroupbox("Loot", "package")

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

for _, loot in ipairs(lootItems) do
    LootGroup:AddButton({
        Text = loot.name,
        Func = function()
            teleportToPosition(loot.pos)
        end,
        Tooltip = "Teleport to " .. loot.name,
    })
end

local MedicalGroup = Tabs.LCorp:AddLeftGroupbox("Medical", "heart")

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

for _, med in ipairs(medicalItems) do
    MedicalGroup:AddButton({
        Text = med.name,
        Func = function()
            teleportToPosition(med.pos)
        end,
        Tooltip = "Teleport to " .. med.name,
    })
end

local BarrelGroup = Tabs.LCorp:AddRightGroupbox("Barrels", "circle")

local barrels = {
    {name = "Barrel 1", pos = Vector3.new(316, 987, -202)},
    {name = "Barrel 2", pos = Vector3.new(306, 980, 32)},
    {name = "Barrel 3", pos = Vector3.new(102, 980, 261)},
    {name = "Barrel 4", pos = Vector3.new(60, 1005, 131)},
    {name = "Barrel 5", pos = Vector3.new(-132, 980, -169)},
    {name = "Barrel 6", pos = Vector3.new(-181, 980, 170)},
}

for _, barrel in ipairs(barrels) do
    BarrelGroup:AddButton({
        Text = barrel.name,
        Func = function()
            teleportToPosition(barrel.pos)
        end,
        Tooltip = "Teleport to " .. barrel.name,
    })
end

local CycleGroup = Tabs.LCorp:AddLeftGroupbox("Loot Cycle", "rotate-cw")

CycleGroup:AddButton({
    Text = "Cycle to Next Loot",
    Func = function()
        cycleLootTeleports()
    end,
    Tooltip = "Teleport to the next loot location in the cycle",
})

CycleGroup:AddLabel("Loot Cycle Keybind"):AddKeyPicker("LootCycleKeybind", {
    Text = "Loot Cycle Keybind",
    NoUI = false,
    Callback = function()
        cycleLootTeleports()
    end,
})

local NPCTargetterGroup = Tabs.NPCTargetter:AddLeftGroupbox("Loop Teleport", "crosshair")

local npcTargetEnabled = false
local npcTargetLoop
local npcTargetPlate = nil
local npcTargetDistance = 0

local function findNearestNPC()
    local alive = workspace:FindFirstChild("Alive")
    if not alive then return nil end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    
    local nearestNPC = nil
    local shortestDistance = math.huge
    
    for _, entity in pairs(alive:GetChildren()) do
        if entity ~= LocalPlayer.Character and entity:FindFirstChild("Humanoid") then
            local humanoid = entity:FindFirstChild("Humanoid")
            if humanoid.Health > 2 then
                local player = Players:GetPlayerFromCharacter(entity)
                if not player then
                    local npcHRP = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso")
                    if npcHRP then
                        local dist = (hrp.Position - npcHRP.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            nearestNPC = entity
                        end
                    end
                end
            end
        end
    end
    
    return nearestNPC
end

local function createNPCTargetPlate()
    if npcTargetPlate then npcTargetPlate:Destroy() end
    
    npcTargetPlate = Instance.new("Part")
    npcTargetPlate.Name = "NPCTargetPlate"
    npcTargetPlate.Shape = Enum.PartType.Block
    npcTargetPlate.Size = Vector3.new(8, 0.5, 8)
    npcTargetPlate.CanCollide = true
    npcTargetPlate.Anchored = true
    npcTargetPlate.CanQuery = false
    npcTargetPlate.Material = Enum.Material.ForceField
    npcTargetPlate.Transparency = 0.3
    npcTargetPlate.TopSurface = Enum.SurfaceType.Smooth
    npcTargetPlate.BottomSurface = Enum.SurfaceType.Smooth
    npcTargetPlate.Parent = workspace
end

local NPCTargetToggle = NPCTargetterGroup:AddToggle("NPCTargetToggle", {
    Text = "Loop Teleport",
    Default = false,
    Callback = function(Value)
        npcTargetEnabled = Value
        if Value then
            createNPCTargetPlate()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            local renderConnection = RunService.RenderStepped:Connect(function()
                if npcTargetEnabled and npcTargetPlate then
                    local targetNPC = findNearestNPC()
                    if targetNPC then
                        local npcHRP = targetNPC:FindFirstChild("HumanoidRootPart") or targetNPC:FindFirstChild("Torso")
                        if npcHRP then
                            local npcPos = npcHRP.Position
                            local belowPos = Vector3.new(npcPos.X, npcPos.Y - npcTargetDistance, npcPos.Z)
                            humanoidRootPart.CFrame = CFrame.new(belowPos)
                            npcTargetPlate.Position = Vector3.new(belowPos.X, belowPos.Y - 2.5, belowPos.Z)
                        end
                    end
                end
            end)
            
            npcTargetLoop = renderConnection
        else
            if npcTargetLoop then
                task.cancel(npcTargetLoop)
            end
            if npcTargetPlate then
                npcTargetPlate:Destroy()
                npcTargetPlate = nil
            end
        end
    end,
})

NPCTargetToggle:AddKeyPicker("NPCTargetKeybind", {
    Text = "Loop Teleport",
    Mode = "Toggle",
    Callback = function()
        NPCTargetToggle:SetValue(not Toggles.NPCTargetToggle.Value)
    end,
})

NPCTargetterGroup:AddSlider("NPCDistanceSlider", {
    Text = "Distance Below",
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        npcTargetDistance = Value
    end,
})

Library:OnUnload(function()
    stopTpWalk()
    stopNoclip()
    stopInfJump()
    unloadF3X()
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

MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "N", NoUI = true, Text = "Menu keybind" })

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
-- Fall dmg disabler
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:WaitForChild("Events", 10)
if events then
    local fallDamageRemote = events:WaitForChild("FallDamage", 10)
    if fallDamageRemote then
        fallDamageRemote:Destroy()
    end
end


