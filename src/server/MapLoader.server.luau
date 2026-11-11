--!strict
-- โหลดแมพแรกตอนเซิร์ฟเวอร์เริ่ม (กด Play ใน Studio แล้วแมพจะถูกสร้าง)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapBuilder = require(script.Parent.MapBuilder)
local TempleCourtyard = require(ReplicatedStorage.Shared.Maps.TempleCourtyard)

MapBuilder.Build(TempleCourtyard)

local Workspace = game:GetService("Workspace")
local map = Workspace:FindFirstChild("Map")

-- ลบ Baseplate ของเทมเพลต Studio: ผิวบนอยู่ที่ y=0 เท่าพื้นลาน ทำให้พื้นกะพริบและบังหญ้ารอบนอก
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

-- ปิดจุดเกิดเดิมของเทมเพลต Studio (เช่น SpawnLocation กลาง Baseplate) ไม่ให้คนเกิดทับรูปปั้นกลางลาน
for _, inst in Workspace:GetDescendants() do
	if inst:IsA("SpawnLocation") and not (map and inst:IsDescendantOf(map)) then
		inst.Enabled = false
	end
end
