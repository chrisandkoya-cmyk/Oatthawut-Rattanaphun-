--!strict
-- วัดระยะที่ท่ายาวๆ (ลำแสง แขนยืด) ไปได้จริงก่อนชนกำแพง/เสา เพื่อตัดความยาว hitbox ไม่ให้ทะลุสิ่งกีดขวาง
-- ตัวละครอื่น (มี Humanoid) ไม่นับเป็นสิ่งกีดขวาง

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Types)

local Reach = {}

local MAX_SKIPS = 8

function Reach.clear(ctx: Types.SkillContext, maxLength: number): number
	local origin = ctx.root.Position
	local direction = ctx.forward() * maxLength
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { ctx.character }
	for _ = 1, MAX_SKIPS do
		local result = workspace:Raycast(origin, direction, params)
		if not result then
			return maxLength
		end
		local model = result.Instance:FindFirstAncestorWhichIsA("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			params:AddToFilter(model)
		else
			return math.max(result.Distance - 1, 1)
		end
	end
	return maxLength
end

-- hitbox แนวยาวไปข้างหน้าตามระยะที่ไปได้จริง (ตัวช่วยให้ไม่ต้องเขียนซ้ำทุกสกิล)
function Reach.line(ctx: Types.SkillContext, width: number, height: number, maxLength: number): Types.HitboxOptions
	local length = Reach.clear(ctx, maxLength)
	return { size = Vector3.new(width, height, length), offset = length / 2 }
end

return Reach
