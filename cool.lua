local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local guiName = "DiddysCheatGUI"

-- Clear old GUI if exists
if player.PlayerGui:FindFirstChild(guiName) then
	player.PlayerGui[guiName]:Destroy()
end

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 2147483647
gui.Parent = player:WaitForChild("PlayerGui")

local remoteBlacklist = {"PlayEmote", "SendNotificationInfo"}

local function isBlacklisted(name)
	name = name:lower()
	for _, word in ipairs(remoteBlacklist) do
		if name:find(word:lower(), 1, true) then return true end
	end
	return false
end

-- ────────────────────────────────────────────────────────────────
-- Main Frame & UI Setup
-- ────────────────────────────────────────────────────────────────

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

-- Title Bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.65, 0, 1, 0)
title.Position = UDim2.new(0.035, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DIDDY CHEATS"
title.TextColor3 = Color3.fromRGB(225, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left

local status = Instance.new("TextLabel", titleBar)
status.Size = UDim2.new(0.32, 0, 1, 0)
status.Position = UDim2.new(0.56, 0, 0, 0)
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

-- Minimize Button
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

-- Tab Bar
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, 0, 0, 46)
tabBar.Position = UDim2.new(0, 0, 0, 48)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 28, 44)

local tabs = {"Remotes", "Cheats"}
local tabFrames = {}
local currentTab = "Remotes"

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(0.48, -12, 0.8, 0)
	btn.Position = UDim2.new((i-1)*0.5 + 0.01, 0, 0.1, 0)
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

	btn.MouseButton1Click:Connect(function()
		currentTab = name
		for _, b in tabBar:GetChildren() do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
				b.Indicator.Visible = false
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(42, 42, 62)
		ind.Visible = true
		for k, v in pairs(tabFrames) do v.Visible = (k == name) end
		setStatus(name .. " loaded")
	end)
end

-- Content Frame
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -94)
content.Position = UDim2.new(0, 0, 0, 94)
content.BackgroundTransparency = 1

-- Minimize logic
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0.38, 0, 0, 48)
		}):Play()
		tabBar.Visible = false
		content.Visible = false
		minBtn.Text = "+"
		minBtn.BackgroundColor3 = Color3.fromRGB(70, 210, 90)
		setStatus("Minimized")
		task.delay(1.2, function()
			if minimized then setStatus("—") end
		end)
	else
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0.38, 0, 0.75, 0)
		}):Play()
		task.delay(0.2, function()
			if not minimized then
				tabBar.Visible = true
				content.Visible = true
			end
		end)
		minBtn.Text = "−"
		minBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
		setStatus(currentTab .. " loaded")
	end
end)

-- ────────────────────────────────────────────────────────────────
-- Remotes Tab
-- ────────────────────────────────────────────────────────────────

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
	btn.TextColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(140, 255, 170)
		or remote:IsA("RemoteFunction") and Color3.fromRGB(255, 220, 130)
		or Color3.fromRGB(200, 200, 255)
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
			if remote:IsA("RemoteEvent") then
				remote:FireServer(arg)
			elseif remote:IsA("RemoteFunction") then
				remote:InvokeServer(arg)
			end
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
				if status.Text == remote.Name .. " → copied!" then
					setStatus(currentTab .. " loaded")
				end
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
	fireExampleBox.Text = "Mass fired → arg = " .. tostring(arg)
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
		if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or
			obj:IsA("BindableEvent") or obj:IsA("BindableFunction")) and
			not isBlacklisted(obj.Name) then
			addRemote(obj)
			count = count + 1
		end
	end
	setStatus("Found " .. count .. " remotes")
end

rescanBtn.MouseButton1Click:Connect(scanRemotes)

-- ────────────────────────────────────────────────────────────────
-- Cheats Tab
-- ────────────────────────────────────────────────────────────────

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
	Aimbot = false,
	Fly = false,
	Noclip = false,
	InfJump = false,
	GodMode = false,
	Fullbright = false,
	Spin = false
}

local targets = {
	WalkSpeed = 16,
	JumpHeight = 7.2,
	MaxHealth = 100,
	FOV = 70,
	FlySpeed = 50,
	SpinSpeed = 360
}

local connections = {}
local aimbotConnection
local lastTraceBeam = nil

-- ────────────────────────────────────────────────────────────────
-- ESP — team color + default fallback + color picker
-- ────────────────────────────────────────────────────────────────

local defaultOutlineColor = Color3.fromRGB(0, 255, 100)  -- lime green fallback

local espConnections = {}

local function getPlayerOutlineColor(plr)
	if plr.Team and plr.TeamColor then
		return plr.TeamColor.Color
	end
	return defaultOutlineColor
end

local function addHighlight(character, plr)
	if not character then return end

	if character:FindFirstChild("PlayerHighlight") then
		return
	end

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

	if plr.Character then
		addHighlight(plr.Character, plr)
	end

	local conn = plr.CharacterAdded:Connect(function(char)
		addHighlight(char, plr)
	end)

	espConnections[plr] = conn
end

local function toggleESP(enable)
	states.ESP = enable

	if enable then
		setStatus("ESP ON (Team colors)")

		for _, plr in ipairs(Players:GetPlayers()) do
			setupPlayer(plr)
		end

		if not espConnections["PlayerAdded"] then
			local addedConn = Players.PlayerAdded:Connect(setupPlayer)
			espConnections["PlayerAdded"] = addedConn
		end
	else
		setStatus("ESP OFF")

		for _, conn in pairs(espConnections) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
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

Players.PlayerRemoving:Connect(function(plr)
	if espConnections[plr] then
		espConnections[plr]:Disconnect()
		espConnections[plr] = nil
	end
	if plr.Character then
		local h = plr.Character:FindFirstChild("PlayerHighlight")
		if h then h:Destroy() end
	end
end)

-- ────────────────────────────────────────────────────────────────
-- Aimbot (unchanged)
-- ────────────────────────────────────────────────────────────────

local function getClosestTarget(maxFovDeg)
	local bestPart = nil
	local bestDot = -1
	local camPos = camera.CFrame.Position
	local camLook = camera.CFrame.LookVector
	local maxCos = math.cos(math.rad(maxFovDeg or 14))

	for _, plr in Players:GetPlayers() do
		if plr == player or not plr.Character then continue end
		local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
		if not head then continue end
		local vec = (head.Position - camPos).Unit
		local dot = camLook:Dot(vec)
		if dot > maxCos and dot > bestDot then
			bestDot = dot
			bestPart = head
		end
	end
	return bestPart
end

local function toggleAimbot(on)
	states.Aimbot = on
	if on then
		setStatus("Aimbot ON")
		if aimbotConnection then aimbotConnection:Disconnect() end
		aimbotConnection = RunService.RenderStepped:Connect(function()
			if not states.Aimbot then return end
			local target = getClosestTarget(14)
			if target then
				local targetCF = CFrame.new(camera.CFrame.Position, target.Position)
				camera.CFrame = camera.CFrame:Lerp(targetCF, 0.16)
				if lastTraceBeam then lastTraceBeam:Destroy() end
				local beam = Instance.new("Beam")
				local a0 = Instance.new("Attachment")
				local a1 = Instance.new("Attachment")
				a0.WorldPosition = camera.CFrame.Position
				a1.WorldPosition = target.Position + Vector3.new(0, 0.1, 0)
				a0.Parent = workspace.Terrain
				a1.Parent = workspace.Terrain
				beam.Attachment0 = a0
				beam.Attachment1 = a1
				beam.Color = ColorSequence.new(Color3.fromRGB(255, 40, 40))
				beam.Width0 = 0.14
				beam.Width1 = 0.14
				beam.Transparency = NumberSequence.new(0.35)
				beam.FaceCamera = true
				beam.Parent = workspace
				lastTraceBeam = beam
				task.delay(0.18, function()
					if lastTraceBeam == beam then
						beam:Destroy()
						lastTraceBeam = nil
					end
				end)
			end
		end)
	else
		setStatus("Aimbot OFF")
		if aimbotConnection then
			aimbotConnection:Disconnect()
			aimbotConnection = nil
		end
		if lastTraceBeam then
			lastTraceBeam:Destroy()
			lastTraceBeam = nil
		end
	end
end

-- ────────────────────────────────────────────────────────────────
-- Other cheats (Fly, Noclip, etc.)
-- ────────────────────────────────────────────────────────────────

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
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0,-1,0) end
			bv.Velocity = move.Magnitude > 0 and move.Unit * targets.FlySpeed or Vector3.new()
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
				for _, part in player.Character:GetDescendants() do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
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

local function toggleGod(on)
	if connections.god then connections.god:Disconnect() connections.god = nil end
	if on then
		connections.god = RunService.Heartbeat:Connect(function()
			local hum = player.Character and player.Character:FindFirstChild("Humanoid")
			if hum then hum.Health = hum.MaxHealth end
		end)
	end
end

local lightingBackup = {
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ClockTime = Lighting.ClockTime
}

local function toggleFullbright(on)
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
		if spinConnection then
			spinConnection:Disconnect()
			spinConnection = nil
		end
	end
end

local function teleportToPlayer(name)
	name = name:lower()
	local target
	for _, p in Players:GetPlayers() do
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

local function getAllTools()
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then
		setStatus("❌ Backpack not found!")
		return
	end
	local added = 0
	for _, obj in game:GetDescendants() do
		if obj:IsA("Tool") then
			if obj.Parent ~= backpack and (not player.Character or obj.Parent ~= player.Character) then
				local clone = obj:Clone()
				if clone then
					clone.Parent = backpack
					added += 1
				end
			end
		end
	end
	setStatus("✅ Gave " .. added .. " tools!")
end

local function applyStats()
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = targets.WalkSpeed
		hum.JumpHeight = targets.JumpHeight
		hum.MaxHealth = targets.MaxHealth
		hum.Health = targets.MaxHealth
	end
	camera.FieldOfView = targets.FOV
end

player.CharacterAdded:Connect(function(char)
	task.wait(0.4)
	applyStats()
	if states.Fly then toggleFly(true) end
	if states.Noclip then toggleNoclip(true) end
	if states.GodMode then toggleGod(true) end
	if states.Spin then toggleSpin(true) end
end)

if player.Character then applyStats() end

-- ────────────────────────────────────────────────────────────────
-- UI Controls
-- ────────────────────────────────────────────────────────────────

local function createToggle(name, colorOn, colorOff, toggleFunc)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
	frame.Parent = cheatsScroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.18, 0, 0.8, 0)
	btn.Position = UDim2.new(0.02, 0, 0, 10)
	btn.BackgroundColor3 = colorOff
	btn.Text = "OFF"
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

	btn.MouseButton1Click:Connect(function()
		states[name] = not states[name]
		btn.BackgroundColor3 = states[name] and colorOn or colorOff
		btn.Text = states[name] and "ON" or "OFF"
		toggleFunc(states[name])
		setStatus(name .. (states[name] and " ON" or " OFF"))
	end)
end

local function createSlider(name, targetKey, default, min, max)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
	frame.Parent = cheatsScroll
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

-- Build toggles and sliders
createToggle("ESP", Color3.fromRGB(255, 80, 80), Color3.fromRGB(60, 60, 80), toggleESP)
createToggle("Aimbot", Color3.fromRGB(255, 100, 100), Color3.fromRGB(60, 60, 80), toggleAimbot)
createToggle("Fly", Color3.fromRGB(100, 200, 255), Color3.fromRGB(60, 60, 80), toggleFly)
createToggle("Noclip", Color3.fromRGB(255, 180, 100), Color3.fromRGB(60, 60, 80), toggleNoclip)
createToggle("Inf Jump", Color3.fromRGB(180, 120, 255), Color3.fromRGB(60, 60, 80), toggleInfJump)
createToggle("God Mode", Color3.fromRGB(255, 150, 100), Color3.fromRGB(60, 60, 80), toggleGod)
createToggle("Fullbright", Color3.fromRGB(255, 255, 140), Color3.fromRGB(60, 60, 80), toggleFullbright)
createToggle("Spin", Color3.fromRGB(220, 100, 220), Color3.fromRGB(60, 60, 80), toggleSpin)

createSlider("Spin Speed (°/s)", "SpinSpeed", 360, 0, 20000)
createSlider("Walk Speed", "WalkSpeed", 16, 0, 300)
createSlider("Jump Height", "JumpHeight", 7.2, 0, 500)
createSlider("Max Health", "MaxHealth", 100, 1, 10000)
createSlider("FOV", "FOV", 70, 10, 150)
createSlider("Fly Speed", "FlySpeed", 50, 10, 500)

-- ESP Default Color Picker (only used when no teams)
local colorFrame = Instance.new("Frame", cheatsScroll)
colorFrame.Size = UDim2.new(1, 0, 0, 50)
colorFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
Instance.new("UICorner", colorFrame).CornerRadius = UDim.new(0, 10)

local colorLabel = Instance.new("TextLabel", colorFrame)
colorLabel.Size = UDim2.new(0.45, 0, 1, 0)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "ESP Default Color (RGB):"
colorLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
colorLabel.Font = Enum.Font.GothamSemibold
colorLabel.TextSize = 16
colorLabel.TextXAlignment = Enum.TextXAlignment.Left

local colorInput = Instance.new("TextBox", colorFrame)
colorInput.Size = UDim2.new(0.3, 0, 0.7, 0)
colorInput.Position = UDim2.new(0.48, 0, 0.15, 0)
colorInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
colorInput.TextColor3 = Color3.new(1, 1, 1)
colorInput.Text = "0,255,100"
colorInput.Font = Enum.Font.Gotham
colorInput.TextSize = 16
Instance.new("UICorner", colorInput).CornerRadius = UDim.new(0, 8)

local setColorBtn = Instance.new("TextButton", colorFrame)
setColorBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
setColorBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
setColorBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 110)
setColorBtn.Text = "SET COLOR"
setColorBtn.TextColor3 = Color3.new(1, 1, 1)
setColorBtn.Font = Enum.Font.GothamBold
setColorBtn.TextSize = 15
Instance.new("UICorner", setColorBtn).CornerRadius = UDim.new(0, 8)

setColorBtn.MouseButton1Click:Connect(function()
	local text = colorInput.Text
	local r, g, b = text:match("^(%d+),%s*(%d+),%s*(%d+)$")
	r = tonumber(r) g = tonumber(g) b = tonumber(b)
	if r and g and b and r>=0 and r<=255 and g>=0 and g<=255 and b>=0 and b<=255 then
		defaultOutlineColor = Color3.fromRGB(r, g, b)
		setStatus("Default ESP color → " .. r .. "," .. g .. "," .. b)

		-- Update existing non-team highlights if ESP is on
		if states.ESP then
			for _, plr in Players:GetPlayers() do
				if plr.Character and not plr.Team then
					local h = plr.Character:FindFirstChild("PlayerHighlight")
					if h then
						h.OutlineColor = defaultOutlineColor
					end
				end
			end
		end
	else
		setStatus("Use format: R,G,B (0-255)")
		colorInput.Text = "0,255,100"
	end
end)

-- Teleport To
local tpToFrame = Instance.new("Frame", cheatsScroll)
tpToFrame.Size = UDim2.new(1, 0, 0, 50)
tpToFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
Instance.new("UICorner", tpToFrame).CornerRadius = UDim.new(0, 10)

local tpToLabel = Instance.new("TextLabel", tpToFrame)
tpToLabel.Size = UDim2.new(0.4, 0, 1, 0)
tpToLabel.BackgroundTransparency = 1
tpToLabel.Text = "Teleport To:"
tpToLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
tpToLabel.Font = Enum.Font.GothamSemibold
tpToLabel.TextSize = 16
tpToLabel.TextXAlignment = Enum.TextXAlignment.Left

local tpToInput = Instance.new("TextBox", tpToFrame)
tpToInput.Size = UDim2.new(0.35, 0, 0.8, 0)
tpToInput.Position = UDim2.new(0.42, 0, 0.1, 0)
tpToInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
tpToInput.TextColor3 = Color3.new(1, 1, 1)
tpToInput.PlaceholderText = "Player name"
tpToInput.Text = ""
tpToInput.Font = Enum.Font.Gotham
tpToInput.TextSize = 15
Instance.new("UICorner", tpToInput).CornerRadius = UDim.new(0, 8)

local tpToBtn = Instance.new("TextButton", tpToFrame)
tpToBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
tpToBtn.Position = UDim2.new(0.79, 0, 0.1, 0)
tpToBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
tpToBtn.Text = "Go"
tpToBtn.TextColor3 = Color3.new(1, 1, 1)
tpToBtn.Font = Enum.Font.GothamBold
tpToBtn.TextSize = 15
Instance.new("UICorner", tpToBtn).CornerRadius = UDim.new(0, 8)

tpToBtn.MouseButton1Click:Connect(function()
	local name = tpToInput.Text
	if name ~= "" then
		teleportToPlayer(name)
	else
		setStatus("Enter player name")
	end
end)

-- GET EVERY TOOL BUTTON
local toolsFrame = Instance.new("Frame", cheatsScroll)
toolsFrame.Size = UDim2.new(1, 0, 0, 60)
toolsFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
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

-- Final init
task.defer(function()
	task.wait(0.4)
	scanRemotes()
	if fireExampleBox then
		fireExampleBox.Text = "Scan complete - click remote or use FIRE ALL"
	end
	main.Visible = true
	TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.31, 0, 0.125, 0)
	}):Play()
	print("Diddy Cheats loaded V1")
	setStatus("Loaded")
end)

-- Toggle GUI - Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.PageUp then
		if main.Visible then
			TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Position = UDim2.new(0.31, 0, -1.2, 0)
			}):Play()
			task.delay(0.45, function()
				main.Visible = false
			end)
		else
			main.Visible = true
			TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.31, 0, 0.125, 0)
			}):Play()
		end
	end
end)



