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

local function refresh(player: Player)
	local character = player.Character
	if not (character and character.Parent) then
		return
	end
	local looks = looksFor(player:GetAttribute("CharacterId"))
	if not looks then
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
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return AppearanceSystem
