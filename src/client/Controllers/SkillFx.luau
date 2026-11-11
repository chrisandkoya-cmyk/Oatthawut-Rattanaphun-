--!strict
-- เอฟเฟกต์ภาพของสกิลตามตัวละคร: รับ Fx (kind = "Skill") แล้วเรียกตัวจัดการใน Effects/<characterId>
-- ตัวละครที่ไม่มีไฟล์ Effects ก็ไม่เกิดอะไร (ไม่ error)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local Lib = require(script.Parent.Parent.Effects.Lib)

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

local function onFx(payload: Types.FxPayload)
	if payload.kind ~= "Skill" or not (payload.key and payload.characterId) then
		return
	end
	local handlers = handlersFor(payload.characterId)
	local handler = handlers and handlers[payload.key]
	local root = Lib.rootOf(payload.source)
	if handler and root then
		local ok, err = pcall(handler, root, payload)
		if not ok then
			warn(`[SkillFx] {payload.characterId}.{payload.key} error: {err}`)
		end
	end
end

function SkillFx.start()
	Net.get("Fx").OnClientEvent:Connect(onFx)
end

return SkillFx
