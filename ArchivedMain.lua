local Players = game:GetService("Players") :: Players
local HttpService = game:GetService("HttpService") :: HttpService
local StarterGui = game:GetService("StarterGui") :: StarterGui
local Player = Players.LocalPlayer :: Player

local ValidKeys = {
    ["JSE6D598TSLKA4ERT89AERTHTFGAE56"] = {hwid = "EDB6D544-4C2F-4BC9-BCD4-266BC94809FE", name = "Mic's key"},
    ["K7X9M2QP8WN5VB1ZT4RHJ6YC2LD8PF3"] = {hwid = "6EB9C457-9FC8-4E0B-B90F-5C9DA551F5F8", name = "Fabi's key"},
    ["G4958ESRKTJ5H4RT09A45ETAW4RKTCV"] = {hwid = "E8DC9AAB-A48E-4C07-B17A-269865411193", name = "Zarc's key"},
    ["XMNB54389DFCGZDMBTWEE4RGFASEFLB"] = {hwid = "3587044F-092C-41D5-A61B-778D18618386", name = "Sembrell's key"},
    ["P9Q2N5W8R3T6Y1M4K7J0H2V5X8C3F6L"] = {hwid = "", name = "DustPuff's key"},
    ["90EALWRAWETVGAWSCVGPTAPW4903275"] = {hwid = "3F25698E-B36C-423A-A0AE-6EBE6AF77ADD", name = "Eshteme's key"},
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
end


