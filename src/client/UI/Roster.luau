--!strict
-- รายชื่อตัวละครที่แสดงในเมนู อ่านจาก ReplicatedStorage/Shared/CharacterInfo (ไม่ฝังชื่อตัวละครในโค้ด UI)
-- เพิ่มตัวละครใหม่ = เพิ่มไฟล์ CharacterInfo ไฟล์เดียว เมนูจะขึ้นเอง

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)

local PLACEHOLDER_ID = "TrainingFighter" -- ตัวทดสอบระบบ ซ่อนเมื่อมีตัวละครจริงแล้ว

local Roster = {}

function Roster.list(): { Types.CharacterInfo }
	local folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterInfo")
	local result: { Types.CharacterInfo } = {}
	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			local ok, info = pcall(require, child)
			if ok and typeof(info) == "table" and typeof((info :: any).id) == "string" then
				table.insert(result, info :: any)
			else
				warn(`[Roster] อ่าน CharacterInfo/{child.Name} ไม่ได้`)
			end
		end
	end
	table.sort(result, function(a, b)
		return a.id < b.id
	end)
	if #result > 1 then
		for i = #result, 1, -1 do
			if result[i].id == PLACEHOLDER_ID then
				table.remove(result, i)
			end
		end
	end
	return result
end

return Roster
