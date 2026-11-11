--!strict
-- ใส่หน้าตา (Shared/Appearance/<id>) ให้ผู้เล่นตามตัวละครที่เลือก และสลับร่างปกติ <-> ร่างอันติ
-- อ่านสถานะจาก Attribute ที่ระบบต่อสู้ตั้งไว้บน Player: CharacterId, UltEndsAt
-- ตัวละครที่ไม่มีไฟล์ Appearance (เช่น TrainingFighter) ไม่ถูกแตะ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Appearance = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Appearance")
local Builder = require(Appearance:WaitForChild("Builder"))

local AppearanceSystem = {}

local function looksFor(characterId: unknown): { base: Builder.Look, ultimate: Builder.Look }?
	if typeof(characterId) ~= "string" then
		return nil
	end
	local module = Appearance:FindFirstChild(characterId)
	if not (module and module:IsA("ModuleScript")) then
		return nil
	end
	local ok, result = pcall(require, module)
	if not ok then
		warn(`[Appearance] โหลด {characterId} ไม่ได้: {result}`)
		return nil
	end
	return result :: any
end

-- ล้างอวตารของผู้เล่น (ผม เสื้อผ้า ขนาดตัว ชิ้นส่วนร่างกายพิเศษ) ให้เป็น R15 มาตรฐานสัดส่วน 1:1 ก่อนใส่หน้าตา
-- ต้องใช้ ApplyDescription เพราะผู้เล่นแต่ละคนมีอวตารไม่เหมือนกัน (ผมยาว กระโปรง ตัวเล็ก ฯลฯ)
local function normalize(character: Model, look: Builder.Look)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local ok, description = pcall(function()
		return humanoid:GetAppliedDescription()
	end)
	if not ok then
		description = Instance.new("HumanoidDescription")
	end
	local desc = description :: HumanoidDescription
	desc:SetAccessories({}, true)
	for _, field in
		{
			"HatAccessory",
			"HairAccessory",
			"FaceAccessory",
			"NeckAccessory",
			"ShouldersAccessory",
			"FrontAccessory",
			"BackAccessory",
			"WaistAccessory",
		}
	do
		(desc :: any)[field] = ""
	end
	desc.Shirt = 0
	desc.Pants = 0
	desc.GraphicTShirt = 0
	desc.Head = 0
	desc.Torso = 0
	desc.LeftArm = 0
	desc.RightArm = 0
	desc.LeftLeg = 0
	desc.RightLeg = 0
	desc.HeightScale = 1
	desc.WidthScale = 1
	desc.DepthScale = 1
	desc.HeadScale = 1
	desc.BodyTypeScale = 0
	desc.ProportionScale = 0
	local c = look.colors
	desc.HeadColor = c.Head or desc.HeadColor
	desc.TorsoColor = c.UpperTorso or desc.TorsoColor
	desc.LeftArmColor = c.LeftUpperArm or desc.LeftArmColor
	desc.RightArmColor = c.RightUpperArm or desc.RightArmColor
	desc.LeftLegColor = c.LeftUpperLeg or desc.LeftLegColor
	desc.RightLegColor = c.RightUpperLeg or desc.RightLegColor
	local applied, err = pcall(function()
		humanoid:ApplyDescriptionReset(desc)
	end)
	if not applied then
		warn(`[Appearance] ล้างอวตารไม่สำเร็จ: {err}`)
	end
	character:SetAttribute("AvatarNormalized", true)
end

local busy: { [Player]: boolean } = {}
local pending: { [Player]: boolean } = {} -- มี refresh เข้ามาระหว่างที่กำลังล้างอวตาร ให้ทำซ้ำหลังจบ

local refresh: (player: Player) -> ()

function refresh(player: Player)
	local character = player.Character
	if busy[player] then
		pending[player] = true
		return
	end
	-- ตอนเกิด player.Character ถูกตั้งก่อนตัวละครอยู่ใน Workspace (Parent ยังเป็น nil) ต้องรอก่อน
	local waited = 0
	while character and not character.Parent and waited < 5 do
		waited += task.wait(0.1)
		if player.Character ~= character then
			return
		end
	end
	if busy[player] then
		pending[player] = true
		return
	end
	if not (character and character.Parent) then
		return
	end
	local looks = looksFor(player:GetAttribute("CharacterId"))
	if not looks then
		return
	end
	busy[player] = true
	if not character:GetAttribute("AvatarNormalized") then
		normalize(character, looks.base)
	end
	busy[player] = nil
	if pending[player] then
		pending[player] = nil
		task.defer(refresh, player) -- สถานะเปลี่ยนระหว่างรอ (เช่น แปลงร่างทันทีหลังเกิด) อ่านค่าล่าสุดใหม่
		return
	end
	if player.Character ~= character or not character.Parent then
		return
	end
	local inUltimate = (player:GetAttribute("UltEndsAt") or 0) :: number > 0
	Builder.apply(character, inUltimate and looks.ultimate or looks.base)
end

local function onCharacterAdded(player: Player)
	-- รอให้อวตารโหลดเสร็จก่อนค่อยถอดเสื้อผ้า และรอระบบต่อสู้ตั้ง CharacterId
	if not player:HasAppearanceLoaded() then
		player.CharacterAppearanceLoaded:Wait()
	end
	local waited = 0
	while player:GetAttribute("CharacterId") == nil and waited < 5 do
		waited += task.wait(0.1)
	end
	refresh(player)
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(function()
		task.spawn(onCharacterAdded, player)
	end)
	player:GetAttributeChangedSignal("UltEndsAt"):Connect(function()
		refresh(player)
	end)
	player:GetAttributeChangedSignal("CharacterId"):Connect(function()
		refresh(player)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player)
	end
end

function AppearanceSystem.start()
	Players.PlayerAdded:Connect(onPlayer)
	Players.PlayerRemoving:Connect(function(player)
		busy[player] = nil
		pending[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return AppearanceSystem
