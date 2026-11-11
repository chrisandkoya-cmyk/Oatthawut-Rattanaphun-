--!strict
-- หาเป้าในกล่อง hitbox (คำนวณบนเซิร์ฟเวอร์)

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared").Config)

local Hitbox = {}

-- หา Model ที่มี Humanoid จากชิ้นส่วนที่โดน (รองรับ accessory ที่ซ้อนอยู่ข้างใน)
function Hitbox.findCharacter(part: Instance): Model?
	local model = part:FindFirstAncestorWhichIsA("Model")
	while model do
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return model
		end
		model = model:FindFirstAncestorWhichIsA("Model")
	end
	return nil
end

function Hitbox.inFront(root: BasePart, offset: number): CFrame
	return root.CFrame * CFrame.new(0, 0, -offset)
end

local function showDebug(cframe: CFrame, size: Vector3)
	if not (Config.Debug.ShowHitboxes and RunService:IsStudio()) then
		return
	end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 0.7
	part.Color = Color3.fromRGB(255, 40, 40)
	part.Material = Enum.Material.ForceField
	part.Size = size
	part.CFrame = cframe
	part.Name = "HitboxDebug"
	part.Parent = workspace
	Debris:AddItem(part, 0.15)
end

-- คืน Model ที่ยังมีชีวิตในกล่อง ไม่รวมผู้โจมตี (ไม่ซ้ำ)
function Hitbox.query(attacker: Model, cframe: CFrame, size: Vector3): { Model }
	showDebug(cframe, size)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { attacker }

	local found: { [Model]: boolean } = {}
	local result: { Model } = {}
	for _, part in workspace:GetPartBoundsInBox(cframe, size, params) do
		local model = Hitbox.findCharacter(part)
		if model and not found[model] then
			found[model] = true
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(result, model)
			end
		end
	end
	return result
end

return Hitbox
