--!strict
-- หน้าเลือกตัวละคร: การ์ดตัวละคร + พรีวิว 3D (ViewportFrame) + ชื่อสกิลทั้ง 4 + อันติ
-- ข้อมูลทั้งหมดมาจาก CharacterInfo (ชื่อไทย/สี/สกิล) ส่วนโมเดลพรีวิวไม่บังคับ:
-- วางโมเดลไว้ที่ ReplicatedStorage/Assets/Previews/<id> ถ้าไม่มีจะแสดงตัวอักษรแทน

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	-- แถบบน
	local top = Widgets.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.94, 0.11),
		Position = UDim2.fromScale(0.03, 0.03),
	}, parent)
	local back = Widgets.button(top, "< กลับ", false, onBack)
	back.Instance.Size = UDim2.fromScale(0.16, 1)
	Widgets.label(top, {
		Text = "เลือกนักสู้",
		Font = Theme.FontTitle,
		Size = UDim2.fromScale(0.5, 1),
		Position = UDim2.fromScale(0.25, 0),
	}, 40)

	-- พรีวิว
	local previewBox = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.38, 0.56),
		Position = UDim2.fromScale(0.03, 0.16),
	}, parent)
	Widgets.corner(previewBox, 0.06)
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

	-- ข้อมูลตัวละคร
	local info = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.53, 0.56),
		Position = UDim2.fromScale(0.44, 0.16),
	}, parent)
	Widgets.corner(info, 0.04)
	Widgets.padding(info, 0.03)
	local nameLabel = Widgets.label(info, {
		Font = Theme.FontTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(1, 0.15),
	}, 38)
	local descLabel = Widgets.label(info, {
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.fromScale(1, 0.15),
		Position = UDim2.fromScale(0, 0.16),
	}, 18)

	local skillList = Widgets.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.4),
		Position = UDim2.fromScale(0, 0.33),
	}, info)
	Widgets.new("UIGridLayout", {
		CellSize = UDim2.fromScale(0.49, 0.3),
		CellPadding = UDim2.fromScale(0.02, 0.05),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, skillList)
	local skillLabels: { TextLabel } = {}
	for i = 1, 5 do
		local row = Widgets.new("Frame", {
			BackgroundColor3 = Theme.PanelLight,
			BorderSizePixel = 0,
			LayoutOrder = i,
		}, skillList)
		Widgets.corner(row, 0.25)
		Widgets.padding(row, 0.06)
		table.insert(
			skillLabels,
			Widgets.label(row, { TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.fromScale(1, 1) }, 18)
		)
	end

	local chooseButton = Widgets.button(info, "เลือกตัวนี้", true, function()
		if focusedId then
			onChoose(focusedId)
		end
	end)
	chooseButton.Instance.AnchorPoint = Vector2.new(1, 1)
	chooseButton.Instance.Position = UDim2.fromScale(1, 1)
	chooseButton.Instance.Size = UDim2.fromScale(0.5, 0.2)

	-- แถบการ์ด
	local strip = Widgets.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.94, 0.23),
		Position = UDim2.fromScale(0.03, 0.75),
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 4,
	}, parent)
	Widgets.new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, strip)
	Widgets.new(
		"UIPadding",
		{ PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 4) },
		strip
	)

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
		spinModel = nil
		viewport:ClearAllChildren()
		local model = findPreviewModel(character.id)
		glyph.Visible = model == nil
		if model then
			spinModel = frameModel(viewport, model)
		end
		refreshButton()
	end

	for index, character in roster do
		local card = Widgets.new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			LayoutOrder = index,
		}, strip)
		Widgets.corner(card, 0.1)
		Widgets.new("UIAspectRatioConstraint", { AspectRatio = 1.1 }, card)
		local stroke = Widgets.new("UIStroke", { Color = character.color, Thickness = 3, Transparency = 0.8 }, card)
		local bar = Widgets.new("Frame", {
			BackgroundColor3 = character.color,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0.1),
		}, card)
		Widgets.corner(bar, 0.5)
		Widgets.label(card, {
			Text = initial(character.displayName),
			Font = Theme.FontTitle,
			TextColor3 = character.color,
			Size = UDim2.fromScale(0.5, 0.45),
			Position = UDim2.fromScale(0.25, 0.15),
		}, 60)
		Widgets.label(card, {
			Text = character.displayName,
			Font = Theme.FontBold,
			Size = UDim2.fromScale(0.9, 0.2),
			Position = UDim2.fromScale(0.05, 0.62),
		}, 20)
		local tag = Widgets.label(card, {
			Text = "ใช้อยู่",
			TextColor3 = Theme.Accent,
			Size = UDim2.fromScale(0.6, 0.12),
			Position = UDim2.fromScale(0.2, 0.84),
			Visible = false,
		}, 14)
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
