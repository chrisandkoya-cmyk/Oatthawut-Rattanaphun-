--!strict
-- ตัวนับคอมโบตัวใหญ่สีแดง กลางซ้ายจอ: ขึ้นเมื่อโดนต่อเนื่อง 2 ครั้งขึ้นไป เลขเด้งทุกหมัด เลขยิ่งสูงยิ่งใหญ่
-- ค่ามาจาก Attribute ของผู้เล่น (ComboCount / ComboHitAt) ที่เซิร์ฟเวอร์ตั้ง แสดงผลอย่างเดียว

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.UI.Theme)
local Widgets = require(script.Parent.Parent.UI.Widgets)

local ComboCounter = {}

local player = Players.LocalPlayer

local MIN_SHOWN = 2 -- แสดงตั้งแต่คอมโบที่ 2
local HIDE_AFTER = 1.3 -- วินาทีหลังหมัดล่าสุดแล้วหาย
local RED = Color3.fromRGB(255, 56, 56)
local SETTLE = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function ComboCounter.start()
	local hud = player:WaitForChild("PlayerGui"):WaitForChild("CombatHud") :: ScreenGui

	local root = Widgets.new("Frame", {
		Name = "ComboCounter",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.03, 0.4),
		Size = UDim2.fromScale(0.2, 0.22),
		BackgroundTransparency = 1,
		Visible = false,
		Rotation = -5, -- เอียงนิดๆ ให้ดูดุ
	}, hud)
	Widgets.new("UISizeConstraint", { MinSize = Vector2.new(110, 80), MaxSize = Vector2.new(260, 150) }, root)
	local scale = Widgets.new("UIScale", { Scale = 1 }, root)

	local number = Widgets.label(root, {
		Font = Theme.FontPixel,
		TextColor3 = RED,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(20, 0, 0),
		Size = UDim2.fromScale(1, 0.7),
	}, 96)
	Widgets.label(root, {
		Text = "คอมโบ",
		Font = Theme.FontBold,
		TextColor3 = Color3.fromRGB(255, 220, 220),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeTransparency = 0.3,
		Size = UDim2.fromScale(0.7, 0.26),
		Position = UDim2.fromScale(0, 0.72),
	}, 28)

	local lastHitAt = 0

	local function onHit()
		local count = player:GetAttribute("ComboCount")
		if typeof(count) ~= "number" or count < MIN_SHOWN then
			root.Visible = false
			return
		end
		lastHitAt = os.clock()
		number.Text = tostring(count)
		root.Visible = true
		-- เด้งทุกหมัด แล้วตั้งขนาดตามเลข (สูงสุด 1.4 เท่า)
		local target = 1 + math.min(count, 30) / 75
		scale.Scale = target * 1.25
		TweenService:Create(scale, SETTLE, { Scale = target }):Play()
		local hitTime = lastHitAt
		task.delay(HIDE_AFTER, function()
			if lastHitAt == hitTime then
				root.Visible = false
			end
		end)
	end

	player:GetAttributeChangedSignal("ComboHitAt"):Connect(onHit)
	-- เกิดใหม่/เปลี่ยนตัว: ซ่อนทันที
	player:GetAttributeChangedSignal("CharacterId"):Connect(function()
		lastHitAt = 0
		root.Visible = false
	end)
end

return ComboCounter
