--!strict
-- เมนูหลัก: เริ่มเล่น / เลือกตัวละคร / วิธีเล่น (ตอนเข้าเกมจะเปิดเอง และมีปุ่ม "เมนู" เปิดซ้ำได้)
-- UI แค่แสดงผลและส่งคำขอ: การเลือกตัวละครจริงเซิร์ฟเวอร์เป็นคนตรวจ (Combat.onSelect)

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)
local Input = require(script.Parent.Input)
local CharacterSelect = require(script.Parent.Parent.UI.CharacterSelect)
local Roster = require(script.Parent.Parent.UI.Roster)
local Theme = require(script.Parent.Parent.UI.Theme)
local Widgets = require(script.Parent.Parent.UI.Widgets)

local Menu = {}

local player = Players.LocalPlayer

local ORBIT_BIND = "MenuOrbitCamera"
local ORBIT_RADIUS = 70
local ORBIT_HEIGHT = 38
local ORBIT_SPEED = math.rad(8)

type PageName = "Main" | "Select" | "Help"

local gui: ScreenGui
local pages: { [string]: CanvasGroup } = {}
local currentPage: PageName? = nil
local selectHandle: CharacterSelect.Handle
local menuButton: TextButton
local currentLabel: TextLabel
local blur: BlurEffect? = nil
local isOpen = false

local activeId: string = Config.DefaultCharacter -- ตัวที่เซิร์ฟเวอร์ใช้อยู่ตอนนี้
local chosenId: string? = nil

local nameOf: { [string]: string } = {}

----------------------------------------------------------------------
-- กล้อง / ปุ่มควบคุม
----------------------------------------------------------------------

local function mapCenter(): Vector3
	local map = Workspace:FindFirstChild("Map")
	local lo = map and map:GetAttribute("BoundsMin")
	local hi = map and map:GetAttribute("BoundsMax")
	if typeof(lo) == "Vector3" and typeof(hi) == "Vector3" then
		return (lo + hi) * 0.5
	end
	return Vector3.zero
end

local function startOrbit()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local angle = 0
	RunService:BindToRenderStep(ORBIT_BIND, Enum.RenderPriority.Camera.Value + 1, function(dt)
		angle += ORBIT_SPEED * dt
		local center = mapCenter()
		camera.CameraType = Enum.CameraType.Scriptable
		local pos = center + Vector3.new(math.cos(angle) * ORBIT_RADIUS, ORBIT_HEIGHT, math.sin(angle) * ORBIT_RADIUS)
		camera.CFrame = CFrame.lookAt(pos, center + Vector3.new(0, 6, 0))
	end)
end

local function stopOrbit()
	pcall(function()
		RunService:UnbindFromRenderStep(ORBIT_BIND)
	end)
	local camera = Workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

local function setMovement(enabled: boolean)
	pcall(function()
		local module = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5)
		if module then
			local controls = (require(module :: ModuleScript) :: any):GetControls()
			if enabled then
				controls:Enable()
			else
				controls:Disable()
			end
		end
	end)
end

local function setHudVisible(visible: boolean)
	local hud = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("CombatHud")
	if hud and hud:IsA("ScreenGui") then
		hud.Enabled = visible
	end
end

----------------------------------------------------------------------
-- หน้าต่างๆ
----------------------------------------------------------------------

local function showPage(name: PageName?)
	local previous = currentPage
	currentPage = name
	if previous and previous ~= name then
		local old = pages[previous]
		Widgets.tween(old, Theme.Fast, { GroupTransparency = 1 })
		task.delay(Theme.Fast.Time, function()
			if currentPage ~= previous then
				old.Visible = false
			end
		end)
	end
	if name then
		local page = pages[name]
		page.Visible = true
		page.GroupTransparency = 1
		page.Position = UDim2.fromScale(0, 0.03)
		Widgets.tween(page, Theme.Page, { GroupTransparency = 0, Position = UDim2.fromScale(0, 0) })
	end
	selectHandle.setActive(name == "Select")
end

local function newPage(name: PageName): CanvasGroup
	local page = Widgets.new("CanvasGroup", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		GroupTransparency = 1,
	}, gui)
	pages[name] = page
	return page
end

local function refreshCurrentLabel()
	local id = chosenId or activeId
	currentLabel.Text = `ตัวละคร: {nameOf[id] or id}`
end

local function buildMain(page: CanvasGroup, onPlay: () -> ())
	local column = Widgets.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.42, 0.74),
		Position = UDim2.fromScale(0.06, 0.13),
	}, page)

	Widgets.label(column, {
		Text = "ANIME",
		Font = Theme.FontBold,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(0.5, 0.07),
	}, 24)
	Widgets.label(column, {
		Text = "BATTLE\nARENA",
		Font = Theme.FontTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(1, 0.3),
		Position = UDim2.fromScale(0, 0.07),
		LineHeight = 0.9,
	}, 72)
	Widgets.label(column, {
		Text = "สังเวียนประลองนักสู้",
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(0.8, 0.06),
		Position = UDim2.fromScale(0, 0.38),
	}, 20)

	local buttons = Widgets.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.8, 0.42),
		Position = UDim2.fromScale(0, 0.47),
	}, column)
	Widgets.new("UIListLayout", {
		Padding = UDim.new(0.04, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, buttons)
	local function add(text: string, primary: boolean, order: number, handler: () -> ())
		local button = Widgets.button(buttons, text, primary, handler)
		button.Instance.LayoutOrder = order
		button.Instance.Size = UDim2.fromScale(1, 0.28)
	end
	add("เริ่มเล่น", true, 1, onPlay)
	add("เลือกตัวละคร", false, 2, function()
		showPage("Select")
	end)
	add("วิธีเล่น", false, 3, function()
		showPage("Help")
	end)

	currentLabel = Widgets.label(column, {
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromScale(0.8, 0.05),
		Position = UDim2.fromScale(0, 0.93),
	}, 16)
end

local HELP_PC = {
	"คลิกซ้าย  ตีคอมโบ 4 หมัด",
	"Space ค้าง + คลิก  ตีเสย",
	"กระโดดแล้วคลิก  ทุบลงพื้น",
	"F (ค้าง)  ป้องกัน",
	"Q  แดช",
	"1 2 3 4  สกิล",
	"G  อันติ (เมื่อเกจเต็ม)",
}
local HELP_MOBILE = {
	"แตะปุ่ม ตี  ตีคอมโบ",
	"ปัดปุ่ม ตี ขึ้น  ตีเสย",
	"แตะ ตี กลางอากาศ  ทุบลงพื้น",
	"ปุ่ม การ์ด (ค้าง)  ป้องกัน",
	"ปุ่ม แดช  พุ่งตัว",
	"ปุ่ม 1-4  สกิล",
	"ปุ่ม อันติ  เมื่อเกจเต็ม",
}

local function buildHelp(page: CanvasGroup)
	local panel = Widgets.new("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.8, 0.7),
		Position = UDim2.fromScale(0.1, 0.18),
	}, page)
	Widgets.corner(panel, 0.04)
	Widgets.padding(panel, 0.03)

	local function column(title: string, lines: { string }, x: number)
		local col = Widgets.new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.48, 0.86),
			Position = UDim2.fromScale(x, 0.14),
		}, panel)
		Widgets.label(col, {
			Text = title,
			Font = Theme.FontTitle,
			TextColor3 = Theme.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(1, 0.14),
		}, 28)
		local list = Widgets.new("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.84),
			Position = UDim2.fromScale(0, 0.16),
		}, col)
		Widgets.new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)
		for i, line in lines do
			Widgets.label(list, {
				Text = line,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.fromScale(1, 1 / #lines),
				LayoutOrder = i,
			}, 20)
		end
	end
	column("คอม (PC)", HELP_PC, 0)
	column("มือถือ", HELP_MOBILE, 0.52)

	local back = Widgets.button(panel, "< กลับ", false, function()
		showPage("Main")
	end)
	back.Instance.Size = UDim2.fromScale(0.16, 0.11)
end

----------------------------------------------------------------------
-- เปิด/ปิดเมนู
----------------------------------------------------------------------

local function open()
	if isOpen then
		return
	end
	isOpen = true
	gui.Enabled = true
	menuButton.Visible = false
	Input.setEnabled(false)
	setMovement(false)
	setHudVisible(false)
	startOrbit()
	if not blur then
		local effect = Instance.new("BlurEffect")
		effect.Size = 0
		effect.Parent = Lighting
		blur = effect
	end
	Widgets.tween(blur :: BlurEffect, Theme.Page, { Size = 16 })
	refreshCurrentLabel()
	selectHandle.setChosen(chosenId or activeId)
	showPage("Main")
end

local function close(waitForRespawn: boolean)
	if not isOpen then
		return
	end
	isOpen = false
	showPage(nil)
	local effect = blur
	if effect then
		Widgets.tween(effect, Theme.Page, { Size = 0 })
		blur = nil
		task.delay(Theme.Page.Time + 0.05, function()
			effect:Destroy()
		end)
	end

	local function finish()
		if isOpen then
			return -- ระหว่างรอมีคนเปิดเมนูใหม่
		end
		stopOrbit()
		setMovement(true)
		Input.setEnabled(true)
		setHudVisible(true)
		menuButton.Visible = true
		gui.Enabled = true
	end
	if waitForRespawn then
		-- รอตัวละครใหม่เกิดก่อนค่อยคืนกล้อง (เผื่อเซิร์ฟเวอร์ไม่ตอบ: รอสูงสุด 6 วินาที)
		local done = false
		local conn: RBXScriptConnection
		conn = player.CharacterAdded:Connect(function()
			if done then
				return
			end
			done = true
			conn:Disconnect()
			task.wait(0.2)
			finish()
		end)
		task.delay(6, function()
			if not done then
				done = true
				conn:Disconnect()
				finish()
			end
		end)
	else
		task.delay(Theme.Fast.Time, finish)
	end
end

local function play()
	local wanted = chosenId
	local needsRespawn = wanted ~= nil and wanted ~= activeId
	if needsRespawn and wanted then
		Net.get("SelectCharacter"):FireServer(wanted)
		Net.get("Respawn"):FireServer()
		activeId = wanted
	end
	close(needsRespawn)
end

function Menu.start()
	for _, info in Roster.list() do
		nameOf[info.id] = info.displayName
	end

	gui = Widgets.new("ScreenGui", {
		Name = "MainMenu",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 50,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui"))

	-- พื้นหลังไล่สีทับฉากแมพที่โดนเบลอ
	local backdrop = Widgets.new("Frame", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 0,
	}, gui)
	Widgets.new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.55, 0.45),
			NumberSequenceKeypoint.new(1, 0.9),
		}),
	}, backdrop)

	local mainPage = newPage("Main")
	local selectPage = newPage("Select")
	local helpPage = newPage("Help")

	selectHandle = CharacterSelect.build(selectPage, function()
		showPage("Main")
	end, function(id: string)
		chosenId = id
		selectHandle.setChosen(id)
		refreshCurrentLabel()
		showPage("Main")
	end)
	buildHelp(helpPage)
	buildMain(mainPage, play)

	-- ปุ่มเปิดเมนูซ้ำ (กลางบนจอ ไม่ชนปุ่มระบบของ Roblox)
	local overlay = Widgets.new("ScreenGui", {
		Name = "MenuButton",
		ResetOnSpawn = false,
		DisplayOrder = 49,
	}, player.PlayerGui)
	local openButton = Widgets.button(overlay, "เมนู", false, open)
	menuButton = openButton.Instance
	menuButton.AnchorPoint = Vector2.new(0.5, 0)
	menuButton.Position = UDim2.new(0.5, 0, 0, 12)
	menuButton.Size = UDim2.fromScale(0.1, 0.07)
	menuButton.Visible = false
	Widgets.new("UISizeConstraint", { MinSize = Vector2.new(80, Theme.MinTouch), MaxSize = Vector2.new(140, 56) }, menuButton)

	-- ปุ่ม M เปิด/ปิดเมนูบน PC
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.M and not isOpen then
			open()
		end
	end)

	task.defer(open)
end

return Menu
