--!strict
-- จุดเริ่มต้นฝั่งเซิร์ฟเวอร์ (Script ตัวเดียว) เริ่มระบบแบบ 2 เฟส: init ทุกตัวก่อน แล้วค่อย start

local Systems = script.Systems

-- ระบบต้องโหลดก่อนใช้งาน และลำดับมีผล (Combat ก่อน Dummies)
local order = { "Combat", "Dummies", "Lobby" }

local loaded: { any } = {}
for _, name in order do
	local module = Systems:FindFirstChild(name)
	if module and module:IsA("ModuleScript") then
		table.insert(loaded, require(module))
	end
end

for _, system in loaded do
	if typeof(system.init) == "function" then
		system.init()
	end
end
for _, system in loaded do
	if typeof(system.start) == "function" then
		task.spawn(system.start)
	end
end
