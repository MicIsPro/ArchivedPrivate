local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local viewing = nil
local viewDied = nil
local viewChanged = nil
local espConnections = {}

local filteredItems = {
    "Fragment of silence",
    "seed of light", 
    "mirror shard",
    "book of library",
    "Book of The Library",
    "sealed book cache",
    "Fragment of Ruined Mirror Worlds",
    "Enkephalin",
    "Serum W",
    "Serum R",
    "Serum K",
    "Gravity Manipulation",
    "Mist of The Lake",
    "Sinner Contract",
    "Wild Hunt",
    "Enchain",
    "Deathseeking",
    "Chefs Blessing",
    "Borrowed Eyes",
    "Silencing Gloves",
    "Shockwave",
    "Manifested Armor"
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
    "Organs"
}

local function containsCache(itemName)
    return string.lower(itemName):find("cache") ~= nil
end

local function isFilteredItem(itemName)
    local lowerName = string.lower(itemName)
    for _, filterItem in pairs(filteredItems) do
        if lowerName == string.lower(filterItem) then
            return true
        end
    end
    return containsCache(itemName)
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
mainFrame.Size = UDim2.new(0, 750, 0, 550)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 25)
titleFix.Position = UDim2.new(0, 0, 1, -25)
titleFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -150, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Backpack Scanner"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeButton

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 40)
tabFrame.Position = UDim2.new(0, 10, 0, 60)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local filteredTab = Instance.new("TextButton")
filteredTab.Size = UDim2.new(0, 150, 1, 0)
filteredTab.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
filteredTab.Text = "Filtered Items"
filteredTab.TextColor3 = Color3.fromRGB(255, 255, 255)
filteredTab.TextSize = 16
filteredTab.Font = Enum.Font.Gotham
filteredTab.BorderSizePixel = 0
filteredTab.Parent = tabFrame

local filteredTabCorner = Instance.new("UICorner")
filteredTabCorner.CornerRadius = UDim.new(0, 8)
filteredTabCorner.Parent = filteredTab

local fullBackpackTab = Instance.new("TextButton")
fullBackpackTab.Size = UDim2.new(0, 150, 1, 0)
fullBackpackTab.Position = UDim2.new(0, 160, 0, 0)
fullBackpackTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fullBackpackTab.Text = "Full Backpacks"
fullBackpackTab.TextColor3 = Color3.fromRGB(255, 255, 255)
fullBackpackTab.TextSize = 16
fullBackpackTab.Font = Enum.Font.Gotham
fullBackpackTab.BorderSizePixel = 0
fullBackpackTab.Parent = tabFrame

local fullTabCorner = Instance.new("UICorner")
fullTabCorner.CornerRadius = UDim.new(0, 8)
fullTabCorner.Parent = fullBackpackTab

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -120)
contentFrame.Position = UDim2.new(0, 10, 0, 110)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

local currentTab = "filtered"

local function updateCanvasSize()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

local function createPlayerEntry(player, items, stats)
    local playerFrame = Instance.new("Frame")
    playerFrame.Size = UDim2.new(1, -10, 0, 100)
    playerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    playerFrame.BorderSizePixel = 0
    playerFrame.Parent = scrollFrame
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 6)
    playerCorner.Parent = playerFrame
    
    local viewButton = Instance.new("TextButton")
    viewButton.Size = UDim2.new(0, 60, 0, 25)
    viewButton.Position = UDim2.new(1, -130, 0, 5)
    viewButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    viewButton.Text = "View"
    viewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    viewButton.TextSize = 11
    viewButton.Font = Enum.Font.Gotham
    viewButton.BorderSizePixel = 0
    viewButton.Parent = playerFrame
    
    local viewBtnCorner = Instance.new("UICorner")
    viewBtnCorner.CornerRadius = UDim.new(0, 4)
    viewBtnCorner.Parent = viewButton
    
    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 60, 0, 25)
    espButton.Position = UDim2.new(1, -65, 0, 5)
    espButton.BackgroundColor3 = Color3.fromRGB(120, 70, 200)
    espButton.Text = "ESP"
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.TextSize = 11
    espButton.Font = Enum.Font.Gotham
    espButton.BorderSizePixel = 0
    espButton.Parent = playerFrame
    
    local espBtnCorner = Instance.new("UICorner")
    espBtnCorner.CornerRadius = UDim.new(0, 4)
    espBtnCorner.Parent = espButton
    
    local unviewBtn = Instance.new("TextButton")
    unviewBtn.Size = UDim2.new(0, 60, 0, 25)
    unviewBtn.Position = UDim2.new(1, -130, 0, 35)
    unviewBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    unviewBtn.Text = "Unview"
    unviewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unviewBtn.TextSize = 11
    unviewBtn.Font = Enum.Font.Gotham
    unviewBtn.BorderSizePixel = 0
    unviewBtn.Parent = playerFrame
    
    local unviewBtnCorner = Instance.new("UICorner")
    unviewBtnCorner.CornerRadius = UDim.new(0, 4)
    unviewBtnCorner.Parent = unviewBtn
    
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(0.3, -140, 0, 25)
    playerName.Position = UDim2.new(0, 10, 0, 5)
    playerName.BackgroundTransparency = 1
    playerName.Text = player.Name
    playerName.TextColor3 = Color3.fromRGB(255, 255, 100)
    playerName.TextSize = 16
    playerName.Font = Enum.Font.GothamBold
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.Parent = playerFrame
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.3, -140, 0, 20)
    statsLabel.Position = UDim2.new(0, 10, 0, 30)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Ahn: " .. (stats.Ahn or 0) .. " | Singularity: " .. (stats.Singularity or 0)
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextSize = 12
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = playerFrame
    
    local itemsLabel = Instance.new("TextLabel")
    itemsLabel.Size = UDim2.new(0.7, -140, 1, -10)
    itemsLabel.Position = UDim2.new(0.3, 10, 0, 5)
    itemsLabel.BackgroundTransparency = 1
    itemsLabel.Text = items
    itemsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemsLabel.TextSize = 12
    itemsLabel.Font = Enum.Font.Gotham
    itemsLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemsLabel.TextYAlignment = Enum.TextYAlignment.Top
    itemsLabel.TextWrapped = true
    itemsLabel.Parent = playerFrame
    
    viewButton.MouseButton1Click:Connect(function()
        startViewing(player)
    end)
    
    unviewBtn.MouseButton1Click:Connect(function()
        if viewing == player then
            stopViewing()
        end
    end)
    
    espButton.MouseButton1Click:Connect(function()
        if espConnections[player.Name] then
            removeESP(player)
            espButton.Text = "ESP"
            espButton.BackgroundColor3 = Color3.fromRGB(120, 70, 200)
        else
            createESP(player)
            espButton.Text = "UnESP"
            espButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        end
    end)
    
    if espConnections[player.Name] then
        espButton.Text = "UnESP"
        espButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    end
    
    return playerFrame
end

local function updateDisplay()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local items, stats = scanPlayerBackpack(player, currentTab == "filtered")
            if items ~= "" or currentTab == "full" then
                createPlayerEntry(player, items == "" and "No items found" or items, stats)
            end
        end
    end
    
    updateCanvasSize()
end

filteredTab.MouseButton1Click:Connect(function()
    currentTab = "filtered"
    filteredTab.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    fullBackpackTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    updateDisplay()
end)

fullBackpackTab.MouseButton1Click:Connect(function()
    currentTab = "full"
    fullBackpackTab.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    filteredTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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