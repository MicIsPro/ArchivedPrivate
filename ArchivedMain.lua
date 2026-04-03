local Players = game:GetService("Players") :: Players
local HttpService = game:GetService("HttpService") :: HttpService
local StarterGui = game:GetService("StarterGui") :: StarterGui
local MarketplaceService = game:GetService("MarketplaceService")
local Player = Players.LocalPlayer :: Player

local ValidKeys = {
    ["JSE6D598TSLKA4ERT89AERTHTFGAE56"] = {hwid = "aC2746D41-7990-450F-8F82-34D5FF0B2D33", name = "Mic's key"},
    ["K7X9M2QP8WN5VB1ZT4RHJ6YC2LD8PF3"] = {hwid = "", name = "Fabi's key"},
    [""] = {hwid = "", name = "Zarc's key"},
    ["XMNB54389DFCGZDMBTWEE4RGFASEFLB"] = {hwid = "EA1E7342-69B5-4199-9278-80AD2324B01C", name = "Sembrell's key"},
}

local DiscordWebhook = "https://discord.com/api/webhooks/1432346858629496854/-cm23r_TiuqYzOr75kfdzkrihcPi883pOQz58mFjpK0DL9mNzgSk82KpeuCMfzlff241"

local function SendNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

local function LogToDiscord(key, keyName, hwid, success, reason)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local status = success and "✓ SUCCESS" or "✗ FAILED"
    local isKeyBound = reason == "Key successfully bound to HWID"
    local isAwaitingBind = reason == "Key awaiting HWID bind"

    if DiscordWebhook ~= "" then
        pcall(function()
            local fields = {
                {["name"] = "Player", ["value"] = Player.Name, ["inline"] = true},
                {["name"] = "Status", ["value"] = status, ["inline"] = true},
                {["name"] = "Key Name", ["value"] = keyName or "Unknown", ["inline"] = true},
                {["name"] = "Key", ["value"] = "||" .. (key or "AUTO-LOAD") .. "||", ["inline"] = false},
                {["name"] = "HWID", ["value"] = "||" .. hwid .. "||", ["inline"] = false},
                {["name"] = "Timestamp", ["value"] = timestamp, ["inline"] = false}
            }

            if reason then
                table.insert(fields, {["name"] = "Reason", ["value"] = reason, ["inline"] = false})
            end

            local embed = {
                ["content"] = (isKeyBound or isAwaitingBind) and "<@523218932568686593>" or nil,
                ["embeds"] = {{
                    ["title"] = "🔐 Key System Log",
                    ["color"] = success and 3066993 or 15158332,
                    ["fields"] = fields,
                    ["footer"] = {["text"] = "HWID-Locked Key System"}
                }}
            }

            if request then
                request({
                    Url = DiscordWebhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(embed)
                })
            end
        end)
    end
end

local function CheckHWIDMatch()
    local hwid = GetHWID()

    for key, data in pairs(ValidKeys) do
        if data.hwid == hwid then
            return true, key, data.name
        end
    end

    return false, nil, nil
end

local function LoadMainScript()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/MicIsPro/ArchivedPrivate/refs/heads/main/Main.lua")
    end)

    if success and result then
        loadstring(result)()
    end
end

local function ValidateKey(key)
    local hwid = GetHWID()

    if ValidKeys[key] == nil then
        LogToDiscord(key, "Unknown", hwid, false, "Key does not exist")
        return false, "Invalid key"
    end

    local keyData = ValidKeys[key]
    local boundHWID = keyData.hwid
    local keyName = keyData.name

    if boundHWID == "" then
        ValidKeys[key].hwid = hwid
        LogToDiscord(key, keyName, hwid, true, "Key awaiting HWID bind")
        return true, "Key validated and bound to your device!"
    end

    if boundHWID == hwid then
        LogToDiscord(key, keyName, hwid, true, "HWID matched")
        return true, "Key validated successfully!"
    else
        LogToDiscord(key, keyName, hwid, false, "HWID mismatch - Key bound to different device")
        return false, "This key is bound to another device"
    end
end

local function CreateHWIDResetGUI()
    local ResetGui = Instance.new("ScreenGui")
    ResetGui.Name = "HWIDResetPrompt"
    ResetGui.ResetOnSpawn = false
    ResetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ResetFrame = Instance.new("Frame")
    ResetFrame.Size = UDim2.new(0, 320, 0, 110)
    ResetFrame.Position = UDim2.new(0.5, -160, 0.5, 125)
    ResetFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ResetFrame.BorderSizePixel = 0
    ResetFrame.Parent = ResetGui

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 12)
    ResetCorner.Parent = ResetFrame

    local ResetStroke = Instance.new("UIStroke")
    ResetStroke.Color = Color3.fromRGB(40, 40, 40)
    ResetStroke.Thickness = 1
    ResetStroke.Parent = ResetFrame

    local TopBar2 = Instance.new("Frame")
    TopBar2.Size = UDim2.new(1, 0, 0, 45)
    TopBar2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar2.BorderSizePixel = 0
    TopBar2.Parent = ResetFrame

    local TopCorner2 = Instance.new("UICorner")
    TopCorner2.CornerRadius = UDim.new(0, 12)
    TopCorner2.Parent = TopBar2

    local BottomCover2 = Instance.new("Frame")
    BottomCover2.Size = UDim2.new(1, 0, 0, 12)
    BottomCover2.Position = UDim2.new(0, 0, 1, -12)
    BottomCover2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    BottomCover2.BorderSizePixel = 0
    BottomCover2.Parent = TopBar2

    local ResetTitle = Instance.new("TextLabel")
    ResetTitle.Size = UDim2.new(1, -20, 1, 0)
    ResetTitle.Position = UDim2.new(0, 15, 0, 0)
    ResetTitle.BackgroundTransparency = 1
    ResetTitle.Text = "🔄  Want your HWID reset then pay up!"
    ResetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetTitle.TextSize = 15
    ResetTitle.Font = Enum.Font.GothamBold
    ResetTitle.TextXAlignment = Enum.TextXAlignment.Left
    ResetTitle.Parent = TopBar2

    local ClickButton = Instance.new("TextButton")
    ClickButton.Size = UDim2.new(1, -40, 0, 38)
    ClickButton.Position = UDim2.new(0, 20, 0, 57)
    ClickButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    ClickButton.BorderSizePixel = 0
    ClickButton.Text = "Click Here"
    ClickButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    ClickButton.TextSize = 14
    ClickButton.Font = Enum.Font.GothamBold
    ClickButton.Parent = ResetFrame

    local ClickCorner = Instance.new("UICorner")
    ClickCorner.CornerRadius = UDim.new(0, 8)
    ClickCorner.Parent = ClickButton

    ClickButton.MouseEnter:Connect(function()
        ClickButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)

    ClickButton.MouseLeave:Connect(function()
        ClickButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    end)

    ClickButton.MouseButton1Click:Connect(function()
        MarketplaceService:PromptGamePassPurchase(Player, 1418127686)
    end)

    ResetGui.Parent = Player:WaitForChild("PlayerGui")
end

local function CreateKeyGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(40, 40, 40)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar

    local BottomCover = Instance.new("Frame")
    BottomCover.Size = UDim2.new(1, 0, 0, 12)
    BottomCover.Position = UDim2.new(0, 0, 1, -12)
    BottomCover.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    BottomCover.BorderSizePixel = 0
    BottomCover.Parent = TopBar

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 35, 0, 35)
    Icon.Position = UDim2.new(0, 15, 0, 10)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🔐"
    Icon.TextSize = 28
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 28)
    Title.Position = UDim2.new(0, 55, 0, 6)
    Title.BackgroundTransparency = 1
    Title.Text = "Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -60, 0, 18)
    Subtitle.Position = UDim2.new(0, 55, 0, 30)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Enter your key to continue"
    Subtitle.TextColor3 = Color3.fromRGB(160, 160, 160)
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TopBar

    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(1, -40, 0, 18)
    InputLabel.Position = UDim2.new(0, 20, 0, 70)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = "License Key:"
    InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InputLabel.TextSize = 12
    InputLabel.Font = Enum.Font.GothamMedium
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Parent = MainFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -40, 0, 42)
    KeyInput.Position = UDim2.new(0, 20, 0, 92)
    KeyInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    KeyInput.BorderSizePixel = 0
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    KeyInput.TextSize = 13
    KeyInput.Font = Enum.Font.RobotoMono
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = MainFrame

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = KeyInput

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(40, 40, 40)
    InputStroke.Thickness = 1
    InputStroke.Parent = KeyInput

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 18)
    StatusLabel.Position = UDim2.new(0, 20, 0, 140)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(1, -40, 0, 42)
    SubmitButton.Position = UDim2.new(0, 20, 0, 165)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "Verify Key"
    SubmitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    SubmitButton.TextSize = 14
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = MainFrame

    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton

    SubmitButton.MouseEnter:Connect(function()
        SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)

    SubmitButton.MouseLeave:Connect(function()
        SubmitButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    end)

    local function AttemptValidation()
        local key = KeyInput.Text:upper():gsub("%s+", "")

        if key == "" then
            StatusLabel.Text = "⚠ Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            return
        end

        SubmitButton.Text = "Validating..."
        SubmitButton.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        task.wait(0.5)

        local success, message = ValidateKey(key)

        if success then
            StatusLabel.Text = "✓ " .. message
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            SubmitButton.Text = "Success!"
            SubmitButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)

            task.wait(1)
            ScreenGui:Destroy()

            LoadMainScript()
        else
            StatusLabel.Text = "✗ " .. message
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitButton.Text = "Try Again"
            SubmitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(1.5)
            SubmitButton.Text = "Verify Key"
            SubmitButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            SubmitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        end
    end

    SubmitButton.MouseButton1Click:Connect(AttemptValidation)

    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            AttemptValidation()
        end
    end)

    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    KeyInput:CaptureFocus()
end

local isHWIDMatch, matchedKey, matchedKeyName = CheckHWIDMatch()

if isHWIDMatch then
    local hwid = GetHWID()
    LogToDiscord(matchedKey, matchedKeyName, hwid, true, "Auto-loaded via HWID match")
    SendNotification("Key System", "✓ HWID recognized - Loading script automatically...", 3)
    LoadMainScript()
else
    SendNotification("Key System", "⚠ HWID not recognized - Please enter your key", 5)
    CreateKeyGUI()
    CreateHWIDResetGUI()
end
