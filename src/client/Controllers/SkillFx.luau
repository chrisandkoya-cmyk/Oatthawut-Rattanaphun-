--!strict
-- เอฟเฟกต์ภาพของสกิลตามตัวละคร: รับ Fx (kind = "Skill") แล้วเรียกตัวจัดการใน Effects/<characterId>
-- ตัวละครที่ไม่มีไฟล์ Effects ก็ไม่เกิดอะไร (ไม่ error)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local shared = Shared
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local Lib = require(script.Parent.Parent.Effects.Lib)
local Juice = require(script.Parent.Parent.Effects.Juice)

local SkillFx = {}

local effectsFolder = script.Parent.Parent:WaitForChild("Effects")
local cache: { [string]: { [string]: any }? } = {}

local function handlersFor(characterId: string): { [string]: any }?
	if cache[characterId] ~= nil then
		return cache[characterId]
	end
	local module = effectsFolder:FindFirstChild(characterId)
	local handlers = nil
	if module and module:IsA("ModuleScript") then
		local ok, result = pcall(require, module)
		if ok then
			handlers = result :: any
		else
			warn(`[SkillFx] โหลด {characterId} ไม่ได้: {result}`)
		end
	end
	cache[characterId] = handlers
	return handlers
end

local function tintAura(payload: Types.FxPayload)
	-- ออร่าอันติใช้สีของตัวละคร (FxController สร้าง Highlight ไว้แล้ว เราแค่เปลี่ยนสี)
	local source = payload.source
	local aura = source and source:FindFirstChild("UltAura")
	local module = payload.characterId and shared.CharacterInfo:FindFirstChild(payload.characterId)
	if aura and aura:IsA("Highlight") and module and module:IsA("ModuleScript") then
		local info = (require :: any)(module) :: Types.CharacterInfo
		aura.FillColor = info.color
		aura.FillTransparency = 0.55
		aura.OutlineColor = info.color:Lerp(Color3.new(1, 1, 1), 0.5)
	end
end

local function onFx(payload: Types.FxPayload)
	if not payload.characterId then
		return
	end
	local key = payload.key
	if payload.kind == "UltStart" then
		key = "UltStart"
		task.defer(tintAura, payload)
	elseif payload.kind ~= "Skill" or not key then
		return
	end
	local handlers = handlersFor(payload.characterId)
	local handler = handlers and handlers[key]
	local root = Lib.rootOf(payload.source)
	if root and key then
		-- ชั้นเสริมความหนักแน่น (กล้องสั่น แสงวาบ เส้นสปีด) สีตามตัวละคร
		local tint = Color3.new(1, 1, 1)
		local module = shared.CharacterInfo:FindFirstChild(payload.characterId)
		if module and module:IsA("ModuleScript") then
			local ok, info = pcall(require, module)
			if ok and typeof(info) == "table" and typeof((info :: any).color) == "Color3" then
				tint = (info :: any).color
			end
		end
		local okJuice, errJuice = pcall(Juice.forKey, key, root, tint)
		if not okJuice then
			warn(`[SkillFx] Juice {key} error: {errJuice}`)
		end
	end
	if handler and root then
		local ok, err = pcall(handler, root, payload)
		if not ok then
			warn(`[SkillFx] {payload.characterId}.{key} error: {err}`)
		end
	end
end

function SkillFx.start()
	Net.get("Fx").OnClientEvent:Connect(onFx)
end

return SkillFx
