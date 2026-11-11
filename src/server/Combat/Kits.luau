--!strict
-- โหลดและตรวจ ModuleScript ตัวละครทั้งหมดใน ServerScriptService/Server/Characters
-- 1 ตัวละคร = 1 ModuleScript (ชื่อไฟล์ = id)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)
local infoFolder = ReplicatedStorage.Shared:WaitForChild("CharacterInfo")

local Kits = {}

local kits: { [string]: Types.CharacterKit } = {}

local function validate(name: string, kit: any): string?
	if typeof(kit) ~= "table" then
		return "ต้อง return table"
	end
	if kit.id ~= name then
		return `id ต้องตรงกับชื่อไฟล์ ({name})`
	end
	if
		typeof(kit.stats) ~= "table"
		or typeof(kit.stats.maxHealth) ~= "number"
		or typeof(kit.stats.walkSpeed) ~= "number"
	then
		return "stats.maxHealth / stats.walkSpeed หาย"
	end
	if typeof(kit.skills) ~= "table" or #kit.skills ~= 4 then
		return "skills ต้องมี 4 ท่า"
	end
	if typeof(kit.ultimate) ~= "table" or typeof(kit.ultimate.skills) ~= "table" or #kit.ultimate.skills ~= 4 then
		return "ultimate.skills ต้องมี 4 ท่า"
	end
	if typeof(kit.ultimate.duration) ~= "number" or kit.ultimate.duration <= 0 then
		return "ultimate.duration ต้องเป็นเลขมากกว่า 0"
	end
	for i, skill in kit.skills do
		if typeof(skill.run) ~= "function" or typeof(skill.cooldown) ~= "number" then
			return `skills[{i}] ต้องมี run และ cooldown`
		end
	end
	for i, skill in kit.ultimate.skills do
		if typeof(skill.run) ~= "function" or typeof(skill.cooldown) ~= "number" then
			return `ultimate.skills[{i}] ต้องมี run และ cooldown`
		end
	end
	if not infoFolder:FindFirstChild(name) then
		return `ไม่มี CharacterInfo/{name} (ชื่อ/สกิน/เสียง)`
	end
	return nil
end

function Kits.load(folder: Instance)
	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child)
			if not ok then
				warn(`[Kits] โหลด {child.Name} ไม่ได้: {result}`)
				continue
			end
			local problem = validate(child.Name, result)
			if problem then
				warn(`[Kits] {child.Name} ไม่ผ่าน: {problem}`)
				continue
			end
			kits[child.Name] = result :: Types.CharacterKit
		end
	end
end

function Kits.get(id: string): Types.CharacterKit?
	return kits[id]
end

function Kits.has(id: string): boolean
	return kits[id] ~= nil
end

function Kits.list(): { string }
	local ids = {}
	for id in kits do
		table.insert(ids, id)
	end
	table.sort(ids)
	return ids
end

return Kits
