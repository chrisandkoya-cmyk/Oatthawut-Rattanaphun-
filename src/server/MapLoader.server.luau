--!strict
-- โหลดแมพแรกตอนเซิร์ฟเวอร์เริ่ม (กด Play ใน Studio แล้วแมพจะถูกสร้าง)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapBuilder = require(script.Parent.MapBuilder)
local TempleCourtyard = require(ReplicatedStorage.Shared.Maps.TempleCourtyard)

MapBuilder.Build(TempleCourtyard)

-- ปิดจุดเกิดเดิมของเทมเพลต Studio (เช่น SpawnLocation กลาง Baseplate) ไม่ให้คนเกิดทับรูปปั้นกลางลาน
local Workspace = game:GetService("Workspace")
local map = Workspace:FindFirstChild("Map")
for _, inst in Workspace:GetDescendants() do
	if inst:IsA("SpawnLocation") and not (map and inst:IsDescendantOf(map)) then
		inst.Enabled = false
	end
end
