local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
	"Fragment Of Silence", "Fragment of Ruined Mirror Worlds", "Fused Blade of Ruined Mirror Worlds",
	"Seed Of Light", "Mirror Shard", "Rewound Time", "Glass Of Oblivion", "First Kindret Blood",
	"Manifested Armor Shard", "Secret Cookbook", "Borrowed Eye", "Meteorite Fragment",
	"Anklet of the Lake", "Degraded Lock", "Serum W Vial", "Serum R Vial", "Serum K Vial",
	"Fixer Glove", "Arbiter Essence", "Essence of Destruction", "Busted Clock",
	"Seeker's Nail", "Silencing glove", "Memorial Coffin", "Singularity",
}

local excludedItems = {
	"Wiring", "Broken Gauntlet", "Gun Parts", "Light Handle", "Heavy Handle", "Handle",
	"Office Manager", "Hammer Head", "Rope", "Low Quality Blade", "Scrap Metal",
	"Makeshift Handle", "Organs", "Gears", "Spices", "Cup Of Coffee",
	"Book Of a Grade 9 Fixer", "Book Of a Grade 7 Fixer", "Book Of Zwei Association",
	"Book Of Hana Association", "Book Of Shi Association", "Book Of Stray Dogs",
	"Focused Strikes", "Dodge and Strike", "Charge and Cover", "Thrust", "Light Attack",
	"Alleyway Counter", "Right Hook", "Opportunistic Slash", "Y-you Only Live Once",
	"Deep Cuts", "Mutilate", "Sky Kick", "Dropkick", "Backstreets Scramble",
	"You're Too Slow", "Stylish Sweeps", "Shocking Blow", "Crush", "Onslaught Command",
	"Preemptive Strike", "Fleet Footsteps", "Set Fire", "Blade Flourish", "Waltz in Black",
	"Waltz In White", "Light Dash", "Degraded Shockwave", "Scales of Judgement",
	"Destruction Awaits", "Client Protection", "Standoff", "Blade Whirl", "Law and Order",
	"Augury Crusher", "Augury Infusion", "Augury Kick", "Celestial Sight", "Catch Breath",
	"Extreme Edge", "Flying Sword", "Boundary Of Death", "Severing Flash", "Contre Attaque",
	"Engagement", "Balestra Fente", "Perfected Death Fist", "Raging Storm", "Fiery Waltz",
	"Red Kick", "Flowing Flame", "Ignite Weaponry", "Fleet Edge", "Flow of the Sword",
	"Dissect Target", "Moulinet", "Swash", "Investigation", "Weight Of Knowledge",
	"Illuminate Thy Vacuity", "Studious Dedication", "Scorch Knowledge", "Pistol Draw",
	"Coin Tricky", "Summary Judgement", "Re-Load", "Execute Prescript", "Somber Procuration",
	"Will of The City", "Proof of Loyalty", "Kicking", "Punching", "A Just Vengeance",
	"MY HAIR COUPOOOOOOONS!", "COMPLETE AND TOTAL EXTERMINATION!!!", "Vengeance Retaliation",
	"Sanguine Painting", "Hematic Coloring", "Paint Over", "Slash Series", "Overthrow",
	"Fare-Thee Well!", "Red Plum Blossoms Scatter", "Moon-Splitting Draw", "Yield My Flesh",
	"Sober Up", "Cloud Cutter", "Silent Mist", "Shadowcloud Kick", "Sky Clearing Cut",
	"Dark Cloud Cleaver", "Shadowcloud Shattercleave", "Inhale", "Exhale Smoke",
	"Loss of Senses", "Purify", "Cackle", "Rip", "Charge Shield", "Leap",
	"Overcharged Ripple", "Level Slash", "Upstanding Slash", "Onrush", "Spear",
	"Focus Spirit", "Lupine Onslaught", "Kicks and Stomps", "Rapacious Assault",
	"Pitch-Black Pulverizer", "Extract Fuel", "Trash Disposal", "Greatsword Rend",
	"Behead Heathcliffs", "Smackdown", "Grovel Before Me, Pathetic One", "Go… Go Away…!",
	"Siphon", "Topple", "Wound", "Hardblood Impact", "Suffocating Guilt",
	"Dark Gloom Vestige", "Faint Gloom Vestige", "Twinkling Gloom Vestige", "Brilliant Gloom Vestige", "Lunar Gloom Vestige",
	"Dark Gluttony Vestige", "Faint Gluttony Vestige", "Twinkling Gluttony Vestige", "Brilliant Gluttony Vestige", "Lunar Gluttony Vestige",
	"Dark Desire Vestige", "Faint Desire Vestige", "Twinkling Desire Vestige", "Brilliant Desire Vestige", "Lunar Desire Vestige",
	"Dark Sloth Vestige", "Faint Sloth Vestige", "Twinkling Sloth Vestige", "Brilliant Sloth Vestige", "Lunar Sloth Vestige",
	"Dark Envy Vestige", "Faint Envy Vestige", "Twinkling Envy Vestige", "Brilliant Envy Vestige", "Lunar Envy Vestige",
	"Dark Pride Vestige", "Faint Pride Vestige", "Twinkling Pride Vestige", "Brilliant Pride Vestige", "Lunar Pride Vestige",
}

local P  = Color3.fromRGB(93, 63, 211)
local PD = Color3.fromRGB(68, 46, 158)
local PK = Color3.fromRGB(22, 14, 52)
local B0 = Color3.fromRGB(0, 0, 0)
local B1 = Color3.fromRGB(7, 7, 10)
local B2 = Color3.fromRGB(11, 11, 16)
local B3 = Color3.fromRGB(16, 16, 22)
local B4 = Color3.fromRGB(22, 22, 30)
local W  = Color3.fromRGB(255, 255, 255)
local W1 = Color3.fromRGB(185, 185, 200)
local W2 = Color3.fromRGB(110, 110, 130)

local function mkCorner(r, p) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p end
local function mkStroke(col, th, tr, p) local s = Instance.new("UIStroke") s.Color = col s.Thickness = th s.Transparency = tr s.Parent = p end
local function mkGrad(c0, c1, rot, p) local g = Instance.new("UIGradient") g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c0), ColorSequenceKeypoint.new(1, c1)}) g.Rotation = rot g.Parent = p end

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "SingularityNotifs"
notifGui.ResetOnSpawn = false
notifGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 300, 1, 0)
notifContainer.Position = UDim2.new(1, -316, 0, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = notifGui

local nLayout = Instance.new("UIListLayout")
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.Padding = UDim.new(0, 10)
nLayout.Parent = notifContainer

local nPad = Instance.new("UIPadding")
nPad.PaddingBottom = UDim.new(0, 24)
nPad.Parent = notifContainer

local notifOrder = 0

local function fireNotification(player)
	notifOrder += 1
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = B1
	card.BorderSizePixel = 0
	card.LayoutOrder = notifOrder
	card.Position = UDim2.new(1, 20, 0, 0)
	card.ClipsDescendants = true
	card.Parent = notifContainer
	mkCorner(12, card)
	mkGrad(B2, PK, 135, card)
	mkStroke(P, 1, 0.55, card)

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 4, 0.7, 0)
	pill.Position = UDim2.new(0, 0, 0.15, 0)
	pill.BackgroundColor3 = P
	pill.BorderSizePixel = 0
	pill.Parent = card
	mkCorner(4, pill)

	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 36, 0, 36)
	iconBg.Position = UDim2.new(0, 14, 0.5, -18)
	iconBg.BackgroundColor3 = PK
	iconBg.BorderSizePixel = 0
	iconBg.Parent = card
	mkCorner(8, iconBg)
	mkStroke(P, 1, 0.4, iconBg)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "!"
	iconLabel.TextColor3 = P
	iconLabel.TextSize = 18
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = iconBg

	local topLine = Instance.new("TextLabel")
	topLine.Size = UDim2.new(1, -62, 0, 24)
	topLine.Position = UDim2.new(0, 58, 0, 12)
	topLine.BackgroundTransparency = 1
	topLine.Text = player.DisplayName
	topLine.TextColor3 = W
	topLine.TextSize = 14
	topLine.Font = Enum.Font.GothamBold
	topLine.TextXAlignment = Enum.TextXAlignment.Left
	topLine.TextTruncate = Enum.TextTruncate.AtEnd
	topLine.Parent = card

	local subLine = Instance.new("TextLabel")
	subLine.Size = UDim2.new(1, -62, 0, 18)
	subLine.Position = UDim2.new(0, 58, 0, 36)
	subLine.BackgroundTransparency = 1
	subLine.Text = "@" .. player.Name .. "  ·  Singularity Extractor"
	subLine.TextColor3 = W1
	subLine.TextSize = 11
	subLine.Font = Enum.Font.Gotham
	subLine.TextXAlignment = Enum.TextXAlignment.Left
	subLine.TextTruncate = Enum.TextTruncate.AtEnd
	subLine.Parent = card

	local tagFrame = Instance.new("Frame")
	tagFrame.Size = UDim2.new(0, 46, 0, 16)
	tagFrame.Position = UDim2.new(0, 58, 0, 56)
	tagFrame.BackgroundColor3 = PD
	tagFrame.BorderSizePixel = 0
	tagFrame.Parent = card
	mkCorner(4, tagFrame)

	local tagLabel = Instance.new("TextLabel")
	tagLabel.Size = UDim2.new(1, 0, 1, 0)
	tagLabel.BackgroundTransparency = 1
	tagLabel.Text = "ALERT"
	tagLabel.TextColor3 = W
	tagLabel.TextSize = 9
	tagLabel.Font = Enum.Font.GothamBold
	tagLabel.Parent = tagFrame

	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	task.delay(6, function()
		if card and card.Parent then
			local out = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, 0)})
			out:Play()
			out.Completed:Connect(function() card:Destroy() end)
		end
	end)
end

local function hasSingularityExtractor(player)
	if not player:FindFirstChild("Backpack") then return false end
	for _, item in pairs(player.Backpack:GetChildren()) do
		if string.lower(item.Name) == "singularity extractor" then return true end
	end
	return false
end

local function isFilteredItem(n)
	local l = string.lower(n)
	for _, v in pairs(filteredItems) do if l == string.lower(v) then return true end end
	return false
end

local function isExcludedItem(n)
	local l = string.lower(n)
	for _, v in pairs(excludedItems) do if l == string.lower(v) then return true end end
	return false
end

local function createESP(player)
	if espConnections[player.Name] then return end
	local function buildGui()
		if not player.Character or not player.Character:FindFirstChild("Head") then return end
		local bg = Instance.new("BillboardGui")
		bg.Name = "ESP_" .. player.Name
		bg.Parent = player.Character.Head
		bg.Size = UDim2.new(0, 200, 0, 50)
		bg.StudsOffset = Vector3.new(0, 2, 0)
		bg.AlwaysOnTop = true
		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1, 0, 0.5, 0)
		nl.BackgroundTransparency = 1
		nl.Text = player.Name
		nl.TextColor3 = P
		nl.TextSize = 16
		nl.Font = Enum.Font.GothamBold
		nl.TextStrokeTransparency = 0
		nl.TextStrokeColor3 = B0
		nl.Parent = bg
		local hl = Instance.new("TextLabel")
		hl.Size = UDim2.new(1, 0, 0.5, 0)
		hl.Position = UDim2.new(0, 0, 0.5, 0)
		hl.BackgroundTransparency = 1
		hl.TextColor3 = W
		hl.TextSize = 14
		hl.Font = Enum.Font.Gotham
		hl.TextStrokeTransparency = 0
		hl.TextStrokeColor3 = B0
		hl.Parent = bg
		local function upd()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local h = player.Character.Humanoid
				hl.Text = math.floor(h.Health) .. " / " .. math.floor(h.MaxHealth)
			end
		end
		upd()
		local hc = RunService.Heartbeat:Connect(upd)
		return bg, hc
	end
	local eg, hc = buildGui()
	local cc = player.CharacterAdded:Connect(function()
		if eg then eg:Destroy() end
		if hc then hc:Disconnect() end
		wait(1)
		eg, hc = buildGui()
	end)
	espConnections[player.Name] = {charConnection = cc, hpConnection = hc, espGui = eg}
end

local function removeESP(player)
	if not espConnections[player.Name] then return end
	local c = espConnections[player.Name]
	if c.charConnection then c.charConnection:Disconnect() end
	if c.hpConnection then c.hpConnection:Disconnect() end
	if c.espGui then c.espGui:Destroy() end
	espConnections[player.Name] = nil
end

local function stopViewing()
	viewing = nil
	if viewDied then viewDied:Disconnect() viewDied = nil end
	if viewChanged then viewChanged:Disconnect() viewChanged = nil end
	workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
end

local function startViewing(player)
	stopViewing()
	if not player.Character then return end
	viewing = player
	workspace.CurrentCamera.CameraSubject = player.Character
	viewDied = player.CharacterAdded:Connect(function()
		repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if viewing == player then workspace.CurrentCamera.CameraSubject = player.Character end
	end)
	viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		if viewing == player and player.Character then
			workspace.CurrentCamera.CameraSubject = player.Character
		end
	end)
end

local function getPlayerStats(player)
	local stats = {Ahn = 0, Singularity = 0}
	local pd = Players:FindFirstChild(player.Name)
	if pd and pd:FindFirstChild("Data") then
		local d = pd.Data
		if d:FindFirstChild("Ahn") then stats.Ahn = d.Ahn.Value or 0 end
		if d:FindFirstChild("Singularity") then stats.Singularity = d.Singularity.Value or 0 end
	end
	return stats
end

local function countFilteredItems(player)
	if not player:FindFirstChild("Backpack") then return 0 end
	local count = 0
	for _, item in pairs(player.Backpack:GetChildren()) do
		if isFilteredItem(item.Name) then count += 1 end
	end
	return count
end

local function countAllItems(player)
	if not player:FindFirstChild("Backpack") then return 0 end
	local count = 0
	for _, item in pairs(player.Backpack:GetChildren()) do
		if not isExcludedItem(item.Name) then count += 1 end
	end
	return count
end

local function scanPlayerBackpack(player, useFilter)
	if specialPlayers[player.Name] then return "[CLASSIFIED]", {Ahn = "███████", Singularity = "███████"} end
	if not player:FindFirstChild("Backpack") then return "", getPlayerStats(player) end
	local counts, list = {}, {}
	for _, item in pairs(player.Backpack:GetChildren()) do
		local pass = useFilter and isFilteredItem(item.Name) or (not useFilter and not isExcludedItem(item.Name))
		if pass then counts[item.Name] = (counts[item.Name] or 0) + 1 end
	end
	for name, count in pairs(counts) do
		table.insert(list, count > 1 and name .. " x" .. count or name)
	end
	return table.concat(list, ", "), getPlayerStats(player)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackpackScannerGUI"
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 860, 0, 600)
main.Position = UDim2.new(0.5, -430, 0.5, -300)
main.BackgroundColor3 = B1
main.BorderSizePixel = 0
main.Parent = screenGui
mkCorner(16, main)
mkGrad(B1, B0, 160, main)
mkStroke(P, 1, 0.6, main)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = B0
sidebar.BorderSizePixel = 0
sidebar.Parent = main
mkCorner(16, sidebar)
mkGrad(B1, B0, 180, sidebar)
mkStroke(P, 1, 0.75, sidebar)

local sidebarFill = Instance.new("Frame")
sidebarFill.Size = UDim2.new(0, 20, 1, 0)
sidebarFill.Position = UDim2.new(1, -20, 0, 0)
sidebarFill.BackgroundColor3 = B0
sidebarFill.BorderSizePixel = 0
sidebarFill.Parent = sidebar

local logoBlock = Instance.new("Frame")
logoBlock.Size = UDim2.new(1, 0, 0, 70)
logoBlock.BackgroundTransparency = 1
logoBlock.Parent = sidebar

local logoDot = Instance.new("Frame")
logoDot.Size = UDim2.new(0, 10, 0, 10)
logoDot.Position = UDim2.new(0, 18, 0.5, -5)
logoDot.BackgroundColor3 = P
logoDot.BorderSizePixel = 0
logoDot.Parent = logoBlock
mkCorner(99, logoDot)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -40, 1, 0)
logoText.Position = UDim2.new(0, 36, 0, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "Scanner"
logoText.TextColor3 = W
logoText.TextSize = 16
logoText.Font = Enum.Font.GothamBold
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = logoBlock

local logoDivider = Instance.new("Frame")
logoDivider.Size = UDim2.new(0, 140, 0, 1)
logoDivider.Position = UDim2.new(0, 20, 0, 68)
logoDivider.BackgroundColor3 = P
logoDivider.BackgroundTransparency = 0.7
logoDivider.BorderSizePixel = 0
logoDivider.Parent = sidebar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 160)
tabContainer.Position = UDim2.new(0, 0, 0, 78)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sidebar

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 4)
tabListLayout.Parent = tabContainer

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 12)
tabPad.PaddingRight = UDim.new(0, 12)
tabPad.Parent = tabContainer

local function makeSideTab(label, icon, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 44)
	btn.BackgroundColor3 = B2
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.LayoutOrder = order
	btn.Parent = tabContainer
	mkCorner(10, btn)

	local iconL = Instance.new("TextLabel")
	iconL.Size = UDim2.new(0, 22, 0, 22)
	iconL.Position = UDim2.new(0, 12, 0.5, -11)
	iconL.BackgroundTransparency = 1
	iconL.Text = icon
	iconL.TextColor3 = W2
	iconL.TextSize = 14
	iconL.Font = Enum.Font.GothamBold
	iconL.Parent = btn

	local textL = Instance.new("TextLabel")
	textL.Size = UDim2.new(1, -44, 1, 0)
	textL.Position = UDim2.new(0, 40, 0, 0)
	textL.BackgroundTransparency = 1
	textL.Text = label
	textL.TextColor3 = W2
	textL.TextSize = 13
	textL.Font = Enum.Font.GothamBold
	textL.TextXAlignment = Enum.TextXAlignment.Left
	textL.Parent = btn

	local activePill = Instance.new("Frame")
	activePill.Size = UDim2.new(0, 3, 0.55, 0)
	activePill.Position = UDim2.new(0, 0, 0.225, 0)
	activePill.BackgroundColor3 = P
	activePill.BorderSizePixel = 0
	activePill.Transparency = 1
	activePill.Parent = btn
	mkCorner(4, activePill)

	return btn, iconL, textL, activePill
end

local filteredBtn, filteredIcon, filteredText, filteredPill = makeSideTab("Rare", "◈", 1)
local fullBtn, fullIcon, fullText, fullPill = makeSideTab("Full Inv", "▦", 2)
local ahnBtn, ahnIcon, ahnText, ahnPill = makeSideTab("Ahn", "◆", 3)

local allTabs = {
	{filteredBtn, filteredIcon, filteredText, filteredPill},
	{fullBtn, fullIcon, fullText, fullPill},
	{ahnBtn, ahnIcon, ahnText, ahnPill},
}

local function setActiveTab(activeBtn)
	for _, t in pairs(allTabs) do
		local btn, icon, txt, pill = t[1], t[2], t[3], t[4]
		if btn == activeBtn then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = PK}):Play()
			TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = P}):Play()
			TweenService:Create(txt, TweenInfo.new(0.2), {TextColor3 = W}):Play()
			pill.Transparency = 0
		else
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = W2}):Play()
			TweenService:Create(txt, TweenInfo.new(0.2), {TextColor3 = W2}):Play()
			pill.Transparency = 1
		end
	end
end

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0, 14, 1, -50)
closeBtn.BackgroundColor3 = PK
closeBtn.Text = "✕"
closeBtn.TextColor3 = W1
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = sidebar
mkCorner(8, closeBtn)
mkStroke(P, 1, 0.5, closeBtn)

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -192, 1, -24)
rightPanel.Position = UDim2.new(0, 192, 0, 12)
rightPanel.BackgroundColor3 = B2
rightPanel.BorderSizePixel = 0
rightPanel.Parent = main
mkCorner(12, rightPanel)
mkStroke(P, 1, 0.75, rightPanel)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundColor3 = B3
topBar.BorderSizePixel = 0
topBar.Parent = rightPanel
mkCorner(12, topBar)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 20)
topBarFix.Position = UDim2.new(0, 0, 1, -20)
topBarFix.BackgroundColor3 = B3
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local topDivider = Instance.new("Frame")
topDivider.Size = UDim2.new(1, -24, 0, 1)
topDivider.Position = UDim2.new(0, 12, 1, -1)
topDivider.BackgroundColor3 = P
topDivider.BackgroundTransparency = 0.75
topDivider.BorderSizePixel = 0
topDivider.Parent = topBar

local pageTitle = Instance.new("TextLabel")
pageTitle.Size = UDim2.new(1, -80, 1, 0)
pageTitle.Position = UDim2.new(0, 18, 0, 0)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Rare Items"
pageTitle.TextColor3 = W
pageTitle.TextSize = 16
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = topBar

local countBadge = Instance.new("Frame")
countBadge.Size = UDim2.new(0, 36, 0, 22)
countBadge.Position = UDim2.new(1, -48, 0.5, -11)
countBadge.BackgroundColor3 = PD
countBadge.BorderSizePixel = 0
countBadge.Parent = topBar
mkCorner(6, countBadge)

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, 0, 1, 0)
countLabel.BackgroundTransparency = 1
countLabel.Text = "0"
countLabel.TextColor3 = W
countLabel.TextSize = 12
countLabel.Font = Enum.Font.GothamBold
countLabel.Parent = countBadge

local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, -24, 1, -68)
listContainer.Position = UDim2.new(0, 12, 0, 58)
listContainer.BackgroundTransparency = 1
listContainer.Parent = rightPanel

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = PD
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = listContainer

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingBottom = UDim.new(0, 8)
listPad.Parent = scroll

local currentTab = "filtered"

local function refreshCanvas()
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
end

local function updateViewButtons()
	for _, frame in pairs(playerFrames) do
		if frame and frame.Parent and frame:FindFirstChild("ViewButton") then
			local vb = frame.ViewButton
			local pl = Players:FindFirstChild(frame.Name:sub(13))
			if pl then
				if viewing == pl then
					vb.Text = "Unview"
					vb.BackgroundColor3 = PD
				else
					vb.Text = "View"
					vb.BackgroundColor3 = Color3.fromRGB(45, 30, 100)
				end
			end
		end
	end
end

local function createPlayerEntry(player, items, stats, rank)
	local isSpecial = specialPlayers[player.Name] ~= nil

	local card = Instance.new("Frame")
	card.Name = "PlayerFrame_" .. player.Name
	card.Size = UDim2.new(1, -4, 0, 80)
	card.BackgroundColor3 = B3
	card.BorderSizePixel = 0
	card.LayoutOrder = rank or 0
	card.Parent = scroll
	mkCorner(10, card)
	mkGrad(B3, B4, 135, card)
	mkStroke(P, 1, 0.82, card)

	local leftAccent = Instance.new("Frame")
	leftAccent.Size = UDim2.new(0, 3, 0.6, 0)
	leftAccent.Position = UDim2.new(0, 0, 0.2, 0)
	leftAccent.BackgroundColor3 = isSpecial and Color3.fromRGB(200, 60, 60) or P
	leftAccent.BorderSizePixel = 0
	leftAccent.Parent = card
	mkCorner(4, leftAccent)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.38, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 16, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = isSpecial and (player.Name .. " — " .. specialPlayers[player.Name].note) or player.Name
	nameLabel.TextColor3 = isSpecial and Color3.fromRGB(220, 100, 100) or W
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = card

	local statsRow = Instance.new("TextLabel")
	statsRow.Size = UDim2.new(0.38, 0, 0, 18)
	statsRow.Position = UDim2.new(0, 16, 0, 38)
	statsRow.BackgroundTransparency = 1
	local isRedacted = type(stats.Ahn) == "string" and stats.Ahn == "███████"
	if isRedacted then
		statsRow.Text = "Ahn ███  ·  Sing ███"
	elseif currentTab == "ahn" then
		statsRow.Text = "Ahn  " .. (stats.Ahn or 0)
	else
		statsRow.Text = "Ahn  " .. (stats.Ahn or 0) .. "   ·   Sing  " .. (stats.Singularity or 0)
	end
	statsRow.TextColor3 = W2
	statsRow.TextSize = 11
	statsRow.Font = Enum.Font.Gotham
	statsRow.TextXAlignment = Enum.TextXAlignment.Left
	statsRow.Parent = card

	if currentTab ~= "ahn" then
		local itemDivider = Instance.new("Frame")
		itemDivider.Size = UDim2.new(0, 1, 0.55, 0)
		itemDivider.Position = UDim2.new(0.44, 0, 0.225, 0)
		itemDivider.BackgroundColor3 = P
		itemDivider.BackgroundTransparency = 0.8
		itemDivider.BorderSizePixel = 0
		itemDivider.Parent = card

		local itemsLabel = Instance.new("TextLabel")
		itemsLabel.Size = UDim2.new(0.52, -8, 1, -16)
		itemsLabel.Position = UDim2.new(0.45, 8, 0, 8)
		itemsLabel.BackgroundTransparency = 1
		itemsLabel.Text = (items == "" or items == nil) and "—" or items
		itemsLabel.TextColor3 = items == "" and W2 or W1
		itemsLabel.TextSize = 11
		itemsLabel.Font = Enum.Font.Gotham
		itemsLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemsLabel.TextYAlignment = Enum.TextYAlignment.Center
		itemsLabel.TextWrapped = true
		itemsLabel.Parent = card
	end

	if not isSpecial then
		local viewBtn = Instance.new("TextButton")
		viewBtn.Name = "ViewButton"
		viewBtn.Size = UDim2.new(0, 64, 0, 24)
		viewBtn.Position = UDim2.new(1, -142, 0.5, -12)
		viewBtn.BackgroundColor3 = viewing == player and PD or Color3.fromRGB(45, 30, 100)
		viewBtn.Text = viewing == player and "Unview" or "View"
		viewBtn.TextColor3 = W
		viewBtn.TextSize = 11
		viewBtn.Font = Enum.Font.GothamBold
		viewBtn.BorderSizePixel = 0
		viewBtn.Parent = card
		mkCorner(6, viewBtn)
		mkStroke(P, 1, 0.45, viewBtn)

		local espBtn = Instance.new("TextButton")
		espBtn.Size = UDim2.new(0, 64, 0, 24)
		espBtn.Position = UDim2.new(1, -70, 0.5, -12)
		espBtn.BackgroundColor3 = espConnections[player.Name] and PD or PK
		espBtn.Text = espConnections[player.Name] and "UnESP" or "ESP"
		espBtn.TextColor3 = W
		espBtn.TextSize = 11
		espBtn.Font = Enum.Font.GothamBold
		espBtn.BorderSizePixel = 0
		espBtn.Parent = card
		mkCorner(6, espBtn)
		mkStroke(P, 1, 0.45, espBtn)

		viewBtn.MouseButton1Click:Connect(function()
			if viewing == player then stopViewing() else startViewing(player) end
			updateViewButtons()
		end)

		espBtn.MouseButton1Click:Connect(function()
			if espConnections[player.Name] then
				removeESP(player)
				espBtn.Text = "ESP"
				espBtn.BackgroundColor3 = PK
			else
				createESP(player)
				espBtn.Text = "UnESP"
				espBtn.BackgroundColor3 = PD
			end
		end)
	end

	playerFrames[player.Name] = card
	return card
end

local function updateDisplay()
	for _, c in pairs(scroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	playerFrames = {}

	local dataList = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer then
			local items, stats = scanPlayerBackpack(player, currentTab == "filtered")
			local sortValue = 0
			if currentTab == "filtered" then
				sortValue = countFilteredItems(player)
			elseif currentTab == "full" then
				sortValue = countAllItems(player)
			elseif currentTab == "ahn" then
				sortValue = type(stats.Ahn) == "number" and stats.Ahn or 0
			end
			table.insert(dataList, {player = player, items = items, stats = stats, sortValue = sortValue})
		end
	end

	table.sort(dataList, function(a, b) return a.sortValue > b.sortValue end)

	local count = 0
	for rank, data in ipairs(dataList) do
		if currentTab == "filtered" and data.sortValue == 0 then continue end
		if currentTab ~= "full" or data.items ~= "" or currentTab == "full" then
			createPlayerEntry(data.player, data.items, data.stats, rank)
			count += 1
		end
	end

	countLabel.Text = tostring(count)
	refreshCanvas()
end

setActiveTab(filteredBtn)

filteredBtn.MouseButton1Click:Connect(function()
	currentTab = "filtered"
	pageTitle.Text = "Rare Items"
	setActiveTab(filteredBtn)
	updateDisplay()
end)

fullBtn.MouseButton1Click:Connect(function()
	currentTab = "full"
	pageTitle.Text = "Full Inventory"
	setActiveTab(fullBtn)
	updateDisplay()
end)

ahnBtn.MouseButton1Click:Connect(function()
	currentTab = "ahn"
	pageTitle.Text = "Ahn Ranking"
	setActiveTab(ahnBtn)
	updateDisplay()
end)

closeBtn.MouseButton1Click:Connect(function()
	if viewing then stopViewing() end
	for name, _ in pairs(espConnections) do
		local pl = Players:FindFirstChild(name)
		if pl then removeESP(pl) end
	end
	screenGui:Destroy()
end)

local dragging, dragStart, startPos = false, nil, nil

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

spawn(function()
	while screenGui.Parent do
		updateDisplay()
		wait(2)
	end
end)

local alreadyNotified = {}

spawn(function()
	while screenGui.Parent do
		local currentNotified = {}
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= Players.LocalPlayer and not specialPlayers[player.Name] then
				if hasSingularityExtractor(player) then
					currentNotified[player.Name] = true
					if not alreadyNotified[player.Name] then
						alreadyNotified[player.Name] = true
						fireNotification(player)
					end
				end
			end
		end
		for name, _ in pairs(alreadyNotified) do
			if not currentNotified[name] then alreadyNotified[name] = nil end
		end
		wait(5)
	end
end)

updateDisplay()
wait(0.5)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

local scanResults = {}

for _, player in pairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		if player:FindFirstChild("Backpack") then
			local itemCount = 0
			for _, item in pairs(player.Backpack:GetChildren()) do
				if string.lower(item.Name) == string.lower("Singularity Extractor") then
					itemCount += 1
				end
			end
			if itemCount > 0 then
				table.insert(scanResults, {player = player, count = itemCount})
			end
		end
	end
end

local cardHeight = 70 + (#scanResults > 0 and (#scanResults * 28) or 28)

local extractorGui = Instance.new("ScreenGui")
extractorGui.Name = "ExtractorScanNotif"
extractorGui.ResetOnSpawn = false
extractorGui.Parent = localPlayer:WaitForChild("PlayerGui")

local notifCard = Instance.new("Frame")
notifCard.Size = UDim2.new(0, 300, 0, cardHeight)
notifCard.Position = UDim2.new(1, 10, 0.5, -(cardHeight / 2))
notifCard.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notifCard.BorderSizePixel = 0
notifCard.ClipsDescendants = true
notifCard.Parent = extractorGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 12)
notifCorner.Parent = notifCard

local notifGradient = Instance.new("UIGradient")
notifGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(93, 63, 211))
})
notifGradient.Rotation = 135
notifGradient.Parent = notifCard

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(93, 63, 211)
accentBar.BorderSizePixel = 0
accentBar.Parent = notifCard

local accentBarCorner = Instance.new("UICorner")
accentBarCorner.CornerRadius = UDim.new(0, 4)
accentBarCorner.Parent = accentBar

local notifTitle = Instance.new("TextLabel")
notifTitle.Size = UDim2.new(1, -55, 0, 30)
notifTitle.Position = UDim2.new(0, 16, 0, 10)
notifTitle.BackgroundTransparency = 1
notifTitle.Text = "Extractor Scanner"
notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
notifTitle.TextSize = 14
notifTitle.Font = Enum.Font.GothamBold
notifTitle.TextXAlignment = Enum.TextXAlignment.Left
notifTitle.Parent = notifCard

local notifCloseBtn = Instance.new("TextButton")
notifCloseBtn.Size = UDim2.new(0, 28, 0, 28)
notifCloseBtn.Position = UDim2.new(1, -36, 0, 8)
notifCloseBtn.BackgroundColor3 = Color3.fromRGB(93, 63, 211)
notifCloseBtn.Text = "×"
notifCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
notifCloseBtn.TextSize = 18
notifCloseBtn.Font = Enum.Font.GothamBold
notifCloseBtn.BorderSizePixel = 0
notifCloseBtn.Parent = notifCard

local notifCloseBtnCorner = Instance.new("UICorner")
notifCloseBtnCorner.CornerRadius = UDim.new(0, 6)
notifCloseBtnCorner.Parent = notifCloseBtn

local notifDivider = Instance.new("Frame")
notifDivider.Size = UDim2.new(1, -20, 0, 1)
notifDivider.Position = UDim2.new(0, 10, 0, 44)
notifDivider.BackgroundColor3 = Color3.fromRGB(93, 63, 211)
notifDivider.BorderSizePixel = 0
notifDivider.Parent = notifCard

if #scanResults == 0 then
	local noResultsLabel = Instance.new("TextLabel")
	noResultsLabel.Size = UDim2.new(1, -20, 0, 28)
	noResultsLabel.Position = UDim2.new(0, 16, 0, 50)
	noResultsLabel.BackgroundTransparency = 1
	noResultsLabel.Text = "No players have the singularity extractor."
	noResultsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	noResultsLabel.TextSize = 13
	noResultsLabel.Font = Enum.Font.Gotham
	noResultsLabel.TextXAlignment = Enum.TextXAlignment.Left
	noResultsLabel.Parent = notifCard
else
	for i, data in ipairs(scanResults) do
		local resultRow = Instance.new("TextLabel")
		resultRow.Size = UDim2.new(1, -20, 0, 24)
		resultRow.Position = UDim2.new(0, 16, 0, 46 + (i * 26))
		resultRow.BackgroundTransparency = 1
		resultRow.Text = "• " .. data.player.Name .. "  —  x" .. data.count
		resultRow.TextColor3 = Color3.fromRGB(255, 255, 255)
		resultRow.TextSize = 13
		resultRow.Font = Enum.Font.Gotham
		resultRow.TextXAlignment = Enum.TextXAlignment.Left
		resultRow.Parent = notifCard
	end
end

local slideIn = TweenService:Create(notifCard, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
	Position = UDim2.new(1, -315, 0.5, -(cardHeight / 2))
})
slideIn:Play()

local function dismissNotif()
	if notifCard and notifCard.Parent then
		local slideOut = TweenService:Create(notifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 10, 0.5, -(cardHeight / 2))
		})
		slideOut:Play()
		slideOut.Completed:Connect(function()
			extractorGui:Destroy()
		end)
	end
end

notifCloseBtn.MouseButton1Click:Connect(dismissNotif)

task.delay(8, dismissNotif)
