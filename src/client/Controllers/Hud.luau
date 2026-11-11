--!strict
-- HUD ชั่วคราว: เกจอันติ + ปุ่มบนมือถือ (ไว้เปลี่ยนเป็นดีไซน์จริงจาก Claude Design ทีหลัง)
-- ปุ่มมือถือจะแสดงเฉพาะอุปกรณ์สัมผัสที่ไม่มีคีย์บอร์ด

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	bar.Position = UDim2.new(0.5, 0, 1, -16)
	bar.Size = UDim2.new(0.3, 0, 0, 14)
	bar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	bar.BorderSizePixel = 0
	bar.Parent = gui

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local function update()
		local gauge = player:GetAttribute("UltGauge")
		local value = if typeof(gauge) == "number" then gauge else 0
		fill.Size = UDim2.fromScale(math.clamp(value / Config.Ultimate.Max, 0, 1), 1)
		local full = value >= Config.Ultimate.Max and player:GetAttribute("UltEndsAt") == 0
		fill.BackgroundColor3 = if full then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(255, 200, 60)
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
