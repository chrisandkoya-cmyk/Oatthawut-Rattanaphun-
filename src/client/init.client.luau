--!strict
-- จุดเริ่มต้นฝั่ง client (LocalScript ตัวเดียว)

local Controllers = script.Controllers

local list = { "Input", "FxController", "ProcAnim", "SkillFx", "Hud", "SkillBar", "Menu" }
for _, name in list do
	local module = Controllers:WaitForChild(name)
	local controller = require(module :: ModuleScript) :: any
	if typeof(controller.start) == "function" then
		task.spawn(controller.start)
	end
end
