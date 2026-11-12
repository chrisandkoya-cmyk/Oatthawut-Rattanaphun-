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

-- ภาษาไทยไม่มีเว้นวรรค ข้อความยาวจึงไม่ตัดบรรทัดเอง (ย่อตัวอักษรแทน) ฟังก์ชันนี้แทรก \n ตรงกลางชื่อที่ยาว
-- โดยไม่ตัดกลางพยางค์: สระ/วรรณยุกต์ที่อยู่บน-ล่างต้องอยู่กับพยัญชนะ และสระนำ (เ แ โ ใ ไ) ต้องอยู่กับตัวถัดไป
local function isThaiCombining(cp: number): boolean
	return cp == 0x0E31 or (cp >= 0x0E34 and cp <= 0x0E3A) or (cp >= 0x0E47 and cp <= 0x0E4E)
end

-- สระตามหลังที่กินที่ (ะ า ำ ๅ) และ ๆ ต้องติดกับพยัญชนะหน้า
local function isThaiTrailing(cp: number): boolean
	return cp == 0x0E30 or cp == 0x0E32 or cp == 0x0E33 or cp == 0x0E45 or cp == 0x0E46
end

local function isThaiLeading(cp: number): boolean
	return cp >= 0x0E40 and cp <= 0x0E44
end

function Widgets.breakLong(text: string, maxPerLine: number): string
	local length = utf8.len(text)
	if not length or length <= maxPerLine or string.find(text, "\n", 1, true) then
		return text
	end
	local codes = { utf8.codepoint(text, 1, -1) }
	-- นับเฉพาะตัวฐาน (ไม่นับสระ/วรรณยุกต์ที่ซ้อน) หาตำแหน่งกึ่งกลาง
	local bases = 0
	for _, cp in codes do
		if not isThaiCombining(cp) then
			bases += 1
		end
	end
	local target = math.ceil(bases / 2)
	local split = #codes
	local seen = 0
	for i, cp in codes do
		if not isThaiCombining(cp) then
			seen += 1
		end
		if seen >= target then
			split = i
			break
		end
	end
	while split > 1 and isThaiLeading(codes[split]) do
		split -= 1
	end
	while split < #codes and (isThaiCombining(codes[split + 1]) or isThaiTrailing(codes[split + 1])) do
		split += 1
	end
	if split >= #codes then
		return text
	end
	return utf8.char(table.unpack(codes, 1, split)) .. "\n" .. utf8.char(table.unpack(codes, split + 1))
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

-- แผงเหลี่ยมมุมมนนิดเดียว (วงกลมจริงๆ เมื่อ radius >= 0.9)
function Widgets.corner(parent: Instance, radius: number?)
	if radius and radius >= 0.9 then
		Widgets.new("UICorner", { CornerRadius = UDim.new(radius, 0) }, parent)
	else
		Widgets.new("UICorner", { CornerRadius = UDim.new(0, 4) }, parent)
	end
end

-- ขอบแดงเข้มของแผง
function Widgets.border(parent: Instance, color: Color3?, thickness: number?)
	return Widgets.new("UIStroke", {
		Color = color or Theme.Crimson,
		Thickness = thickness or 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
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
		BackgroundColor3 = if primary then Color3.fromRGB(36, 120, 52) else Theme.Panel,
		TextColor3 = if primary then Color3.fromRGB(120, 255, 140) else Theme.Text,
		Font = Theme.FontBold,
		TextScaled = true,
		BorderSizePixel = 0,
	}, parent)
	Widgets.corner(button, 0.25)
	Widgets.new("UITextSizeConstraint", { MaxTextSize = 34, MinTextSize = 8 }, button)
	Widgets.new("UISizeConstraint", { MinSize = Vector2.new(0, Theme.MinTouch) }, button)
	Widgets.padding(button, 0.12)
	local stroke = Widgets.new("UIStroke", {
		Color = if primary then Color3.fromRGB(12, 70, 24) else Theme.Crimson,
		Transparency = 0,
		Thickness = 2,
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
		Widgets.tween(stroke, Theme.Fast, { Thickness = if hovering and enabled then 3 else 2 })
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
