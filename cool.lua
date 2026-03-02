local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local guiName = "EliteDiddyCheatGUI"
if player.PlayerGui:FindFirstChild(guiName) then
	player.PlayerGui[guiName]:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 2147483647
gui.Parent = player:WaitForChild("PlayerGui")

local remoteBlacklist = {
	"PlayEmote", "SendNotificationInfo", "GetServerVersion", "GetServerChannel", "WhisperChat",
	"GetServerType", "CanChatWith", "SetPlayerBlockList", "UpdatePlayerBlockList", "NewPlayerGroupDetails",
	"NewPlayerCanManageDetails", "SendPlayerBlockList", "UpdateLocalPlayerBlockList", "SendPlayerProfileSettings",
	"RequestPlayerProfileSettings", "UpdatePlayerProfileSettings", "ShowPlayerJoinedFriendsToast",
	"ShowFriendJoinedPlayerToast", "CreateOrJoinParty", "ServerSideBulkPurchaseEvent", "SetDialogInUse",
	"ContactListInvokeIrisInvite", "UpdateCurrentCall", "RequestDeviceCameraOrientationCapability",
	"ReferredPlayerJoin", "ContactListIrisInviteTeleport",
	"IntegrityCheckProcessorKey2_DynamicTranslationSender_LocalizationService",
	"IntegrityCheckProcessorKey2_LocalizationTableAnalyticsSender_LocalizationService", "ServerControl", "ClientControl",
}

local function isBlacklisted(name)
	name = name:lower()
	for _, word in ipairs(remoteBlacklist) do
		if name:find(word:lower(), 1, true) then return true end
	end
	return false
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0.38, 0, 0.75, 0)
main.Position = UDim2.new(0.31, 0, -1, 0)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(70, 110, 200)
stroke.Thickness = 1.5
stroke.Transparency = 0.3

local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

-- Title text (left side)
local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0.02, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DIDDY CHEATS V6.7"
title.TextColor3 = Color3.fromRGB(225, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left

-- Local player info INSIDE title bar (right side)
local playerThumb = Instance.new("ImageLabel", titleBar)
playerThumb.Size = UDim2.new(0, 36, 0, 36)
playerThumb.Position = UDim2.new(1, -140, 0.5, -18)
playerThumb.BackgroundTransparency = 1
playerThumb.ScaleType = Enum.ScaleType.Fit
Instance.new("UICorner", playerThumb).CornerRadius = UDim.new(1, 0)

local playerNameLabel = Instance.new("TextLabel", titleBar)
playerNameLabel.Size = UDim2.new(0, 120, 1, 0)
playerNameLabel.Position = UDim2.new(1, -100, 0, 0)
playerNameLabel.BackgroundTransparency = 1
playerNameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
playerNameLabel.Font = Enum.Font.GothamSemibold
playerNameLabel.TextSize = 15
playerNameLabel.TextXAlignment = Enum.TextXAlignment.Right
playerNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

local function updatePlayerInfo()
	playerNameLabel.Text = player.DisplayName .. "  @" .. player.Name
	local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	if isReady then
		playerThumb.Image = content
	end
end

updatePlayerInfo()
player:GetPropertyChangedSignal("Character"):Connect(updatePlayerInfo)

local status = Instance.new("TextLabel", titleBar)
status.Size = UDim2.new(0.25, 0, 1, 0)
status.Position = UDim2.new(0.52, 0, 0, 0)
status.BackgroundTransparency = 1
status.Text = "Initializing..."
status.TextColor3 = Color3.fromRGB(170, 220, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 15
status.TextXAlignment = Enum.TextXAlignment.Right

local function setStatus(msg)
	if status and status:IsDescendantOf(player.PlayerGui) then
		status.Text = tostring(msg or "—")
	end
end

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 34, 0, 34)
minBtn.Position = UDim2.new(1, -42, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 22
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 9)

-- Dragging
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, 0, 0, 46)
tabBar.Position = UDim2.new(0, 0, 0, 48)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 28, 44)

local tabButtons = {}
local tabs = {"Remotes", "Cheats", "Players"}
local tabFrames = {}
local currentTab = "Remotes"

-- ================================================
-- PLAYER TAB (only thumbnail + name + username)
-- ================================================

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -94)
content.Position = UDim2.new(0, 0, 0, 94)
content.BackgroundTransparency = 1

local playersTab = Instance.new("Frame", content)
playersTab.Size = UDim2.new(1, 0, 1, 0)
playersTab.BackgroundTransparency = 1
playersTab.Visible = false
tabFrames.Players = playersTab

local playersScroll = Instance.new("ScrollingFrame", playersTab)
playersScroll.Size = UDim2.new(1, -20, 1, -20)
playersScroll.Position = UDim2.new(0, 10, 0, 10)
playersScroll.BackgroundTransparency = 1
playersScroll.ScrollBarThickness = 4
playersScroll.ScrollBarImageColor3 = Color3.fromRGB(90, 140, 230)

local playersLayout = Instance.new("UIListLayout", playersScroll)
playersLayout.Padding = UDim.new(0, 8)
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	playersScroll.CanvasSize = UDim2.fromOffset(0, playersLayout.AbsoluteContentSize.Y + 30)
end)

local currentSpectate = nil

local function teleportToPlayer(name)
	name = name:lower()
	local target
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
			target = p
			break
		end
	end
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 4, 0)
			setStatus("Teleported to " .. target.Name)
		end
	else
		setStatus("Player not found")
	end
end

local function spectatePlayer(name)
	name = name:lower()
	if currentSpectate and currentSpectate:lower() == name then
		camera.CameraSubject = player.Character and (player.Character:FindFirstChild("Humanoid") or player.Character.PrimaryPart)
		setStatus("Spectate stopped")
		currentSpectate = nil
		return
	end
	local target
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
			target = p
			break
		end
	end
	if target and target.Character then
		camera.CameraSubject = target.Character:FindFirstChild("Humanoid") or target.Character.PrimaryPart
		setStatus("Spectating " .. target.Name)
		currentSpectate = target.Name:lower()
	else
		setStatus("Player not found")
	end
end

local function refreshPlayerList()
	if not playersScroll or not playersScroll:IsDescendantOf(gui) then return end
	for _, child in ipairs(playersScroll:GetChildren()) do
		if child:IsA("Frame") or child:IsA("GuiObject") then child:Destroy() end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player then continue end

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 50)
		row.BackgroundTransparency = 1
		row.Parent = playersScroll

		local thumb = Instance.new("ImageLabel")
		thumb.Size = UDim2.new(0, 44, 0, 44)
		thumb.Position = UDim2.new(0, 8, 0.5, -22)
		thumb.BackgroundTransparency = 1
		thumb.ScaleType = Enum.ScaleType.Fit
		local content, isReady = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		if isReady then thumb.Image = content end
		thumb.Parent = row
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

		local nameLbl = Instance.new("TextLabel", row)
		nameLbl.Size = UDim2.new(1, -130, 1, 0)
		nameLbl.Position = UDim2.new(0, 60, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
		nameLbl.TextColor3 = Color3.fromRGB(220, 240, 255)
		nameLbl.Font = Enum.Font.GothamSemibold
		nameLbl.TextSize = 17
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

		local tpBtn = Instance.new("TextButton", row)
		tpBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
		tpBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
		tpBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
		tpBtn.Text = "TP To"
		tpBtn.TextColor3 = Color3.new(1,1,1)
		tpBtn.Font = Enum.Font.Gotham
		tpBtn.TextSize = 14
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
		tpBtn.MouseButton1Click:Connect(function() teleportToPlayer(plr.Name) end)

		local specBtn = Instance.new("TextButton", row)
		specBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
		specBtn.Position = UDim2.new(0.50, 0, 0.15, 0)
		specBtn.BackgroundColor3 = Color3.fromRGB(140, 220, 70)
		specBtn.Text = "Spectate"
		specBtn.TextColor3 = Color3.new(1,1,1)
		specBtn.Font = Enum.Font.Gotham
		specBtn.TextSize = 14
		Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 6)
		specBtn.MouseButton1Click:Connect(function() spectatePlayer(plr.Name) end)
	end
end

-- Tab buttons
for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0.32, -12, 0.8, 0)
	btn.Position = UDim2.new((i-1)*0.333 + 0.01, 0, 0.1, 0)
	btn.BackgroundColor3 = (name == currentTab) and Color3.fromRGB(42, 42, 62) or Color3.fromRGB(28, 28, 44)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(215, 235, 255)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 18
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)
	local ind = Instance.new("Frame", btn)
	ind.Name = "Indicator"
	ind.Size = UDim2.new(1, 0, 0, 3)
	ind.Position = UDim2.new(0, 0, 1, -3)
	ind.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
	ind.Visible = (name == currentTab)
	table.insert(tabButtons, btn)
	btn.MouseButton1Click:Connect(function()
		currentTab = name
		for _, b in ipairs(tabButtons) do
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
			b.Indicator.Visible = false
		end
		btn.BackgroundColor3 = Color3.fromRGB(42, 42, 62)
		ind.Visible = true
		for k, v in pairs(tabFrames) do v.Visible = (k == name) end
		setStatus(name .. " loaded")
		if name == "Players" then task.delay(0.1, refreshPlayerList) end
	end)
end

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = UDim2.new(0.38, 0, 0, 48)}):Play()
		tabBar.Visible = false
		content.Visible = false
		minBtn.Text = "+"
		minBtn.BackgroundColor3 = Color3.fromRGB(70, 210, 90)
		setStatus("Minimized")
	else
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = UDim2.new(0.38, 0, 0.75, 0)}):Play()
		task.delay(0.2, function()
			if not minimized then tabBar.Visible = true content.Visible = true end
		end)
		minBtn.Text = "−"
		minBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
		setStatus(currentTab .. " loaded")
	end
end)

-- ================================================
-- REMOTES TAB (FIRE ALL with confirmation)
-- ================================================

local remotesTab = Instance.new("Frame", content)
remotesTab.Size = UDim2.new(1, 0, 1, 0)
remotesTab.BackgroundTransparency = 1
remotesTab.Visible = true
tabFrames.Remotes = remotesTab

local remotesScroll = Instance.new("ScrollingFrame", remotesTab)
remotesScroll.Size = UDim2.new(1, -20, 1, -110)
remotesScroll.Position = UDim2.new(0, 10, 0, 10)
remotesScroll.BackgroundTransparency = 1
remotesScroll.ScrollBarThickness = 4
remotesScroll.ScrollBarImageColor3 = Color3.fromRGB(90, 140, 230)

local remotesLayout = Instance.new("UIListLayout", remotesScroll)
remotesLayout.Padding = UDim.new(0, 8)
remotesLayout.SortOrder = Enum.SortOrder.LayoutOrder
remotesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	remotesScroll.CanvasSize = UDim2.fromOffset(0, remotesLayout.AbsoluteContentSize.Y + 30)
end)

local remoteButtons = {}

local function buildPath(obj)
	local parts = {}
	local cur = obj
	while cur and cur ~= game do
		table.insert(parts, 1, cur.Name)
		cur = cur.Parent
	end
	return "game." .. table.concat(parts, ".")
end

local function getFullExampleLine(remote)
	local path = buildPath(remote)
	local class = remote.ClassName
	if class == "RemoteEvent" then return path .. ":FireServer(nil)" end
	if class == "RemoteFunction" then return path .. ":InvokeServer(nil)" end
	if class == "BindableEvent" then return path .. ":Fire()" end
	if class == "BindableFunction" then return path .. ":Invoke()" end
	return path
end

local fireExampleBox = Instance.new("TextBox", remotesTab)
fireExampleBox.Size = UDim2.new(1, -20, 0, 0)
fireExampleBox.AutomaticSize = Enum.AutomaticSize.Y
fireExampleBox.Position = UDim2.new(0, 10, 1, -95)
fireExampleBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
fireExampleBox.TextColor3 = Color3.fromRGB(220, 245, 255)
fireExampleBox.Text = "Click a remote → path appears here (click again to copy)"
fireExampleBox.ClearTextOnFocus = false
fireExampleBox.MultiLine = true
fireExampleBox.TextWrapped = true
fireExampleBox.TextXAlignment = Enum.TextXAlignment.Left
fireExampleBox.TextYAlignment = Enum.TextYAlignment.Top
fireExampleBox.Font = Enum.Font.Gotham
fireExampleBox.TextSize = 14
fireExampleBox.Active = true
fireExampleBox.Selectable = true
fireExampleBox.TextEditable = true
Instance.new("UICorner", fireExampleBox).CornerRadius = UDim.new(0, 10)

local boxPadding = Instance.new("UIPadding", fireExampleBox)
boxPadding.PaddingTop = UDim.new(0, 10)
boxPadding.PaddingLeft = UDim.new(0, 12)
boxPadding.PaddingRight = UDim.new(0, 12)
boxPadding.PaddingBottom = UDim.new(0, 10)

local function addRemote(remote)
	if isBlacklisted(remote.Name) then return end
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundTransparency = 1
	row.Parent = remotesScroll
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.55, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(36, 36, 56)
	btn.Text = remote.Name .. " (" .. remote.ClassName .. ")"
	btn.TextColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(140, 255, 170) or remote:IsA("RemoteFunction") and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(200, 200, 255)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 15
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	local pad = Instance.new("UIPadding", btn)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	local singleArg = Instance.new("TextBox", row)
	singleArg.Size = UDim2.new(0.22, -5, 0.9, 0)
	singleArg.Position = UDim2.new(0.57, 5, 0.05, 0)
	singleArg.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	singleArg.TextColor3 = Color3.fromRGB(220, 245, 255)
	singleArg.PlaceholderText = "arg..."
	singleArg.Text = ""
	singleArg.ClearTextOnFocus = false
	singleArg.Font = Enum.Font.Gotham
	singleArg.TextSize = 13
	Instance.new("UICorner", singleArg).CornerRadius = UDim.new(0, 6)
	local fireOneBtn = Instance.new("TextButton", row)
	fireOneBtn.Size = UDim2.new(0.20, -5, 0.9, 0)
	fireOneBtn.Position = UDim2.new(0.80, 5, 0.05, 0)
	fireOneBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
	fireOneBtn.Text = "Fire 1"
	fireOneBtn.TextColor3 = Color3.new(1, 1, 1)
	fireOneBtn.Font = Enum.Font.GothamBold
	fireOneBtn.TextSize = 13
	Instance.new("UICorner", fireOneBtn).CornerRadius = UDim.new(0, 6)
	fireOneBtn.MouseButton1Click:Connect(function()
		local txt = singleArg.Text:lower()
		local arg
		if txt == "" or txt == "nil" then arg = nil
		elseif txt == "true" then arg = true
		elseif txt == "false" then arg = false
		elseif tonumber(txt) then arg = tonumber(txt)
		else arg = txt end
		local success, err = pcall(function()
			if remote:IsA("RemoteEvent") then remote:FireServer(arg)
			elseif remote:IsA("RemoteFunction") then remote:InvokeServer(arg) end
		end)
		if success then
			setStatus("Fired " .. remote.Name .. " → " .. tostring(arg))
		else
			setStatus("Failed: " .. tostring(err))
		end
	end)
	btn.MouseButton1Click:Connect(function()
		local line = getFullExampleLine(remote)
		fireExampleBox.Text = line
		setStatus(remote.Name .. " selected")
		if typeof(setclipboard) == "function" then
			setclipboard(line)
			setStatus(remote.Name .. " → copied!")
			task.delay(2.5, function()
				if status.Text == remote.Name .. " → copied!" then setStatus(currentTab .. " loaded") end
			end)
		end
	end)
	table.insert(remoteButtons, row)
end

local bottomControls = Instance.new("Frame", remotesTab)
bottomControls.Size = UDim2.new(1, -20, 0, 36)
bottomControls.Position = UDim2.new(0, 10, 1, -56)
bottomControls.BackgroundTransparency = 1

local argInputAll = Instance.new("TextBox", bottomControls)
argInputAll.Size = UDim2.new(0.45, -5, 1, 0)
argInputAll.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
argInputAll.TextColor3 = Color3.fromRGB(220, 245, 255)
argInputAll.PlaceholderText = "Arg for all..."
argInputAll.Text = ""
argInputAll.ClearTextOnFocus = false
argInputAll.Font = Enum.Font.Gotham
argInputAll.TextSize = 14
argInputAll.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", argInputAll).CornerRadius = UDim.new(0, 6)

local fireAllBtn = Instance.new("TextButton", bottomControls)
fireAllBtn.Size = UDim2.new(0.25, -5, 1, 0)
fireAllBtn.Position = UDim2.new(0.47, 0, 0, 0)
fireAllBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
fireAllBtn.Text = "FIRE ALL"
fireAllBtn.TextColor3 = Color3.new(1, 1, 1)
fireAllBtn.Font = Enum.Font.GothamBold
fireAllBtn.TextSize = 14
Instance.new("UICorner", fireAllBtn).CornerRadius = UDim.new(0, 6)

fireAllBtn.MouseButton1Click:Connect(function()
	local confirm = Instance.new("Frame")
	confirm.Name = "ConfirmFireAll"
	confirm.Size = UDim2.new(0, 320, 0, 140)
	confirm.Position = UDim2.new(0.5, -160, 0.5, -70)
	confirm.BackgroundColor3 = Color3.fromRGB(30,30,45)
	confirm.Parent = gui
	Instance.new("UICorner", confirm).CornerRadius = UDim.new(0,12)

	local txt = Instance.new("TextLabel", confirm)
	txt.Size = UDim2.new(1,0,0,60)
	txt.BackgroundTransparency = 1
	txt.Text = "Really fire ALL remotes?\nThis can crash / kick / ban you."
	txt.TextColor3 = Color3.fromRGB(255,180,100)
	txt.Font = Enum.Font.GothamSemibold
	txt.TextSize = 18

	local yes = Instance.new("TextButton", confirm)
	yes.Size = UDim2.new(0.45,0,0,40)
	yes.Position = UDim2.new(0.05,0,0.65,0)
	yes.BackgroundColor3 = Color3.fromRGB(200,60,60)
	yes.Text = "YES – FIRE"
	yes.TextColor3 = Color3.new(1,1,1)

	local no = Instance.new("TextButton", confirm)
	no.Size = UDim2.new(0.45,0,0,40)
	no.Position = UDim2.new(0.5,0,0.65,0)
	no.BackgroundColor3 = Color3.fromRGB(70,160,100)
	no.Text = "Cancel"

	yes.MouseButton1Click:Connect(function()
		local txt = argInputAll.Text:lower()
		local arg
		if txt == "" or txt == "nil" then arg = nil
		elseif txt == "true" then arg = true
		elseif txt == "false" then arg = false
		elseif tonumber(txt) then arg = tonumber(txt)
		else arg = txt end

		local ok, fail = 0, 0
		for _, obj in ipairs(game:GetDescendants()) do
			if obj:IsA("RemoteEvent") and not isBlacklisted(obj.Name) then
				local s = pcall(function() obj:FireServer(arg) end)
				if s then ok = ok + 1 else fail = fail + 1 end
			end
		end
		setStatus("Fired " .. ok .. " | Failed " .. fail)
		confirm:Destroy()
	end)

	no.MouseButton1Click:Connect(function()
		confirm:Destroy()
	end)
end)

local rescanBtn = Instance.new("TextButton", bottomControls)
rescanBtn.Size = UDim2.new(0.28, -5, 1, 0)
rescanBtn.Position = UDim2.new(0.72, 0, 0, 0)
rescanBtn.BackgroundColor3 = Color3.fromRGB(110, 170, 110)
rescanBtn.Text = "🔄 RESCAN"
rescanBtn.TextColor3 = Color3.new(1, 1, 1)
rescanBtn.Font = Enum.Font.GothamBold
rescanBtn.TextSize = 14
Instance.new("UICorner", rescanBtn).CornerRadius = UDim.new(0, 6)

local function scanRemotes()
	setStatus("Scanning...")
	for _, b in ipairs(remoteButtons) do b:Destroy() end
	remoteButtons = {}
	fireExampleBox.Text = "Click a remote → path appears here (click again to copy)"
	local count = 0
	for _, obj in ipairs(game:GetDescendants()) do
		if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction")) and not isBlacklisted(obj.Name) then
			addRemote(obj)
			count = count + 1
		end
	end
	setStatus("Found " .. count .. " remotes")
end
rescanBtn.MouseButton1Click:Connect(scanRemotes)

-- ================================================
-- CHEATS TAB
-- ================================================

local cheatsTab = Instance.new("Frame", content)
cheatsTab.Size = UDim2.new(1, 0, 1, 0)
cheatsTab.BackgroundTransparency = 1
cheatsTab.Visible = false
tabFrames.Cheats = cheatsTab

local cheatsScroll = Instance.new("ScrollingFrame", cheatsTab)
cheatsScroll.Size = UDim2.new(1, -20, 1, -20)
cheatsScroll.Position = UDim2.new(0, 10, 0, 10)
cheatsScroll.BackgroundTransparency = 1
cheatsScroll.ScrollBarThickness = 4
cheatsScroll.ScrollBarImageColor3 = Color3.fromRGB(90, 140, 230)

local cheatsLayout = Instance.new("UIListLayout", cheatsScroll)
cheatsLayout.Padding = UDim.new(0, 12)
cheatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cheatsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	cheatsScroll.CanvasSize = UDim2.fromOffset(0, cheatsLayout.AbsoluteContentSize.Y + 40)
end)

local states = {
	ESP = false,
	BoxESP = false,
	Aimbot = false,
	AimbotThroughWalls = false,
	Tracers = false,
	WalkSpeed = false,
	Fly = false,
	Noclip = false,
	InfJump = false,
	Fullbright = false,
	Spin = false,
	AntiAFK = false,
	CustomCrosshair = false,
	ShowTeammates = true,
	Chams = false,
}

local targets = {
	WalkSpeedValue = 50,
	JumpHeight = 7.2,
	MaxHealth = 100,
	FOV = 70,
	FlySpeed = 50,
	SpinSpeed = 360,
	AimbotSmoothness = 0.16,
}

local settings = {
	AimbotHumanization = false,
	HumanizationOffset = 0.25,
	PredictionFactor = 0.12,
	MaxAimAngle = 55,
	WalkSpeedVariance = 0.07,
	TracerOrigin = "Head",
	TracerDistanceFade = true,
	ESPDistanceFade = true,
	MaxESPDistance = 180,
}

local connections = {}
local aimbotConnection
local tracers = {}
local aimbotPartPriority = "Head"
local defaultOutlineColor = Color3.fromRGB(0, 255, 100)
local espConnections = {}
local aimTeamMode = "Enemies"
local toggleButtons = {}
local chamsHighlights = {}

local function getPlayerOutlineColor(plr)
	if plr.Team and plr.TeamColor then return plr.TeamColor.Color end
	return defaultOutlineColor
end

local function addHighlight(character, plr)
	if not character or character:FindFirstChild("PlayerHighlight") then return end
	local h = Instance.new("Highlight")
	h.Name = "PlayerHighlight"
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = getPlayerOutlineColor(plr)
	h.Adornee = character
	h.Parent = character
end

local function setupPlayer(plr)
	if plr == player then return end
	if plr.Character then addHighlight(plr.Character, plr) end
	local conn = plr.CharacterAdded:Connect(function(char) addHighlight(char, plr) end)
	espConnections[plr] = conn
end

local function toggleESP(enable)
	if enable then
		setStatus("ESP ON")
		for _, plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end
		if not espConnections["PlayerAdded"] then
			espConnections["PlayerAdded"] = Players.PlayerAdded:Connect(setupPlayer)
		end
		task.spawn(function()
			while states.ESP do
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character and (states.ShowTeammates or (player.Team ~= plr.Team)) then
						local h = plr.Character:FindFirstChild("PlayerHighlight")
						if not h then addHighlight(plr.Character, plr)
						else h.OutlineColor = getPlayerOutlineColor(plr) end
						local dist = player.Character and player.Character.PrimaryPart and
							(plr.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude or 0
						if settings.ESPDistanceFade and dist > settings.MaxESPDistance then
							h.Enabled = false
						else
							h.Enabled = true
						end
					end
				end
				task.wait(5)
			end
		end)
	else
		setStatus("ESP OFF")
		for _, conn in pairs(espConnections) do
			if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
		end
		espConnections = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				local h = plr.Character:FindFirstChild("PlayerHighlight")
				if h then h:Destroy() end
			end
		end
	end
end

local boxESPAdornments = {}
local function clearBoxESP()
	for plr, parts in pairs(boxESPAdornments) do
		for _, adorn in ipairs(parts) do if adorn and adorn.Parent then adorn:Destroy() end end
	end
	boxESPAdornments = {}
end

local function toggleBoxESP(enable)
	if connections.boxESP then connections.boxESP:Disconnect() connections.boxESP = nil end
	clearBoxESP()
	if not enable then setStatus("Box ESP OFF") return end
	setStatus("Box ESP ON")
	connections.boxESP = RunService.RenderStepped:Connect(function()
		for plr, parts in pairs(boxESPAdornments) do
			if not plr.Character or not plr.Character.Parent then
				for _, adorn in ipairs(parts) do if adorn then adorn:Destroy() end end
				boxESPAdornments[plr] = nil
			end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player or not plr.Character then continue end
			local char = plr.Character
			local hum = char:FindFirstChild("Humanoid")
			if not hum or hum.Health <= 0 then continue end
			if not boxESPAdornments[plr] then boxESPAdornments[plr] = {} end
			local partsList = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
			for _, partName in ipairs(partsList) do
				local part = char:FindFirstChild(partName)
				if not part or not part:IsA("BasePart") or part:FindFirstChild("BoxESP") then continue end
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "BoxESP"
				box.Adornee = part
				box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
				box.Color3 = Color3.new(1, 0.15, 0.15)
				box.Transparency = 0.6
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Parent = part
				table.insert(boxESPAdornments[plr], box)
			end
		end
	end)
end

Players.PlayerRemoving:Connect(function(plr)
	if espConnections[plr] then espConnections[plr]:Disconnect() espConnections[plr] = nil end
	if plr.Character then
		local h = plr.Character:FindFirstChild("PlayerHighlight")
		if h then h:Destroy() end
	end
end)

local function canSee(targetPart)
	if not targetPart then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	local result = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position), rayParams)
	return result and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestTarget()
	local bestPart, bestScore = nil, -1
	local camPos  = camera.CFrame.Position
	local camLook = camera.CFrame.LookVector
	local maxCos = math.cos(math.rad(settings.MaxAimAngle))
	for _, plr in Players:GetPlayers() do
		if plr == player or not plr.Character then continue end
		local isEnemy = not plr.Team or player.Team ~= plr.Team
		if aimTeamMode == "Enemies" and not isEnemy then continue end
		if aimTeamMode == "Teammates" and isEnemy then continue end
		local root = plr.Character:FindFirstChild("HumanoidRootPart")
		if not root then continue end
		local aimPart = plr.Character:FindFirstChild(aimbotPartPriority) or root
		if not aimPart then continue end
		if not states.AimbotThroughWalls and not canSee(aimPart) then continue end
		local vel = root.Velocity
		local predictedPos = aimPart.Position + vel * settings.PredictionFactor
		local toTarget = (predictedPos - camPos).Unit
		local dot = camLook:Dot(toTarget)
		if dot > maxCos and dot > bestScore then
			bestScore = dot
			bestPart = aimPart
		end
	end
	return bestPart
end

local function toggleAimbot(on)
	if on then
		setStatus("Aimbot ON" .. (states.AimbotThroughWalls and " (through walls)" or ""))
		if aimbotConnection then aimbotConnection:Disconnect() end
		aimbotConnection = RunService.RenderStepped:Connect(function()
			local target = getClosestTarget()
			if target then
				local offset = Vector3.new(0, 0, 0)
				if settings.AimbotHumanization then
					offset = Vector3.new(
						math.random(-10,10)*0.1 * settings.HumanizationOffset,
						math.random(-8,12)*0.1  * settings.HumanizationOffset,
						math.random(-6,6)*0.1   * settings.HumanizationOffset
					)
				end
				local targetPos = target.Position + offset
				local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
				camera.CFrame = camera.CFrame:Lerp(targetCF, targets.AimbotSmoothness)
			end
		end)
	else
		setStatus("Aimbot OFF")
		if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
	end
end

local function toggleAimbotThroughWalls(on)
	states.AimbotThroughWalls = on
	setStatus("Aimbot Through Walls: " .. (on and "ON" or "OFF"))
	if states.Aimbot then
		toggleAimbot(false)
		task.wait()
		toggleAimbot(true)
	end
end

local function toggleTracers(on)
	if connections.tracers then connections.tracers:Disconnect() connections.tracers = nil end
	for _, obj in ipairs(tracers) do if obj and obj.Parent then obj:Destroy() end end
	tracers = {}
	if not on then setStatus("Tracers OFF") return end
	setStatus("Tracers ON")
	connections.tracers = RunService.RenderStepped:Connect(function()
		for _, obj in ipairs(tracers) do if obj and obj.Parent then obj:Destroy() end end
		tracers = {}
		local char = player.Character
		if not char or not char.Parent then return end
		local myHead = char:FindFirstChild("Head")
		if not myHead or not myHead:IsA("BasePart") then return end
		local myPos = myHead.Position
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then continue end
			local tChar = plr.Character
			if not tChar or not tChar.Parent then continue end
			local tHead = tChar:FindFirstChild("Head")
			if not tHead or not tHead:IsA("BasePart") then continue end
			local hum = tChar:FindFirstChildWhichIsA("Humanoid")
			if not hum or hum.Health <= 0 then continue end
			if not states.ShowTeammates and player.Team == plr.Team then continue end
			local success, dist = pcall(function()
				return (tHead.Position - myPos).Magnitude
			end)
			if not success or (settings.TracerDistanceFade and dist > settings.MaxESPDistance) then continue end
			local originPos = myPos
			if settings.TracerOrigin == "Camera" then originPos = camera.CFrame.Position
			elseif settings.TracerOrigin == "Mouse" then
				local mouse = player:GetMouse()
				originPos = mouse and mouse.Hit and mouse.Hit.Position or myPos
			end
			local beam = Instance.new("Beam")
			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")
			a0.WorldPosition = originPos
			a1.WorldPosition = tHead.Position
			a0.Parent = workspace.Terrain
			a1.Parent = workspace.Terrain
			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Color = ColorSequence.new(getPlayerOutlineColor(plr))
			beam.Width0 = 0.08
			beam.Width1 = 0.08
			beam.Transparency = NumberSequence.new(0.4)
			beam.FaceCamera = true
			beam.Parent = workspace.Terrain
			table.insert(tracers, beam)
			table.insert(tracers, a0)
			table.insert(tracers, a1)
		end
	end)
end

local function toggleWalkSpeed(on)
	if connections.walkSpeed then connections.walkSpeed:Disconnect() end
	local hum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
	if hum then hum.WalkSpeed = 16 end  -- reset to default
	if not on then
		setStatus("Walk Speed → OFF")
		return
	end
	setStatus("Walk Speed → ON")
	connections.walkSpeed = RunService.Heartbeat:Connect(function()
		local hum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
		if not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Running or
			hum:GetState() == Enum.HumanoidStateType.Freefall then
			local base = targets.WalkSpeedValue
			local variance = base * settings.WalkSpeedVariance
			hum.WalkSpeed = base + math.random(-variance*100, variance*100)/100
		else
			hum.WalkSpeed = 16
		end
	end)
end

local function toggleFly(on)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if on then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "EliteFlyBV"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.Velocity = Vector3.new()
		bv.Parent = hrp
		local bg = Instance.new("BodyGyro")
		bg.Name = "EliteFlyBG"
		bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bg.P = 25000
		bg.D = 2000
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp
		connections.fly = RunService.RenderStepped:Connect(function()
			if not states.Fly then return end
			bg.CFrame = camera.CFrame
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end
			bv.Velocity = (move.Magnitude > 0) and (move.Unit * targets.FlySpeed) or Vector3.new()
		end)
	else
		if connections.fly then connections.fly:Disconnect() connections.fly = nil end
		if hrp:FindFirstChild("EliteFlyBV") then hrp.EliteFlyBV:Destroy() end
		if hrp:FindFirstChild("EliteFlyBG") then hrp.EliteFlyBG:Destroy() end
	end
end

local function toggleNoclip(on)
	if connections.noclip then connections.noclip:Disconnect() connections.noclip = nil end
	if on then
		connections.noclip = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end
end

local function toggleInfJump(on)
	if connections.infJump then connections.infJump:Disconnect() connections.infJump = nil end
	if on then
		connections.infJump = UserInputService.JumpRequest:Connect(function()
			local hum = player.Character and player.Character:FindFirstChild("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
end

local function toggleFullbright(on)
	local lightingBackup = {
		Brightness = Lighting.Brightness,
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime
	}
	if on then
		Lighting.Brightness = 2
		Lighting.GlobalShadows = false
		Lighting.FogEnd = math.huge
		Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
		Lighting.ClockTime = 14
	else
		Lighting.Brightness = lightingBackup.Brightness
		Lighting.GlobalShadows = lightingBackup.GlobalShadows
		Lighting.FogEnd = lightingBackup.FogEnd
		Lighting.OutdoorAmbient = lightingBackup.OutdoorAmbient
		Lighting.ClockTime = lightingBackup.ClockTime
	end
end

local spinConnection
local function toggleSpin(on)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if on then
		spinConnection = RunService.RenderStepped:Connect(function(dt)
			if not states.Spin then return end
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(targets.SpinSpeed * dt), 0)
		end)
	else
		if spinConnection then spinConnection:Disconnect() spinConnection = nil end
	end
end

local function toggleAntiAFK(on)
	if on then
		setStatus("Anti-AFK ON")
		connections.antiAFK = RunService.Heartbeat:Connect(function()
			if math.random(1, 300) == 1 then
				local hum = player.Character and player.Character:FindFirstChild("Humanoid")
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end
		end)
	else
		setStatus("Anti-AFK OFF")
		if connections.antiAFK then connections.antiAFK:Disconnect() end
	end
end

local crosshairLines = {}
local function toggleCustomCrosshair(on)
	if on then
		setStatus("Custom Crosshair ON")
		local cross = Instance.new("Frame")
		cross.Size = UDim2.new(0, 20, 0, 20)
		cross.Position = UDim2.new(0.5, -10, 0.5, -10)
		cross.BackgroundTransparency = 1
		cross.Parent = gui
		local h1 = Instance.new("Frame", cross)
		h1.Size = UDim2.new(1, 0, 0, 1)
		h1.Position = UDim2.new(0, 0, 0.5, -0.5)
		h1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		local v1 = Instance.new("Frame", cross)
		v1.Size = UDim2.new(0, 1, 1, 0)
		v1.Position = UDim2.new(0.5, -0.5, 0, 0)
		v1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		crosshairLines = {cross, h1, v1}
	else
		setStatus("Custom Crosshair OFF")
		for _, line in pairs(crosshairLines) do line:Destroy() end
		crosshairLines = {}
	end
end

local chamsHighlights = {}
local function toggleChams(on)
	if not on then
		for _, h in pairs(chamsHighlights) do if h then h:Destroy() end end
		chamsHighlights = {}
		return
	end
	for _, plr in Players:GetPlayers() do
		if plr == player or not plr.Character then continue end
		if not states.ShowTeammates and player.Team == plr.Team then continue end
		local h = Instance.new("Highlight")
		h.Name = "Chams"
		h.FillColor = Color3.fromRGB(180, 60, 255)
		h.FillTransparency = 0.4
		h.OutlineColor = Color3.fromRGB(255, 80, 120)
		h.OutlineTransparency = 0
		h.Adornee = plr.Character
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = plr.Character
		chamsHighlights[plr] = h
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function(char)
			if states.Chams then
				if not states.ShowTeammates and player.Team == plr.Team then return end
				local h = Instance.new("Highlight")
				h.Name = "Chams"
				h.FillColor = Color3.fromRGB(180, 60, 255)
				h.FillTransparency = 0.4
				h.OutlineColor = Color3.fromRGB(255, 80, 120)
				h.OutlineTransparency = 0
				h.Adornee = char
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = char
				chamsHighlights[plr] = h
			end
		end)
	end)
end

local function getAllTools()
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then setStatus("❌ Backpack not found!") return end
	local added = 0
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Tool") then
			if obj.Parent ~= backpack and (not player.Character or obj.Parent ~= player.Character) then
				local clone = obj:Clone()
				if clone then clone.Parent = backpack added = added + 1 end
			end
		end
	end
	setStatus("✅ Gave " .. added .. " tools!")
end

local function applyStats()
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = 16  -- default Roblox value
		hum.JumpHeight = targets.JumpHeight
		hum.MaxHealth = targets.MaxHealth
		hum.Health = targets.MaxHealth
	end
	camera.FieldOfView = targets.FOV
end

player.CharacterAdded:Connect(function(char)
	task.wait(0.4)
	applyStats()
	for feature, enabled in pairs(states) do
		if enabled and feature ~= "ShowTeammates" then
			local toggleFunc = ({
				ESP = toggleESP,
				BoxESP = toggleBoxESP,
				Aimbot = toggleAimbot,
				AimbotThroughWalls = toggleAimbotThroughWalls,
				Tracers = toggleTracers,
				WalkSpeed = toggleWalkSpeed,
				Fly = toggleFly,
				Noclip = toggleNoclip,
				InfJump = toggleInfJump,
				Fullbright = toggleFullbright,
				Spin = toggleSpin,
				AntiAFK = toggleAntiAFK,
				CustomCrosshair = toggleCustomCrosshair,
				Chams = toggleChams,
			})[feature]
			if toggleFunc then toggleFunc(true) end
		end
	end
end)

if player.Character then applyStats() end

local function createToggle(name, colorOn, colorOff, toggleFunc, parentFrame)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
	frame.Parent = parentFrame or cheatsScroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.18, 0, 0.8, 0)
	btn.Position = UDim2.new(0.02, 0, 0, 10)
	btn.BackgroundColor3 = states[name] and colorOn or Color3.fromRGB(60, 60, 80)
	btn.Text = states[name] and "ON" or "OFF"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(0.78, 0, 1, 0)
	label.Position = UDim2.new(0.22, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(220, 240, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 17
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(toggleButtons, {button = btn, name = name, colorOn = colorOn, colorOff = colorOff, toggleFunc = toggleFunc})
	btn.MouseButton1Click:Connect(function()
		local desired = not states[name]
		local success, result = pcall(toggleFunc, desired)
		if success then
			states[name] = desired
		else
			states[name] = false
			setStatus("Error in " .. name .. ": " .. tostring(result))
		end
		btn.BackgroundColor3 = states[name] and colorOn or Color3.fromRGB(60, 60, 80)
		btn.Text = states[name] and "ON" or "OFF"
		setStatus(name .. (states[name] and " ON" or " OFF"))
	end)
end

local function createSlider(name, targetKey, default, min, max, parentFrame)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
	frame.Parent = parentFrame or cheatsScroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(0.45, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name .. ": " .. default
	lbl.TextColor3 = Color3.fromRGB(200, 220, 255)
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	local input = Instance.new("TextBox", frame)
	input.Size = UDim2.new(0.3, 0, 0.7, 0)
	input.Position = UDim2.new(0.48, 0, 0.15, 0)
	input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.Text = tostring(default)
	input.Font = Enum.Font.Gotham
	input.TextSize = 16
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
	local setBtn = Instance.new("TextButton", frame)
	setBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
	setBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
	setBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 110)
	setBtn.Text = "SET"
	setBtn.TextColor3 = Color3.new(1, 1, 1)
	setBtn.Font = Enum.Font.GothamBold
	setBtn.TextSize = 15
	Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 8)
	local function update()
		local val = tonumber(input.Text)
		if val and val >= min and val <= max then
			targets[targetKey] = val
			if targetKey == "FOV" then
				TweenService:Create(camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {FieldOfView = val}):Play()
			end
			applyStats()
			lbl.Text = name .. ": " .. val
			setStatus(name .. " set to " .. val)
		else
			input.Text = tostring(targets[targetKey])
		end
	end
	input.FocusLost:Connect(update)
	setBtn.MouseButton1Click:Connect(update)
end

local allCheatsFrame = Instance.new("Frame", cheatsScroll)
allCheatsFrame.Size = UDim2.new(1, 0, 0, 50)
allCheatsFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
Instance.new("UICorner", allCheatsFrame).CornerRadius = UDim.new(0, 10)

local enableAllBtn = Instance.new("TextButton", allCheatsFrame)
enableAllBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
enableAllBtn.Position = UDim2.new(0.01, 0, 0.1, 0)
enableAllBtn.BackgroundColor3 = Color3.fromRGB(70, 210, 90)
enableAllBtn.Text = "Enable All"
enableAllBtn.TextColor3 = Color3.new(1, 1, 1)
enableAllBtn.Font = Enum.Font.GothamBold
enableAllBtn.TextSize = 16
Instance.new("UICorner", enableAllBtn).CornerRadius = UDim.new(0, 8)

local disableAllBtn = Instance.new("TextButton", allCheatsFrame)
disableAllBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
disableAllBtn.Position = UDim2.new(0.51, 0, 0.1, 0)
disableAllBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
disableAllBtn.Text = "Disable All"
disableAllBtn.TextColor3 = Color3.new(1, 1, 1)
disableAllBtn.Font = Enum.Font.GothamBold
disableAllBtn.TextSize = 16
Instance.new("UICorner", disableAllBtn).CornerRadius = UDim.new(0, 8)

enableAllBtn.MouseButton1Click:Connect(function()
	for _, entry in ipairs(toggleButtons) do
		if not states[entry.name] then
			states[entry.name] = true
			entry.button.BackgroundColor3 = entry.colorOn
			entry.button.Text = "ON"
			pcall(entry.toggleFunc, true)
		end
	end
	setStatus("All cheats enabled")
end)

disableAllBtn.MouseButton1Click:Connect(function()
	for _, entry in ipairs(toggleButtons) do
		if states[entry.name] then
			states[entry.name] = false
			entry.button.BackgroundColor3 = entry.colorOff
			entry.button.Text = "OFF"
			pcall(entry.toggleFunc, false)
		end
	end
	setStatus("All cheats disabled")
end)

-- ================================================
-- DROPDOWN SECTIONS
-- ================================================

local function createSection(title)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, 0, 0, 0)
	sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
	sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	sectionFrame.Parent = cheatsScroll
	Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 10)
	local sectionLayout = Instance.new("UIListLayout", sectionFrame)
	sectionLayout.Padding = UDim.new(0, 0)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local header = Instance.new("TextButton", sectionFrame)
	header.Size = UDim2.new(1, 0, 0, 45)
	header.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	header.Text = "▼ " .. title
	header.TextColor3 = Color3.fromRGB(220, 240, 255)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 18
	header.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
	local headerPad = Instance.new("UIPadding", header)
	headerPad.PaddingLeft = UDim.new(0, 15)
	local subFrame = Instance.new("Frame", sectionFrame)
	subFrame.Size = UDim2.new(1, 0, 0, 0)
	subFrame.AutomaticSize = Enum.AutomaticSize.Y
	subFrame.BackgroundTransparency = 1
	local subLayout = Instance.new("UIListLayout", subFrame)
	subLayout.Padding = UDim.new(0, 12)
	subLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local open = false
	header.MouseButton1Click:Connect(function()
		open = not open
		subFrame.Visible = open
		header.Text = (open and "▲ " or "▼ ") .. title
	end)
	subFrame.Visible = false
	return subFrame
end

local aimbotSub = createSection("Aimbot")
createToggle("Aimbot", Color3.fromRGB(255, 100, 100), Color3.fromRGB(60, 60, 80), toggleAimbot, aimbotSub)
createToggle("Aimbot Through Walls", Color3.fromRGB(255, 140, 80), Color3.fromRGB(60, 60, 80), toggleAimbotThroughWalls, aimbotSub)
createSlider("Aimbot Smoothness", "AimbotSmoothness", 0.16, 0.05, 0.6, aimbotSub)

local visualsSub = createSection("Visuals")
createToggle("ESP", Color3.fromRGB(255, 80, 80), Color3.fromRGB(60, 60, 80), toggleESP, visualsSub)
createToggle("BoxESP", Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 60, 80), toggleBoxESP, visualsSub)
createToggle("Tracers", Color3.fromRGB(100, 100, 255), Color3.fromRGB(60, 60, 80), toggleTracers, visualsSub)
createToggle("Fullbright", Color3.fromRGB(255, 255, 140), Color3.fromRGB(60, 60, 80), toggleFullbright, visualsSub)
createToggle("CustomCrosshair", Color3.fromRGB(150, 255, 150), Color3.fromRGB(60, 60, 80), toggleCustomCrosshair, visualsSub)
createToggle("Chams", Color3.fromRGB(220, 100, 220), Color3.fromRGB(60,60,80), toggleChams, visualsSub)
createToggle("Show Teammates", Color3.fromRGB(100, 220, 100), Color3.fromRGB(60, 60, 80),
	function(v)
		states.ShowTeammates = v
		setStatus("Show Teammates: " .. (v and "ON" or "OFF"))
		if states.ESP then toggleESP(false); task.wait(); toggleESP(true) end
		if states.Tracers then toggleTracers(false); task.wait(); toggleTracers(true) end
		if states.Chams then toggleChams(false); task.wait(); toggleChams(true) end
	end,
	visualsSub
)

local movementSub = createSection("Movement")
createToggle("WalkSpeed", Color3.fromRGB(255, 200, 100), Color3.fromRGB(60, 60, 80), toggleWalkSpeed, movementSub)
createSlider("Walk Speed Value", "WalkSpeedValue", 50, 10, 500, movementSub)
createSlider("Jump Height", "JumpHeight", 7.2, 0, 500, movementSub)
createToggle("Fly", Color3.fromRGB(100, 200, 255), Color3.fromRGB(60, 60, 80), toggleFly, movementSub)
createSlider("Fly Speed", "FlySpeed", 50, 10, 500, movementSub)
createToggle("Noclip", Color3.fromRGB(255, 180, 100), Color3.fromRGB(60, 60, 80), toggleNoclip, movementSub)
createToggle("InfJump", Color3.fromRGB(180, 120, 255), Color3.fromRGB(60, 60, 80), toggleInfJump, movementSub)
createToggle("Spin", Color3.fromRGB(220, 100, 220), Color3.fromRGB(60, 60, 80), toggleSpin, movementSub)
createSlider("Spin Speed (°/s)", "SpinSpeed", 360, 0, 20000, movementSub)
createSlider("Max Health", "MaxHealth", 100, 1, 10000, movementSub)
createSlider("FOV", "FOV", 70, 10, 150, movementSub)

local utilitiesSub = createSection("Utilities")
createToggle("AntiAFK", Color3.fromRGB(100, 255, 200), Color3.fromRGB(60, 60, 80), toggleAntiAFK, utilitiesSub)

local toolsFrame = Instance.new("Frame")
toolsFrame.Size = UDim2.new(1, 0, 0, 60)
toolsFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
toolsFrame.Parent = utilitiesSub
Instance.new("UICorner", toolsFrame).CornerRadius = UDim.new(0, 10)
local toolsBtn = Instance.new("TextButton", toolsFrame)
toolsBtn.Size = UDim2.new(0.96, 0, 0.75, 0)
toolsBtn.Position = UDim2.new(0.02, 0, 0.125, 0)
toolsBtn.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
toolsBtn.Text = "🎒 GET EVERY TOOL"
toolsBtn.TextColor3 = Color3.new(1, 1, 1)
toolsBtn.Font = Enum.Font.GothamBold
toolsBtn.TextSize = 19
Instance.new("UICorner", toolsBtn).CornerRadius = UDim.new(0, 10)
toolsBtn.MouseButton1Click:Connect(getAllTools)

-- ================================================
-- FINAL LOAD
-- ================================================

task.defer(function()
	task.wait(0.4)
	scanRemotes()
	if fireExampleBox then fireExampleBox.Text = "Scan complete - click remote or use FIRE ALL" end
	main.Visible = true
	TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.31, 0, 0.125, 0) }):Play()
	print("Diddy Cheats V6.7 loaded successfully")
	setStatus("Loaded - Enjoy!")
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.PageUp then
		if main.Visible then
			TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.31, 0, -1.2, 0)}):Play()
			task.delay(0.45, function() main.Visible = false end)
		else
			main.Visible = true
			TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.31, 0, 0.125, 0)}):Play()
		end
	end
end)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 180, 0, 36)
infoLabel.Position = UDim2.new(1, -190, 0, 8)
infoLabel.BackgroundTransparency = 0.4
infoLabel.BackgroundColor3 = Color3.fromRGB(20,20,35)
infoLabel.TextColor3 = Color3.fromRGB(200,240,255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 15
infoLabel.Parent = gui
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0,8)

RunService.RenderStepped:Connect(function(dt)
	local fps = math.floor(1/dt + 0.5)
	local ping = player:GetNetworkPing() and math.floor(player:GetNetworkPing()*1000) or "???"
	infoLabel.Text = string.format("FPS: %d   Ping: %d ms", fps, ping)
end)
