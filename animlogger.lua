local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local animationLog = {}
local animationCounts = {}
local animationNames = {} -- Store animation names

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local ClearButton = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.Size = UDim2.new(0, 450, 0, 400)

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Animation Logger - Devotion_M on discord"
Title.TextColor3 = Color3.fromRGB(120, 80, 150)
Title.TextSize = 14

ClearButton.Name = "ClearButton"
ClearButton.Parent = TopBar
ClearButton.BackgroundColor3 = Color3.fromRGB(80, 50, 100)
ClearButton.BorderSizePixel = 0
ClearButton.Position = UDim2.new(1, -60, 0, 5)
ClearButton.Size = UDim2.new(0, 25, 0, 20)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Text = "CLR"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 10

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.TextSize = 18

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0, 5, 0, 35)
ScrollFrame.Size = UDim2.new(1, -10, 1, -40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 150)

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function updateCanvasSize()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
end

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

local function playAnimation(animId)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animId
    
    local animationTrack = humanoid:LoadAnimation(animation)
    animationTrack:Play()
end

local function createLogEntry(animId, animName, count)
    local EntryFrame = Instance.new("Frame")
    local NameText = Instance.new("TextLabel")
    local IdText = Instance.new("TextLabel")
    local PlayButton = Instance.new("TextButton")
    local CopyButton = Instance.new("TextButton")
    
    EntryFrame.Name = "EntryFrame"
    EntryFrame.Parent = ScrollFrame
    EntryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    EntryFrame.BorderSizePixel = 0
    EntryFrame.Size = UDim2.new(1, -6, 0, 50)
    
    -- Animation Name
    NameText.Name = "NameText"
    NameText.Parent = EntryFrame
    NameText.BackgroundTransparency = 1
    NameText.Position = UDim2.new(0, 10, 0, 5)
    NameText.Size = UDim2.new(1, -130, 0, 18)
    NameText.Font = Enum.Font.GothamBold
    NameText.Text = animName .. " x" .. count
    NameText.TextColor3 = Color3.fromRGB(120, 80, 150)
    NameText.TextSize = 12
    NameText.TextXAlignment = Enum.TextXAlignment.Left
    NameText.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Animation ID
    IdText.Name = "IdText"
    IdText.Parent = EntryFrame
    IdText.BackgroundTransparency = 1
    IdText.Position = UDim2.new(0, 10, 0, 25)
    IdText.Size = UDim2.new(1, -130, 0, 18)
    IdText.Font = Enum.Font.Gotham
    IdText.Text = "ID: " .. animId
    IdText.TextColor3 = Color3.fromRGB(150, 150, 150)
    IdText.TextSize = 10
    IdText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Play Button
    PlayButton.Name = "PlayButton"
    PlayButton.Parent = EntryFrame
    PlayButton.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
    PlayButton.BorderSizePixel = 0
    PlayButton.Position = UDim2.new(1, -115, 0, 5)
    PlayButton.Size = UDim2.new(0, 50, 0, 40)
    PlayButton.Font = Enum.Font.GothamBold
    PlayButton.Text = "▶"
    PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayButton.TextSize = 16
    
    -- Copy Button
    CopyButton.Name = "CopyButton"
    CopyButton.Parent = EntryFrame
    CopyButton.BackgroundColor3 = Color3.fromRGB(80, 50, 100)
    CopyButton.BorderSizePixel = 0
    CopyButton.Position = UDim2.new(1, -60, 0, 5)
    CopyButton.Size = UDim2.new(0, 50, 0, 40)
    CopyButton.Font = Enum.Font.GothamBold
    CopyButton.Text = "Copy"
    CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyButton.TextSize = 11
    
    PlayButton.MouseButton1Click:Connect(function()
        playAnimation(animId)
        PlayButton.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
        wait(0.2)
        PlayButton.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
    end)
    
    CopyButton.MouseButton1Click:Connect(function()
        setclipboard(animId)
        CopyButton.Text = "✓"
        wait(1)
        CopyButton.Text = "Copy"
    end)
    
    return EntryFrame
end

local function updateLog(animId, animName)
    if animationCounts[animId] then
        animationCounts[animId] = animationCounts[animId] + 1
        for _, entry in pairs(ScrollFrame:GetChildren()) do
            if entry:IsA("Frame") and entry:FindFirstChild("IdText") then
                local idText = entry.IdText.Text
                if idText:match(animId) then
                    entry.NameText.Text = animName .. " x" .. animationCounts[animId]
                    break
                end
            end
        end
    else
        animationCounts[animId] = 1
        animationNames[animId] = animName
        table.insert(animationLog, animId)
        createLogEntry(animId, animName, 1)
    end
end

local function setupAnimationTracking(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.AnimationPlayed:Connect(function(animationTrack)
        local animation = animationTrack.Animation
        local animId = animation.AnimationId:match("%d+")
        local animName = animation.Name
        
        if animId then
            updateLog(animId, animName)
        end
    end)
end

if LocalPlayer.Character then
    setupAnimationTracking(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    setupAnimationTracking(character)
end)

ClearButton.MouseButton1Click:Connect(function()
    for _, entry in pairs(ScrollFrame:GetChildren()) do
        if entry:IsA("Frame") then
            entry:Destroy()
        end
    end
    animationLog = {}
    animationCounts = {}
    animationNames = {}
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local dragging
local dragInput
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
