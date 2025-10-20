local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local viewing = nil
local viewDied = nil
local viewChanged = nil
local espConnections = {}
local playerFrames = {}

local specialPlayers = {
    ["Devotion_M"] = {note = "???", redacted = true},
    ["azrisKitten"] = {note = "bait used to be beli- HOLY SHIT IS THAT THE RED MIST", redacted = true},
    ["iLuhMyJ"] = {note = "The Color Fixer", redacted = true},
    ["jcsseai"] = {note = "???", redacted = true}
}

local filteredItems = {
    "Fragment Of Silence",
    "Fragment of Ruined Mirror Worlds",
    "Fused Blade of Ruined Mirror Worlds",
    "Seed Of Light",
    "Mirror Shard",
    "Rewound Time",
    "Glass Of Oblivion",
    "First Kindret Blood",
    "Manifested Armor Shard",
    "Secret Cookbook",
    "Borrowed Eye",
    "Meteorite Fragment",
    "Anklet of the Lake",
    "Degraded Lock",
    "Serum W Vial",
    "Serum R Vial",
    "Serum K Vial",
    "Fixer Glove",
    "Arbiter Essence",
    "Essence of Destruction",
    "Busted Clock",
    "Seeker's Nail",
    "Silencing glove"
}

local excludedItems = {
    "Wiring",
    "Broken Gauntlet", 
    "Gun Parts",
    "Light Handle",
    "Heavy Handle",
    "Handle",
    "Office Manager",
    "Hammer Head",
    "Rope",
    "Low Quality Blade",
    "Scrap Metal",
    "Makeshift Handle",
    "Organs",
    "Gears",
    "Spices",
    "Cup Of Coffee",
    "Book Of a Grade 9 Fixer",
    "Book Of a Grade 7 Fixer",
    "Book Of Zwei Association",
    "Book Of Hana Association",
    "Book Of Shi Association",
    "Book Of Stray Dogs",
"Focused Strikes",
"Dodge and Strike",
"Charge and Cover",
"Thrust",
"Light Attack",
"Alleyway Counter",
"Right Hook",
"Opportunistic Slash",
"Y-you Only Live Once",
"Deep Cuts",
"Mutilate",
"Sky Kick",
"Dropkick",
"Backstreets Scramble",
"You're Too Slow",
"Stylish Sweeps",
"Shocking Blow",
"Crush",
"Onslaught Command",
"Preemptive Strike",
"Fleet Footsteps",
"Set Fire",
"Blade Flourish",
"Waltz in Black",
"Waltz In White",
"Light Dash",
"Degraded Shockwave",
"Scales of Judgement",
"Destruction Awaits",
"Client Protection",
"Standoff",
"Blade Whirl",
"Law and Order",
"Augury Crusher",
"Augury Infusion",
"Augury Kick",
"Celestial Sight",
"Catch Breath",
"Extreme Edge",
"Flying Sword",
"Boundary Of Death",
"Severing Flash",
"Contre Attaque",
"Engagement",
"Balestra Fente",
"Perfected Death Fist",
"Raging Storm",
"Fiery Waltz",
"Red Kick",
"Flowing Flame",
"Ignite Weaponry",
"Fleet Edge",
"Flow of the Sword",
"Dissect Target",
"Moulinet",
"Swash",
"Investigation",
"Weight Of Knowledge",
"Illuminate Thy Vacuity",
"Studious Dedication",
"Scorch Knowledge",
"Pistol Draw",
"Coin Tricky",
"Summary Judgement",
"Re-Load",
"Execute Prescript",
"Somber Procuration",
"Will of The City",
"Proof of Loyalty",
"Kicking",
"Punching",
"A Just Vengeance",
"MY HAIR COUPOOOOOOONS!",
"COMPLETE AND TOTAL EXTERMINATION!!!",
"Vengeance Retaliation",
"Sanguine Painting",
"Hematic Coloring",
"Paint Over",
"Slash Series",
"Overthrow",
"Fare-Thee Well!",
"Red Plum Blossoms Scatter",
"Moon-Splitting Draw",
"Yield My Flesh",
"Sober Up",
"Cloud Cutter",
"Silent Mist",
"Shadowcloud Kick",
"Sky Clearing Cut",
"Dark Cloud Cleaver",
"Shadowcloud Shattercleave",
"Inhale",
"Exhale Smoke",
"Loss of Senses",
"Purify",
"Cackle",
"Rip",
"Charge Shield",
"Leap",
"Overcharged Ripple",
"Level Slash",
"Upstanding Slash",
"Onrush",
"Spear",
"Focus Spirit",
"Lupine Onslaught",
"Kicks and Stomps",
"Rapacious Assault",
"Pitch-Black Pulverizer",
"Extract Fuel",
"Trash Disposal",
"Greatsword Rend",
"Behead Heathcliffs",
"Smackdown",
"Grovel Before Me, Pathetic One",
"Go… Go Away…!",
"Siphon",
"Topple",
"Wound",
"Hardblood Impact",
"Suffocating Guilt",
    "Dark Gloom Vestige",
    "Faint Gloom Vestige",
    "Twinkling Gloom Vestige",
    "Brilliant Gloom Vestige",
    "Lunar Gloom Vestige",
    "Dark Gluttony Vestige",
    "Faint Gluttony Vestige",
    "Twinkling Gluttony Vestige",
    "Brilliant Gluttony Vestige",
    "Lunar Gluttony Vestige",
    "Dark Desire Vestige",
    "Faint Desire Vestige",
    "Twinkling Desire Vestige",
    "Brilliant Desire Vestige",
    "Lunar Desire Vestige",
    "Dark Sloth Vestige",
    "Faint Sloth Vestige",
    "Twinkling Sloth Vestige",
    "Brilliant Sloth Vestige",
    "Lunar Sloth Vestige",
    "Dark Envy Vestige",
    "Faint Envy Vestige",
    "Twinkling Envy Vestige",
    "Brilliant Envy Vestige",
    "Lunar Envy Vestige",
    "Dark Pride Vestige",
    "Faint Pride Vestige",
    "Twinkling Pride Vestige",
    "Brilliant Pride Vestige",
    "Lunar Pride Vestige",
}

local function isFilteredItem(itemName)
    local lowerName = string.lower(itemName)
    for _, filteredItem in pairs(filteredItems) do
        if lowerName == string.lower(filteredItem) then
            return true
        end
    end
    return false
end

local function isExcludedItem(itemName)
    local lowerName = string.lower(itemName)
    for _, excludedItem in pairs(excludedItems) do
        if lowerName == string.lower(excludedItem) then
            return true
        end
    end
    return false
end

local function createESP(player)
    if espConnections[player.Name] then return end
    
    local function createESPGui()
        if not player.Character or not player.Character:FindFirstChild("Head") then return end
        
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "ESP_" .. player.Name
        espGui.Parent = player.Character.Head
        espGui.Size = UDim2.new(0, 200, 0, 50)
        espGui.StudsOffset = Vector3.new(0, 2, 0)
        espGui.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        nameLabel.TextSize = 16
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Parent = espGui
        
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        hpLabel.TextSize = 14
        hpLabel.Font = Enum.Font.Gotham
        hpLabel.TextStrokeTransparency = 0
        hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        hpLabel.Parent = espGui
        
        local function updateHP()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                hpLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            end
        end
        
        updateHP()
        
        local hpConnection = RunService.Heartbeat:Connect(updateHP)
        
        return espGui, hpConnection
    end
    
    local espGui, hpConnection = createESPGui()
    
    local charConnection = player.CharacterAdded:Connect(function()
        if espGui then espGui:Destroy() end
        if hpConnection then hpConnection:Disconnect() end
        wait(1)
        espGui, hpConnection = createESPGui()
    end)
    
    espConnections[player.Name] = {
        charConnection = charConnection,
        hpConnection = hpConnection,
        espGui = espGui
    }
end

local function removeESP(player)
    if espConnections[player.Name] then
        local connections = espConnections[player.Name]
        if connections.charConnection then connections.charConnection:Disconnect() end
        if connections.hpConnection then connections.hpConnection:Disconnect() end
        if connections.espGui then connections.espGui:Destroy() end
        espConnections[player.Name] = nil
    end
end

local function stopViewing()
    if viewing ~= nil then
        viewing = nil
    end
    if viewDied then
        viewDied:Disconnect()
        viewChanged:Disconnect()
        viewDied = nil
        viewChanged = nil
    end
    workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
end

local function startViewing(player)
    stopViewing()
    
    if player.Character then
        viewing = player
        workspace.CurrentCamera.CameraSubject = viewing.Character
        
        local function viewDiedFunc()
            repeat wait() until player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart")
            if viewing == player then
                workspace.CurrentCamera.CameraSubject = viewing.Character
            end
        end
        viewDied = player.CharacterAdded:Connect(viewDiedFunc)
        
        local function viewChangedFunc()
            if viewing == player and player.Character then
                workspace.CurrentCamera.CameraSubject = viewing.Character
            end
        end
        viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
    end
end

local function getPlayerStats(player)
    local stats = {Ahn = 0, Singularity = 0}
    local playerData = Players:FindFirstChild(player.Name)
    if playerData and playerData:FindFirstChild("Data") then
        local data = playerData.Data
        if data:FindFirstChild("Ahn") then
            stats.Ahn = data.Ahn.Value or 0
        end
        if data:FindFirstChild("Singularity") then
            stats.Singularity = data.Singularity.Value or 0
        end
    end
    return stats
end

local function scanPlayerBackpack(player, useFilter)
    if specialPlayers[player.Name] then
        return "[CLASSIFIED]", {Ahn = "███████", Singularity = "███████"}
    end
    
    if not player:FindFirstChild("Backpack") then return "", getPlayerStats(player) end
    
    local backpack = player.Backpack
    local itemCounts = {}
    local itemsList = {}
    
    for _, item in pairs(backpack:GetChildren()) do
        if useFilter then
            if isFilteredItem(item.Name) then
                itemCounts[item.Name] = (itemCounts[item.Name] or 0) + 1
            end
        else
            if not isExcludedItem(item.Name) then
                itemCounts[item.Name] = (itemCounts[item.Name] or 0) + 1
            end
        end
    end
    
    for itemName, count in pairs(itemCounts) do
        if count > 1 then
            table.insert(itemsList, itemName .. " x" .. count)
        else
            table.insert(itemsList, itemName)
        end
    end
    
    return table.concat(itemsList, ", "), getPlayerStats(player)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackpackScannerGUI"
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
})
titleGradient.Rotation = 90
titleGradient.Parent = titleBar

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 30)
titleFix.Position = UDim2.new(0, 0, 1, -30)
titleFix.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -150, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Backpack Scanner"
titleLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeBtnGradient = Instance.new("UIGradient")
closeBtnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 60, 60))
})
closeBtnGradient.Rotation = 90
closeBtnGradient.Parent = closeButton

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 10)
closeBtnCorner.Parent = closeButton

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -40, 0, 50)
tabFrame.Position = UDim2.new(0, 20, 0, 80)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local filteredTab = Instance.new("TextButton")
filteredTab.Size = UDim2.new(0, 180, 1, 0)
filteredTab.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
filteredTab.Text = "Filtered Items"
filteredTab.TextColor3 = Color3.fromRGB(255, 255, 255)
filteredTab.TextSize = 16
filteredTab.Font = Enum.Font.GothamBold
filteredTab.BorderSizePixel = 0
filteredTab.Parent = tabFrame

local filteredTabGradient = Instance.new("UIGradient")
filteredTabGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 220))
})
filteredTabGradient.Rotation = 90
filteredTabGradient.Parent = filteredTab

local filteredTabCorner = Instance.new("UICorner")
filteredTabCorner.CornerRadius = UDim.new(0, 12)
filteredTabCorner.Parent = filteredTab

local fullBackpackTab = Instance.new("TextButton")
fullBackpackTab.Size = UDim2.new(0, 180, 1, 0)
fullBackpackTab.Position = UDim2.new(0, 200, 0, 0)
fullBackpackTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
fullBackpackTab.Text = "Full Backpacks"
fullBackpackTab.TextColor3 = Color3.fromRGB(180, 180, 180)
fullBackpackTab.TextSize = 16
fullBackpackTab.Font = Enum.Font.GothamBold
fullBackpackTab.BorderSizePixel = 0
fullBackpackTab.Parent = tabFrame

local fullTabGradient = Instance.new("UIGradient")
fullTabGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
})
fullTabGradient.Rotation = 90
fullTabGradient.Parent = fullBackpackTab

local fullTabCorner = Instance.new("UICorner")
fullTabCorner.CornerRadius = UDim.new(0, 12)
fullTabCorner.Parent = fullBackpackTab

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -40, 1, -150)
contentFrame.Position = UDim2.new(0, 20, 0, 140)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentGradient = Instance.new("UIGradient")
contentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
contentGradient.Rotation = 180
contentGradient.Parent = contentFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -20)
scrollFrame.Position = UDim2.new(0, 10, 0, 10)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 12
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

local currentTab = "filtered"

local function updateCanvasSize()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

local function updateViewButtons()
    for _, frame in pairs(playerFrames) do
        if frame and frame.Parent and frame:FindFirstChild("ViewButton") then
            local viewButton = frame.ViewButton
            local player = Players:FindFirstChild(frame.Name:sub(13))
            if player then
                if viewing == player then
                    viewButton.Text = "Unview"
                    viewButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                else
                    viewButton.Text = "View"
                    viewButton.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
                end
            end
        end
    end
end

local function createPlayerEntry(player, items, stats)
    local isSpecial = specialPlayers[player.Name] ~= nil
    
    local playerFrame = Instance.new("Frame")
    playerFrame.Name = "PlayerFrame_" .. player.Name
    playerFrame.Size = UDim2.new(1, -20, 0, 120)
    playerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    playerFrame.BorderSizePixel = 0
    playerFrame.Parent = scrollFrame
    
    local playerGradient = Instance.new("UIGradient")
    playerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
    })
    playerGradient.Rotation = 90
    playerGradient.Parent = playerFrame
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 10)
    playerCorner.Parent = playerFrame
    
    if not isSpecial then
        local viewButton = Instance.new("TextButton")
        viewButton.Name = "ViewButton"
        viewButton.Size = UDim2.new(0, 80, 0, 30)
        viewButton.Position = UDim2.new(1, -170, 0, 10)
        viewButton.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
        viewButton.Text = "View"
        viewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        viewButton.TextSize = 12
        viewButton.Font = Enum.Font.GothamBold
        viewButton.BorderSizePixel = 0
        viewButton.Parent = playerFrame
        
        local viewBtnGradient = Instance.new("UIGradient")
        viewBtnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 120, 220))
        })
        viewBtnGradient.Rotation = 90
        viewBtnGradient.Parent = viewButton
        
        local viewBtnCorner = Instance.new("UICorner")
        viewBtnCorner.CornerRadius = UDim.new(0, 8)
        viewBtnCorner.Parent = viewButton
        
        local espButton = Instance.new("TextButton")
        espButton.Size = UDim2.new(0, 80, 0, 30)
        espButton.Position = UDim2.new(1, -80, 0, 10)
        espButton.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
        espButton.Text = "ESP"
        espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        espButton.TextSize = 12
        espButton.Font = Enum.Font.GothamBold
        espButton.BorderSizePixel = 0
        espButton.Parent = playerFrame
        
        local espBtnGradient = Instance.new("UIGradient")
        espBtnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 60, 220))
        })
        espBtnGradient.Rotation = 90
        espBtnGradient.Parent = espButton
        
        local espBtnCorner = Instance.new("UICorner")
        espBtnCorner.CornerRadius = UDim.new(0, 8)
        espBtnCorner.Parent = espButton
        
        if viewing == player then
            viewButton.Text = "Unview"
            viewButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        if espConnections[player.Name] then
            espButton.Text = "UnESP"
            espButton.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
        end
        
        viewButton.MouseButton1Click:Connect(function()
            if viewing == player then
                stopViewing()
            else
                startViewing(player)
            end
            updateViewButtons()
        end)
        
        espButton.MouseButton1Click:Connect(function()
            if espConnections[player.Name] then
                removeESP(player)
                espButton.Text = "ESP"
                espButton.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
            else
                createESP(player)
                espButton.Text = "UnESP"
                espButton.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
            end
        end)
    end
    
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(0.4, -180, 0, 30)
    playerName.Position = UDim2.new(0, 15, 0, 10)
    playerName.BackgroundTransparency = 1
    local displayName = player.Name
    local nameColor = Color3.fromRGB(120, 200, 255)
    if isSpecial then
        displayName = player.Name .. " - " .. specialPlayers[player.Name].note
        nameColor = Color3.fromRGB(255, 50, 50)
    end
    playerName.Text = displayName
    playerName.TextColor3 = nameColor
    playerName.TextSize = 18
    playerName.Font = Enum.Font.GothamBold
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.Parent = playerFrame
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.4, -180, 0, 25)
    statsLabel.Position = UDim2.new(0, 15, 0, 40)
    statsLabel.BackgroundTransparency = 1
    local statsText
    if type(stats.Ahn) == "string" and stats.Ahn == "███████" then
        statsText = "Ahn: ███████ | Singularity: ███████"
    else
        statsText = "Ahn: " .. (stats.Ahn or 0) .. " | Singularity: " .. (stats.Singularity or 0)
    end
    statsLabel.Text = statsText
    statsLabel.TextColor3 = Color3.fromRGB(255, 215, 100)
    statsLabel.TextSize = 14
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = playerFrame
    
    local itemsLabel = Instance.new("TextLabel")
    itemsLabel.Size = UDim2.new(0.6, -190, 1, -20)
    itemsLabel.Position = UDim2.new(0.4, 15, 0, 10)
    itemsLabel.BackgroundTransparency = 1
    itemsLabel.Text = items == "" and "No items found" or items
    itemsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemsLabel.TextSize = 12
    itemsLabel.Font = Enum.Font.Gotham
    itemsLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemsLabel.TextYAlignment = Enum.TextYAlignment.Top
    itemsLabel.TextWrapped = true
    itemsLabel.Parent = playerFrame
    
    playerFrames[player.Name] = playerFrame
    
    return playerFrame
end

local function updateDisplay()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    playerFrames = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local items, stats = scanPlayerBackpack(player, currentTab == "filtered")
            if items ~= "" or currentTab == "full" then
                createPlayerEntry(player, items, stats)
            end
        end
    end
    
    updateCanvasSize()
end

filteredTab.MouseButton1Click:Connect(function()
    currentTab = "filtered"
    filteredTab.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    filteredTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    fullBackpackTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    fullBackpackTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    updateDisplay()
end)

fullBackpackTab.MouseButton1Click:Connect(function()
    currentTab = "full"
    fullBackpackTab.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    fullBackpackTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    filteredTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    filteredTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    updateDisplay()
end)

closeButton.MouseButton1Click:Connect(function()
    if viewing then
        stopViewing()
    end
    for playerName, _ in pairs(espConnections) do
        local player = Players:FindFirstChild(playerName)
        if player then
            removeESP(player)
        end
    end
    screenGui:Destroy()
end)

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

spawn(function()
    while screenGui.Parent do
        updateDisplay()
        wait(2)
    end
end)

updateDisplay()


