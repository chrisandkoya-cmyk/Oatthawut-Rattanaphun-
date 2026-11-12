--!strict
-- แถบสกิล 1-4: ชื่อท่า (ภาษาไทยจาก CharacterInfo) + คูลดาวน์ + แตะ/คลิกใช้ได้ (PC และมือถือ)
-- คูลดาวน์อ่านจาก Attribute ที่เซิร์ฟเวอร์ตั้งบน Player (CdS1..CdS4 / CdU1..CdU4 = เวลาเซิร์ฟเวอร์ที่ใช้ได้อีกครั้ง)
-- ร่างอันติ (UltEndsAt > 0) จะสลับเป็นชื่อท่าชุดอันติเอง ตัวเลขที่แสดงเป็นแค่ข้อมูล เซิร์ฟเวอร์ตัดสินจริง

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Input = require(script.Parent.Input)
local Roster = require(script.Parent.Parent.UI.Roster)
local Theme = require(script.Parent.Parent.UI.Theme)
local TouchLayout = require(script.Parent.Parent.UI.TouchLayout)
local Widgets = require(script.Parent.Parent.UI.Widgets)

local SkillBar = {}

local player = Players.LocalPlayer

type Slot = {
	button: TextButton,
	stroke: UIStroke,
	name: TextLabel,
	cover: Frame,
	timeLabel: TextLabel,
	total: number, -- คูลดาวน์เต็มของครั้งล่าสุดที่เห็น (ใช้คำนวณความยาวแถบ)
	lastEnd: number,
}

function SkillBar.start()
	local hud = player:WaitForChild("PlayerGui"):WaitForChild("CombatHud") :: ScreenGui

	local infos: { [string]: any } = {}
	for _, info in Roster.list() do
		infos[info.id] = info
	end

	local touch = TouchLayout.isTouchOnly()
	local bar = Widgets.new("Frame", {
		Name = "SkillBar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		Size = UDim2.fromScale(0.44, 0.17),
		BackgroundTransparency = 1,
	}, hud)
	if touch then
		-- มือถือ: ปุ่มสกิล 2x2 ใหญ่พอให้นิ้วกด อยู่ซ้ายของปุ่มตี ไม่ทับปุ่มกระโดด
		local anchor, position, size, cell, gap = TouchLayout.skillGrid()
		bar.AnchorPoint = anchor
		bar.Position = position
		bar.Size = size
		local grid = Widgets.new("UIGridLayout", {
			CellSize = cell,
			CellPadding = gap,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, bar)
		TouchLayout.watch(function()
			local a2, p2, s2, c2, g2 = TouchLayout.skillGrid()
			bar.AnchorPoint = a2
			bar.Position = p2
			bar.Size = s2
			grid.CellSize = c2
			grid.CellPadding = g2
		end)
	else
		Widgets.new("UISizeConstraint", { MinSize = Vector2.new(260, 58), MaxSize = Vector2.new(560, 96) }, bar)
		Widgets.new("UIGridLayout", {
			CellSize = UDim2.new(0.23, 0, 1, 0),
			CellPadding = UDim2.new(0.0267, 0, 0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, bar)
	end

	local slots: { Slot } = {}
	for i = 1, 4 do
		local button = Widgets.new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(150, 22, 34),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			LayoutOrder = i,
			ClipsDescendants = true,
		}, bar)
		Widgets.corner(button, 0.18)
		local stroke = Widgets.new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2 }, button)
		Widgets.label(button, {
			Text = tostring(i),
			Font = Theme.FontTitle,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(0.3, 0.32),
			Position = UDim2.fromScale(0.07, 0.04),
		}, 20)
		local nameLabel = Widgets.label(button, {
			Font = Theme.FontBold,
			Size = UDim2.fromScale(0.92, 0.5),
			Position = UDim2.fromScale(0.04, 0.42),
		}, 18)
		local cover = Widgets.new("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			Visible = false,
			ZIndex = 5,
		}, button)
		local timeLabel = Widgets.label(button, {
			Font = Theme.FontTitle,
			Size = UDim2.fromScale(0.8, 0.5),
			Position = UDim2.fromScale(0.1, 0.25),
			Visible = false,
			ZIndex = 6,
		}, 28)
		button.Activated:Connect(function()
			Input.skill(i)
		end)
		slots[i] = {
			button = button,
			stroke = stroke,
			name = nameLabel,
			cover = cover,
			timeLabel = timeLabel,
			total = 1,
			lastEnd = 0,
		}
	end

	local function currentInfo(): any?
		local id = player:GetAttribute("CharacterId")
		return if typeof(id) == "string" then infos[id] else nil
	end

	local function inUltimate(): boolean
		local ends = player:GetAttribute("UltEndsAt")
		return typeof(ends) == "number" and ends > 0
	end

	local function refreshNames()
		local info = currentInfo()
		bar.Visible = info ~= nil
		if not info then
			return
		end
		local ult = inUltimate()
		local names: { string } = if ult then info.ultimate.skillNames else info.skillNames
		for i, slot in slots do
			slot.name.Text = names[i] or "-"
			slot.stroke.Color = if ult then Theme.Accent else Color3.new(0, 0, 0)
			slot.lastEnd = 0
		end
	end

	player:GetAttributeChangedSignal("CharacterId"):Connect(refreshNames)
	player:GetAttributeChangedSignal("UltEndsAt"):Connect(refreshNames)
	refreshNames()

	RunService.Heartbeat:Connect(function()
		if not bar.Visible then
			return
		end
		local now = Workspace:GetServerTimeNow()
		local prefix = if inUltimate() then "CdU" else "CdS"
		for i, slot in slots do
			local readyAt = player:GetAttribute(prefix .. i)
			local remaining = if typeof(readyAt) == "number" then readyAt - now else 0
			if remaining > 0 then
				if readyAt ~= slot.lastEnd then
					slot.lastEnd = readyAt :: number
					slot.total = math.max(remaining, 0.1)
				end
				slot.cover.Visible = true
				slot.cover.Size = UDim2.fromScale(1, math.clamp(remaining / slot.total, 0, 1))
				slot.timeLabel.Visible = true
				-- ใช้ครบต่อร่างในร่างปกติ = เซิร์ฟเวอร์ส่งเวลาไกลมาก แสดงเป็น X
				slot.timeLabel.Text = if remaining > 600
					then "X"
					elseif remaining >= 10 then tostring(math.ceil(remaining))
					else string.format("%.1f", remaining)
			else
				slot.cover.Visible = false
				slot.timeLabel.Visible = false
				slot.lastEnd = 0
			end
		end
	end)
end

return SkillBar
