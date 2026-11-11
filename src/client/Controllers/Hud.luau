--!strict
-- HUD ชั่วคราว: เกจอันติ + ปุ่มบนมือถือ (ไว้เปลี่ยนเป็นดีไซน์จริงจาก Claude Design ทีหลัง)
-- ปุ่มมือถือจะแสดงเฉพาะอุปกรณ์สัมผัสที่ไม่มีคีย์บอร์ด

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared").Config)
local Input = require(script.Parent.Input)

local Hud = {}

local SWIPE_UP_PIXELS = 40 -- ปัดนิ้วขึ้นเกินนี้ถือว่าตีเสย

local player = Players.LocalPlayer

local function makeButton(parent: Instance, text: string, position: UDim2, size: UDim2): TextButton
	local button = Instance.new("TextButton")
	button.Text = text
	button.Position = position
	button.Size = size
	button.AnchorPoint = Vector2.new(1, 1)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	button.BackgroundTransparency = 0.25
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.AutoButtonColor = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button
	button.Parent = parent
	return button
end

local function buildGauge(gui: ScreenGui)
	local bar = Instance.new("Frame")
	bar.Name = "UltBar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.new(0.5, 0, 1, -12)
	bar.Size = UDim2.new(0.44, 0, 0, 26)
	bar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	bar.BorderSizePixel = 0
	bar.Parent = gui
	local barSize = Instance.new("UISizeConstraint")
	barSize.MinSize = Vector2.new(260, 24)
	barSize.MaxSize = Vector2.new(560, 30)
	barSize.Parent = bar
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0.5, 0)
	barCorner.Parent = bar
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 200, 60)
	stroke.Thickness = 2
	stroke.Transparency = 0.4
	stroke.Parent = bar

	-- ส่วนเติม อยู่ใน Frame ที่ตัดขอบมนเพื่อไม่ให้ล้นขอบ
	local clip = Instance.new("CanvasGroup")
	clip.Size = UDim2.fromScale(1, 1)
	clip.BackgroundTransparency = 1
	clip.Parent = bar
	local clipCorner = Instance.new("UICorner")
	clipCorner.CornerRadius = UDim.new(0.5, 0)
	clipCorner.Parent = clip

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	fill.BorderSizePixel = 0
	fill.Parent = clip

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
	labelSize.MaxTextSize = 18
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
		fill.Size = UDim2.fromScale(ratio, 1)
		local active = player:GetAttribute("UltEndsAt") ~= 0 and typeof(player:GetAttribute("UltEndsAt")) == "number"
		local full = ratio >= 1 and not active
		if active then
			fill.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
			label.Text = "กำลังอันติ"
		elseif full then
			fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			label.Text = if UserInputService.KeyboardEnabled
				then "อันติพร้อม! กด G"
				else "อันติพร้อม! แตะ อันติ"
			label.TextColor3 = Color3.fromRGB(30, 24, 8)
		else
			fill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
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
	local function add(
		text: string,
		x: number,
		y: number,
		size: number,
		onBegan: () -> (),
		onEnded: (() -> ())?
	): TextButton
		local button = makeButton(gui, text, UDim2.new(1, -x, 1, -y), UDim2.fromOffset(size, size))
		button.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1
			then
				onBegan()
			end
		end)
		if onEnded then
			button.InputEnded:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
				then
					(onEnded :: () -> ())()
				end
			end)
		end
		return button
	end

	-- ปุ่มตี: แตะ = M1 (ถ้าอยู่กลางอากาศเซิร์ฟเวอร์จะใช้ตีกดเอง), ปัดขึ้น = ตีเสย
	local attackButton = add("ตี", 150, 40, 84, function() end)
	local swipeStartY: number? = nil
	attackButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			swipeStartY = input.Position.Y
		end
	end)
	attackButton.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			local startY = swipeStartY
			swipeStartY = nil
			if startY then
				Input.attack(startY - input.Position.Y > SWIPE_UP_PIXELS)
			end
		end
	end)
	add("การ์ด", 40, 40, 70, function()
		Input.block(true)
	end, function()
		Input.block(false)
	end)
	add("แดช", 40, 125, 60, function()
		Input.dash()
	end)
	add("อันติ", 120, 135, 60, function()
		Input.ultimate()
	end)
	-- ปุ่มสกิล 1-4 อยู่ในแถบสกิล (Controllers/SkillBar) ทั้ง PC และมือถือ
end

function Hud.start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "CombatHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	buildGauge(gui)
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		buildTouchButtons(gui)
	end
end

return Hud
