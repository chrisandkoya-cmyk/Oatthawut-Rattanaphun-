--!strict
-- HUD ชั่วคราว: เกจอันติ + ปุ่มบนมือถือ (ไว้เปลี่ยนเป็นดีไซน์จริงจาก Claude Design ทีหลัง)
-- ปุ่มมือถือจะแสดงเฉพาะอุปกรณ์สัมผัสที่ไม่มีคีย์บอร์ด

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared").Config)
local Input = require(script.Parent.Input)
local TouchLayout = require(script.Parent.Parent.UI.TouchLayout)

local Hud = {}

local SWIPE_UP_PIXELS = 40 -- ปัดนิ้วขึ้นเกินนี้ถือว่าตีเสย
local GAUGE_CELLS = 10
local HEALTH_CELLS = 4
local PRESS_TWEEN = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function isPress(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
end

local player = Players.LocalPlayer

local function makeButton(parent: Instance, text: string, spot: string, accent: Color3): TextButton
	local anchor, position, size = TouchLayout.place(spot)
	local button = Instance.new("TextButton")
	button.Name = text
	button.Text = text
	button.AnchorPoint = anchor
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
	button.BackgroundTransparency = 0.12
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBlack
	button.TextScaled = true
	button.AutoButtonColor = false
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0.22, 0)
	padding.PaddingBottom = UDim.new(0.22, 0)
	padding.PaddingLeft = UDim.new(0.12, 0)
	padding.PaddingRight = UDim.new(0.12, 0)
	padding.Parent = button
	local textLimit = Instance.new("UITextSizeConstraint")
	textLimit.MaxTextSize = 26
	textLimit.MinTextSize = 10
	textLimit.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = accent
	stroke.Thickness = 3
	stroke.Transparency = 0.1
	stroke.Parent = button
	local scale = Instance.new("UIScale")
	scale.Parent = button
	-- กดแล้วหดนิดเดียว ให้รู้ว่ารับนิ้วแล้ว
	button.InputBegan:Connect(function(input)
		if isPress(input) then
			TweenService:Create(scale, PRESS_TWEEN, { Scale = 0.9 }):Play()
			button.BackgroundTransparency = 0
		end
	end)
	button.InputEnded:Connect(function(input)
		if isPress(input) then
			TweenService:Create(scale, PRESS_TWEEN, { Scale = 1 }):Play()
			button.BackgroundTransparency = 0.12
		end
	end)
	button:SetAttribute("TouchSpot", spot)
	button.Parent = parent
	return button
end

local function buildHealth(gui: ScreenGui)
	-- แถบเลือดกลางบนจอ เขียว แบ่ง 4 ช่อง ขอบดำ (ตกต่ำกว่า 25% เป็นแดง)
	local bar = Instance.new("Frame")
	bar.Name = "HealthBar"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 8)
	bar.Size = UDim2.new(0.42, 0, 0, 28)
	bar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	bar.BorderSizePixel = 0
	bar.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MinSize = Vector2.new(280, 22)
	limit.MaxSize = Vector2.new(560, 32)
	limit.Parent = bar
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = bar
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 2
	stroke.Parent = bar

	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1, 1)
	holder.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 3)
	pad.PaddingBottom = UDim.new(0, 3)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = holder
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(1 / HEALTH_CELLS, -4, 1, 0)
	grid.CellPadding = UDim2.fromOffset(4, 0)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = holder
	local fills: { Frame } = {}
	for i = 1, HEALTH_CELLS do
		local cell = Instance.new("Frame")
		cell.BackgroundColor3 = Color3.fromRGB(30, 34, 40)
		cell.BorderSizePixel = 0
		cell.LayoutOrder = i
		cell.Parent = holder
		local cellFill = Instance.new("Frame")
		cellFill.Size = UDim2.fromScale(1, 1)
		cellFill.BackgroundColor3 = Color3.fromRGB(70, 225, 95)
		cellFill.BorderSizePixel = 0
		cellFill.Parent = cell
		fills[i] = cellFill
	end

	local connections: { RBXScriptConnection } = {}
	local function update(humanoid: Humanoid)
		local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
		local color = if ratio < 0.25 then Color3.fromRGB(255, 70, 70) else Color3.fromRGB(70, 225, 95)
		for i, cellFill in fills do
			cellFill.Size = UDim2.fromScale(math.clamp(ratio * HEALTH_CELLS - (i - 1), 0, 1), 1)
			cellFill.BackgroundColor3 = color
		end
	end
	local function bind(character: Model)
		for _, conn in connections do
			conn:Disconnect()
		end
		table.clear(connections)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not (humanoid and humanoid:IsA("Humanoid")) then
			return
		end
		table.insert(
			connections,
			humanoid.HealthChanged:Connect(function()
				update(humanoid)
			end)
		)
		table.insert(
			connections,
			humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
				update(humanoid)
			end)
		)
		update(humanoid)
	end
	player.CharacterAdded:Connect(bind)
	if player.Character then
		task.spawn(bind, player.Character)
	end
end

local function buildGauge(gui: ScreenGui)
	local bar = Instance.new("Frame")
	bar.Name = "UltBar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	-- ใต้แถบเลือดกลางบนจอ (ทั้ง PC และมือถือ) แบบเกม ABA
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 42)
	bar.Size = UDim2.new(0.42, 0, 0, 20)
	bar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	bar.BorderSizePixel = 0
	bar.Parent = gui
	local barSize = Instance.new("UISizeConstraint")
	barSize.MinSize = Vector2.new(280, 18)
	barSize.MaxSize = Vector2.new(560, 22)
	barSize.Parent = bar
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0.3, 0)
	barCorner.Parent = bar
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 200, 60)
	stroke.Thickness = 2
	stroke.Transparency = 0.4
	stroke.Parent = bar

	-- เกจแบ่งเป็นช่อง เติมจากซ้ายไปขวา (ช่องละ 10%)
	local cellsHolder = Instance.new("Frame")
	cellsHolder.BackgroundTransparency = 1
	cellsHolder.Size = UDim2.fromScale(1, 1)
	cellsHolder.Parent = bar
	local holderPadding = Instance.new("UIPadding")
	holderPadding.PaddingTop = UDim.new(0, 3)
	holderPadding.PaddingBottom = UDim.new(0, 3)
	holderPadding.PaddingLeft = UDim.new(0, 4)
	holderPadding.PaddingRight = UDim.new(0, 4)
	holderPadding.Parent = cellsHolder
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(1 / GAUGE_CELLS, -3, 1, 0)
	grid.CellPadding = UDim2.fromOffset(3, 0)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = cellsHolder
	local fills: { Frame } = {}
	for i = 1, GAUGE_CELLS do
		local cell = Instance.new("Frame")
		cell.BackgroundColor3 = Color3.fromRGB(48, 52, 72)
		cell.BorderSizePixel = 0
		cell.LayoutOrder = i
		cell.Parent = cellsHolder
		local cellCorner = Instance.new("UICorner")
		cellCorner.CornerRadius = UDim.new(0.25, 0)
		cellCorner.Parent = cell
		local cellFill = Instance.new("Frame")
		cellFill.Size = UDim2.fromScale(0, 1)
		cellFill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
		cellFill.BorderSizePixel = 0
		cellFill.Parent = cell
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0.25, 0)
		fillCorner.Parent = cellFill
		fills[i] = cellFill
	end

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.ZIndex = 3
	label.Parent = bar
	local labelSize = Instance.new("UITextSizeConstraint")
	labelSize.MaxTextSize = 14
	labelSize.MinTextSize = 8
	labelSize.Parent = label

	local pulse: Tween? = nil
	local function setPulse(active: boolean)
		if pulse then
			pulse:Cancel()
			pulse = nil
		end
		if active then
			stroke.Transparency = 0
			local tween = TweenService:Create(
				stroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Thickness = 5 }
			)
			pulse = tween
			tween:Play()
		else
			stroke.Thickness = 2
			stroke.Transparency = 0.4
		end
	end

	local lastState = ""
	local function update()
		local gauge = player:GetAttribute("UltGauge")
		local value = if typeof(gauge) == "number" then gauge else 0
		local ratio = math.clamp(value / Config.Ultimate.Max, 0, 1)
		for i, cellFill in fills do
			cellFill.Size = UDim2.fromScale(math.clamp(ratio * GAUGE_CELLS - (i - 1), 0, 1), 1)
		end
		local function paint(color: Color3)
			for _, cellFill in fills do
				cellFill.BackgroundColor3 = color
			end
		end
		local active = player:GetAttribute("UltEndsAt") ~= 0 and typeof(player:GetAttribute("UltEndsAt")) == "number"
		local full = ratio >= 1 and not active
		if active then
			paint(Color3.fromRGB(255, 120, 60))
			label.Text = "กำลังอันติ"
			label.TextColor3 = Color3.new(1, 1, 1)
		elseif full then
			paint(Color3.fromRGB(255, 255, 255))
			label.Text = if UserInputService.KeyboardEnabled
				then "พร้อม! กด G"
				else "พร้อม! แตะ อันติ"
			label.TextColor3 = Color3.fromRGB(30, 24, 8)
		else
			paint(Color3.fromRGB(255, 200, 60))
			label.Text = `อันติ {math.floor(ratio * 100)}%`
			label.TextColor3 = Color3.new(1, 1, 1)
		end
		local state = if active then "active" elseif full then "full" else "charging"
		if state ~= lastState then
			lastState = state
			setPulse(full)
		end
	end
	player:GetAttributeChangedSignal("UltGauge"):Connect(update)
	player:GetAttributeChangedSignal("UltEndsAt"):Connect(update)
	update()
end

local function buildTouchButtons(gui: ScreenGui)
	-- ปุ่มตี: แตะ = M1 (กลางอากาศเซิร์ฟเวอร์ใช้ตีกดเอง), ปัดขึ้น = ตีเสย
	local attackButton = makeButton(gui, "ตี", "Attack", Color3.fromRGB(255, 200, 60))
	local swipeHint = Instance.new("TextLabel")
	swipeHint.BackgroundTransparency = 1
	swipeHint.Text = "ปัดขึ้น = ตีเสย"
	swipeHint.Font = Enum.Font.GothamBold
	swipeHint.TextColor3 = Color3.fromRGB(235, 240, 255)
	swipeHint.TextStrokeTransparency = 0.4
	swipeHint.TextScaled = true
	swipeHint.AnchorPoint = Vector2.new(0.5, 1)
	swipeHint.Position = UDim2.fromScale(0.5, -0.06)
	swipeHint.Size = UDim2.fromScale(1.3, 0.2)
	swipeHint.Parent = attackButton
	local hintLimit = Instance.new("UITextSizeConstraint")
	hintLimit.MaxTextSize = 14
	hintLimit.MinTextSize = 8
	hintLimit.Parent = swipeHint

	local swipeStartY: number? = nil
	attackButton.InputBegan:Connect(function(input)
		if isPress(input) then
			swipeStartY = input.Position.Y
		end
	end)
	attackButton.InputEnded:Connect(function(input)
		if isPress(input) then
			local startY = swipeStartY
			swipeStartY = nil
			if startY then
				Input.attack(startY - input.Position.Y > SWIPE_UP_PIXELS)
			end
		end
	end)

	-- การ์ด: กดค้างเพื่อบล็อก ปล่อยเพื่อเลิก
	local blockButton = makeButton(gui, "การ์ด", "Block", Color3.fromRGB(90, 170, 255))
	blockButton.InputBegan:Connect(function(input)
		if isPress(input) then
			Input.block(true)
		end
	end)
	blockButton.InputEnded:Connect(function(input)
		if isPress(input) then
			Input.block(false)
		end
	end)

	-- แดช (ตอนโดนมึนอยู่และเกจพอ ปุ่มนี้คือ "หลุดคอมโบ" ตามกติกาเบิร์สต์ของเซิร์ฟเวอร์)
	local dashButton = makeButton(gui, "แดช", "Dash", Color3.fromRGB(120, 255, 200))
	dashButton.InputBegan:Connect(function(input)
		if isPress(input) then
			Input.dash()
		end
	end)

	local ultButton = makeButton(gui, "อันติ", "Ultimate", Color3.fromRGB(255, 120, 60))
	ultButton.InputBegan:Connect(function(input)
		if isPress(input) then
			Input.ultimate()
		end
	end)

	-- จอหมุน/เปลี่ยนขนาด: วางปุ่มใหม่
	TouchLayout.watch(function()
		for _, button in { attackButton, blockButton, dashButton, ultButton } do
			local spot = button:GetAttribute("TouchSpot")
			if typeof(spot) == "string" then
				local anchor, position, size = TouchLayout.place(spot)
				button.AnchorPoint = anchor
				button.Position = position
				button.Size = size
			end
		end
	end)

	local dashStroke = dashButton:FindFirstChildOfClass("UIStroke") :: UIStroke
	local ultStroke = ultButton:FindFirstChildOfClass("UIStroke") :: UIStroke
	local burstReady = false
	RunService.Heartbeat:Connect(function()
		local now = Workspace:GetServerTimeNow()
		-- สถานะปุ่มแดช: คูลดาวน์ / หลุดคอมโบ / ปกติ
		local gauge = player:GetAttribute("UltGauge")
		local stunnedUntil = player:GetAttribute("StunnedUntil")
		local stunned = typeof(stunnedUntil) == "number" and now < stunnedUntil
		local ultEnds = player:GetAttribute("UltEndsAt")
		local inUlt = typeof(ultEnds) == "number" and ultEnds > 0
		local burstReadyAt = player:GetAttribute("CdBurst")
		local burstWait = if typeof(burstReadyAt) == "number" then burstReadyAt - now else 0
		-- เงื่อนไขตรงกับเซิร์ฟเวอร์ (tryBurst): โดนมึน + เกจพอ + ไม่อยู่ในอันติ + ไม่ติดคูลดาวน์
		local canBurst = stunned
			and not inUlt
			and burstWait <= 0
			and typeof(gauge) == "number"
			and gauge >= Config.Burst.Cost
		local dashReadyAt = player:GetAttribute("CdDash")
		local dashWait = if typeof(dashReadyAt) == "number" then dashReadyAt - now else 0
		if canBurst ~= burstReady then
			burstReady = canBurst
			dashButton.Text = if canBurst then "หลุด!" else "แดช"
			dashStroke.Color = if canBurst then Color3.fromRGB(255, 80, 80) else Color3.fromRGB(120, 255, 200)
		end
		dashButton.TextTransparency = if not canBurst and dashWait > 0 then 0.55 else 0
		-- ปุ่มอันติสว่างเมื่อกดได้
		local ready = typeof(gauge) == "number" and gauge >= Config.Ultimate.Max and (ultEnds == nil or ultEnds == 0)
		ultButton.TextTransparency = if ready then 0 else 0.6
		ultStroke.Transparency = if ready then 0 else 0.7
	end)
end

function Hud.start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "CombatHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	buildHealth(gui)
	buildGauge(gui)
	if TouchLayout.isTouchOnly() then
		buildTouchButtons(gui)
	end
end

return Hud
