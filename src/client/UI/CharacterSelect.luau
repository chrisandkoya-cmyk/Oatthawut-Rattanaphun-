--!strict
-- หน้าเลือกตัวละคร: การ์ดตัวละคร + พรีวิว 3D (ViewportFrame) + ชื่อสกิลทั้ง 4 + อันติ
-- ข้อมูลทั้งหมดมาจาก CharacterInfo (ชื่อไทย/สี/สกิล) ส่วนโมเดลพรีวิวไม่บังคับ:
-- วางโมเดลไว้ที่ ReplicatedStorage/Assets/Previews/<id> (หันหน้าไปทาง -Z แบบ Roblox ปกติ)
-- ถ้าไม่มี จะสร้างหุ่น R15 แล้วใส่หน้าตาจาก Shared/Appearance/<id> เหมือนในเกม
-- ถ้าสร้างไม่ได้ แสดงตัวอักษรแทน

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Roster = require(script.Parent.Roster)
local Theme = require(script.Parent.Theme)
local Widgets = require(script.Parent.Widgets)

local CharacterSelect = {}

export type Handle = {
	setActive: (active: boolean) -> (),
	setChosen: (id: string?) -> (),
}

local SPIN_SPEED = math.rad(35)

-- ตัวอักษรแรก (รองรับภาษาไทย: ตัดตามตัวอักษร ไม่ใช่ตามไบต์)
local function initial(name: string): string
	if name == "" then
		return "?"
	end
	return string.upper(utf8.char(utf8.codepoint(name, 1)))
end

local rigCache: { [string]: Model } = {}

-- หุ่น R15 + หน้าตาตัวละคร (ปกติ) สำหรับพรีวิว คืน nil ถ้าสร้างไม่ได้
local function buildRigPreview(id: string): Model?
	local cached = rigCache[id]
	if cached then
		return cached
	end
	local appearance = ReplicatedStorage:FindFirstChild("Shared")
		and ReplicatedStorage.Shared:FindFirstChild("Appearance")
	local module = appearance and appearance:FindFirstChild(id)
	local builderModule = appearance and appearance:FindFirstChild("Builder")
	if not (module and module:IsA("ModuleScript") and builderModule and builderModule:IsA("ModuleScript")) then
		return nil
	end
	local ok, rig = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	end)
	if not ok or not rig then
		return nil
	end
	local applied = pcall(function()
		local looks = require(module) :: any
		local builder = require(builderModule) :: any
		builder.apply(rig, looks.base)
	end)
	if not applied then
		rig:Destroy()
		return nil
	end
	rigCache[id] = rig
	return rig
end

local function findPreviewModel(id: string): Model?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local previews = assets and assets:FindFirstChild("Previews")
	local model = previews and previews:FindFirstChild(id)
	if model and model:IsA("Model") then
		return model
	end
	return nil
end

-- ตั้งกล้องใน ViewportFrame ให้เห็นทั้งโมเดล โดยคำนวณจากขนาดกล่อง ไม่ใช้ตัวเลขตายตัว
local function frameModel(viewport: ViewportFrame, model: Model): Model
	local clone = model:Clone()
	-- หันหน้าเข้ากล้อง (โมเดลหันไปทาง -Z กล้องอยู่ฝั่ง +Z)
	clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.pi, 0))
	clone.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	viewport.CurrentCamera = camera
	camera.Parent = viewport
	local cf, size = clone:GetBoundingBox()
	local distance = (size.Magnitude * 0.5) / math.tan(math.rad(camera.FieldOfView) * 0.5) * 1.1
	camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0, size.Y * 0.1, distance), cf.Position)
	return clone
end

function CharacterSelect.build(parent: GuiObject, onBack: () -> (), onChoose: (id: string) -> ()): Handle
	local roster = Roster.list()
	local chosenId: string? = nil
	local focusedId: string? = nil
	local spinModel: Model? = nil
	local spinConn: RBXScriptConnection? = nil
	local previewToken = 0

	-- หัวข้อ
	Widgets.label(parent, {
		Text = "เลือกนักสู้",
		Font = Theme.FontTitle,
		TextColor3 = Theme.Red,
		TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -2,
		Size = UDim2.fromScale(0.45, 0.09),
		Position = UDim2.fromScale(0.03, 0.03),
	}, 44)

	-- พรีวิวตัวละคร (ซ้าย)
	local previewBox = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.45, 0.5),
		Position = UDim2.fromScale(0.03, 0.14),
	}, parent)
	Widgets.corner(previewBox, 0.05)
	local previewStroke =
		Widgets.new("UIStroke", { Color = Theme.Accent, Thickness = 2, Transparency = 0.3 }, previewBox)
	local viewport = Widgets.new("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Ambient = Color3.fromRGB(170, 170, 190),
		LightColor = Color3.new(1, 1, 1),
	}, previewBox)
	local glyph = Widgets.label(previewBox, {
		Font = Theme.FontTitle,
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.25, 0.2),
		TextTransparency = 0.1,
	}, 140)

	-- ชื่อ + คำอธิบาย (ซ้ายล่าง)
	local nameBox = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.45, 0.26),
		Position = UDim2.fromScale(0.03, 0.67),
	}, parent)
	Widgets.corner(nameBox, 0.08)
	Widgets.padding(nameBox, 0.04)
	local nameLabel = Widgets.label(nameBox, {
		Font = Theme.FontTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(1, 0.38),
	}, 36)
	local descLabel = Widgets.label(nameBox, {
		TextColor3 = Color3.fromRGB(200, 208, 232),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.fromScale(1, 0.58),
		Position = UDim2.fromScale(0, 0.42),
	}, 20)

	-- ไอคอนตัวละครกลมเรียงขวาบน
	local strip = Widgets.new("ScrollingFrame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.45, 0.3),
		Position = UDim2.fromScale(0.52, 0.14),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 4,
	}, parent)
	Widgets.corner(strip, 0.06)
	Widgets.new("UIGridLayout", {
		CellSize = UDim2.fromOffset(72, 96),
		CellPadding = UDim2.fromOffset(10, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, strip)
	Widgets.new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 8),
	}, strip)

	-- รายการท่า (ขวากลาง)
	local skillList = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.45, 0.34),
		Position = UDim2.fromScale(0.52, 0.46),
	}, parent)
	Widgets.corner(skillList, 0.06)
	Widgets.padding(skillList, 0.03)
	Widgets.new("UIListLayout", { Padding = UDim.new(0.02, 0), SortOrder = Enum.SortOrder.LayoutOrder }, skillList)
	local skillLabels: { TextLabel } = {}
	for i = 1, 5 do
		local row = Widgets.new("Frame", {
			BackgroundColor3 = Theme.PanelLight,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.17, 0),
			LayoutOrder = i,
		}, skillList)
		Widgets.corner(row, 0.25)
		Widgets.padding(row, 0.08)
		table.insert(
			skillLabels,
			Widgets.label(row, { TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.fromScale(1, 1) }, 20)
		)
	end

	-- ปุ่มล่างขวา: กลับ + เลือก (สีเขียว)
	local bottom = Widgets.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.45, 0.13),
		Position = UDim2.fromScale(0.52, 0.83),
	}, parent)
	local back = Widgets.button(bottom, "< กลับ", false, onBack)
	back.Instance.Size = UDim2.fromScale(0.38, 1)
	local chooseButton = Widgets.button(bottom, "เลือกตัวนี้", true, function()
		if focusedId then
			onChoose(focusedId)
		end
	end)
	chooseButton.Instance.AnchorPoint = Vector2.new(1, 0)
	chooseButton.Instance.Position = UDim2.fromScale(1, 0)
	chooseButton.Instance.Size = UDim2.fromScale(0.58, 1)
	chooseButton.Instance.BackgroundColor3 = Theme.Green
	chooseButton.Instance.TextColor3 = Color3.fromRGB(8, 30, 14)

	local cards: { [string]: { Button: TextButton, Stroke: UIStroke, Tag: TextLabel } } = {}

	local function refreshButton()
		if focusedId == nil then
			chooseButton.SetEnabled(false)
		elseif focusedId == chosenId then
			chooseButton.SetText("ใช้ตัวนี้อยู่")
			chooseButton.SetEnabled(false)
		else
			chooseButton.SetText("เลือกตัวนี้")
			chooseButton.SetEnabled(true)
		end
		for id, card in cards do
			card.Tag.Visible = id == chosenId
			local isFocus = id == focusedId
			Widgets.tween(card.Stroke, Theme.Fast, { Transparency = if isFocus then 0 else 0.8 })
		end
	end

	local function stopSpin()
		if spinConn then
			spinConn:Disconnect()
			spinConn = nil
		end
	end

	local function focus(character: any)
		focusedId = character.id
		nameLabel.Text = character.displayName
		descLabel.Text = character.description
		for i = 1, 4 do
			skillLabels[i].Text = `{i}  {character.skillNames[i] or "-"}`
		end
		skillLabels[5].Text = `อันติ  {character.ultimate.name}`
		skillLabels[5].TextColor3 = Theme.Accent
		glyph.Text = initial(character.displayName)
		glyph.TextColor3 = character.color
		previewStroke.Color = character.color
		Widgets.tween(previewStroke, Theme.Fast, { Thickness = 3 })

		-- เปลี่ยนพรีวิว (ลูปหมุนอ่าน spinModel ล่าสุดเอง)
		previewToken += 1
		local token = previewToken
		spinModel = nil
		viewport:ClearAllChildren()
		glyph.Visible = true
		task.spawn(function()
			local model = findPreviewModel(character.id) or buildRigPreview(character.id)
			if token ~= previewToken or not model then
				return -- เลือกตัวอื่นไปแล้ว หรือสร้างไม่ได้ (ใช้ตัวอักษรแทน)
			end
			spinModel = frameModel(viewport, model)
			glyph.Visible = false
		end)
		refreshButton()
	end

	for index, character in roster do
		local card = Widgets.new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = index,
		}, strip)
		local circle = Widgets.new("Frame", {
			BackgroundColor3 = Theme.PanelLight,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(64, 64),
			Position = UDim2.new(0.5, -32, 0, 2),
		}, card)
		Widgets.corner(circle, 1)
		local stroke = Widgets.new("UIStroke", { Color = character.color, Thickness = 3, Transparency = 0.8 }, circle)
		Widgets.label(circle, {
			Text = initial(character.displayName),
			Font = Theme.FontTitle,
			TextColor3 = character.color,
			Size = UDim2.fromScale(0.6, 0.6),
			Position = UDim2.fromScale(0.2, 0.2),
		}, 34)
		Widgets.label(card, {
			Text = character.displayName,
			Font = Theme.FontBold,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, 68),
		}, 14)
		local tag = Widgets.label(card, {
			Text = "ใช้อยู่",
			TextColor3 = Theme.Accent,
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.new(0, 0, 0, 80),
			Visible = false,
		}, 11)
		card.Activated:Connect(function()
			focus(character)
		end)
		cards[character.id] = { Button = card, Stroke = stroke, Tag = tag }
	end

	if #roster == 0 then
		nameLabel.Text = "ยังไม่มีตัวละคร"
		chooseButton.SetEnabled(false)
	else
		focus(roster[1])
	end

	local handle: Handle = {
		setActive = function(active: boolean)
			stopSpin()
			if not active then
				return
			end
			spinConn = RunService.RenderStepped:Connect(function(dt)
				local model = spinModel
				if model then
					model:PivotTo(model:GetPivot() * CFrame.Angles(0, SPIN_SPEED * dt, 0))
				end
			end)
		end,
		setChosen = function(id: string?)
			chosenId = id
			refreshButton()
		end,
	}
	return handle
end

return CharacterSelect
