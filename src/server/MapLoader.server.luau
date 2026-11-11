--!strict
-- โหลดแมพตอนเซิร์ฟเวอร์เริ่ม (กด Play ใน Studio แล้วแมพจะถูกสร้าง)
-- เลือกแมพด้วย attribute "StartMapId" บน Workspace (ไม่ตั้ง = TempleCourtyard)
-- เปลี่ยนแมพระหว่างเล่น: MapBuilder.Build(MapRegistry.Get("StormShip"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MapBuilder = require(script.Parent.MapBuilder)
local MapRegistry = require(ReplicatedStorage.Shared.MapRegistry)

local startId = Workspace:GetAttribute("StartMapId")
if typeof(startId) ~= "string" then
	startId = "TempleCourtyard"
end
MapBuilder.Build(MapRegistry.Get(startId))

local map = Workspace:FindFirstChild("Map")

-- ลบ Baseplate ของเทมเพลต Studio: ผิวบนอยู่ที่ y=0 เท่าพื้นลาน ทำให้พื้นกะพริบและบังหญ้ารอบนอก
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

-- ปิดจุดเกิดเดิมของเทมเพลต Studio ไม่ให้คนเกิดทับของกลางลาน
for _, inst in Workspace:GetDescendants() do
	if inst:IsA("SpawnLocation") and not (map and inst:IsDescendantOf(map)) then
		inst.Enabled = false
	end
end
