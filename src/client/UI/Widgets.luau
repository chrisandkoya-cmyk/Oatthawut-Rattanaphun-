--!strict
-- ชิ้นส่วน UI ที่ใช้ซ้ำ: tween ที่ยกเลิกอันเก่าให้, ปุ่มมี hover/กด/ปิดใช้งาน, ตัวช่วยสร้าง Instance

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local Widgets = {}

local live: { [Instance]: { [string]: Tween } } = {}

-- tween 1 property ต่อ 1 instance ยกเลิกอันเก่าก่อนเสมอ (กดรัวไม่ตีกัน)
function Widgets.tween(inst: Instance, info: TweenInfo, goal: { [string]: any })
	local perInst = live[inst]
	if not perInst then
		perInst = {}
		live[inst] = perInst
		inst.Destroying:Once(function()
			live[inst] = nil
		end)
	end
	local tweens = perInst :: { [string]: Tween }
	for prop, value in goal do
		local old = tweens[prop]
		if old then
			old:Cancel()
		end
		local t = TweenService:Create(inst, info, { [prop] = value })
		tweens[prop] = t
		t:Play()
	end
end

function Widgets.new(className: string, props: { [string]: any }, parent: Instance?): any
	local inst = Instance.new(className)
	for key, value in props do
		(inst :: any)[key] = value
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Widgets.corner(parent: Instance, radius: number?)
	Widgets.new("UICorner", { CornerRadius = UDim.new(radius or 0.2, 0) }, parent)
end

function Widgets.padding(parent: Instance, scale: number)
	local p = UDim.new(scale, 0)
	Widgets.new("UIPadding", { PaddingTop = p, PaddingBottom = p, PaddingLeft = p, PaddingRight = p }, parent)
end

-- ข้อความที่ย่อได้ตามจอ (มือถือไม่ล้น, จอใหญ่ไม่โตเกิน)
function Widgets.label(parent: Instance, props: { [string]: any }, maxSize: number?): TextLabel
	local label = Widgets.new("TextLabel", {
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		Font = Theme.FontBody,
		TextScaled = true,
		TextWrapped = true,
	}, parent)
	for key, value in props do
		label[key] = value
	end
	Widgets.new("UITextSizeConstraint", { MaxTextSize = maxSize or 28, MinTextSize = 8 }, label)
	return label
end

export type Button = {
	Instance: TextButton,
	SetEnabled: (enabled: boolean) -> (),
	SetText: (text: string) -> (),
}

-- ปุ่มมาตรฐาน: hover ขยายนิด, กดหด, ปิดใช้งานแล้วสีจาง
function Widgets.button(parent: Instance, text: string, primary: boolean, onClick: () -> ()): Button
	local button = Widgets.new("TextButton", {
		Text = text,
		AutoButtonColor = false,
		BackgroundColor3 = if primary then Theme.Accent else Theme.PanelLight,
		TextColor3 = if primary then Color3.fromRGB(30, 24, 8) else Theme.Text,
		Font = Theme.FontBold,
		TextScaled = true,
		BorderSizePixel = 0,
	}, parent)
	Widgets.corner(button, 0.25)
	Widgets.new("UITextSizeConstraint", { MaxTextSize = 26, MinTextSize = 8 }, button)
	Widgets.new("UISizeConstraint", { MinSize = Vector2.new(0, Theme.MinTouch) }, button)
	Widgets.padding(button, 0.12)
	local stroke = Widgets.new("UIStroke", {
		Color = if primary then Color3.fromRGB(255, 235, 170) else Theme.Muted,
		Transparency = if primary then 0.2 else 0.7,
		Thickness = 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, button)
	local scale = Widgets.new("UIScale", { Scale = 1 }, button)

	local enabled = true
	local hovering = false
	local function refresh(pressed: boolean)
		local target = 1
		if not enabled then
			target = 1
		elseif pressed then
			target = 0.95
		elseif hovering then
			target = 1.04
		end
		Widgets.tween(scale, Theme.Fast, { Scale = target })
		Widgets.tween(stroke, Theme.Fast, { Transparency = if hovering and enabled then 0 else (if primary then 0.2 else 0.7) })
	end

	button.MouseEnter:Connect(function()
		hovering = true
		refresh(false)
	end)
	button.MouseLeave:Connect(function()
		hovering = false
		refresh(false)
	end)
	button.MouseButton1Down:Connect(function()
		refresh(true)
	end)
	button.MouseButton1Up:Connect(function()
		refresh(false)
	end)
	button.Activated:Connect(function()
		if enabled then
			onClick()
		end
	end)

	return {
		Instance = button,
		SetEnabled = function(value: boolean)
			enabled = value
			button.Active = value
			Widgets.tween(button, Theme.Fast, {
				BackgroundTransparency = if value then 0 else 0.6,
				TextTransparency = if value then 0 else 0.5,
			})
		end,
		SetText = function(value: string)
			button.Text = value
		end,
	}
end

return Widgets
