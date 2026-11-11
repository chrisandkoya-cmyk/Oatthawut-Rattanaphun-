--!strict
-- วาร์ป/ดึงตัวละครอย่างปลอดภัย (ตรวจบนเซิร์ฟเวอร์)
-- ขอบแมพอ่านจาก Attribute BoundsMin / BoundsMax (Vector3) บน Workspace.Map
-- หมายเหตุ: กำแพงล่องหน CanQuery=false raycast ไม่เจอ จึงต้อง clamp กับขอบแมพเสมอ

local Movement = {}

local MAX_TELEPORT = 100 -- เพดานระยะวาร์ป/ดึง กันสกิลตั้งค่าผิด

function Movement.clampToBounds(position: Vector3): Vector3
	local map = workspace:FindFirstChild("Map")
	if not map then
		return position
	end
	-- สนามวงกลม: ไม่ให้ออกนอกรัศมีจากจุด (0,0) (กล่องสี่เหลี่ยมมุมอยู่นอกสนาม)
	local radius = map:GetAttribute("BoundsRadius")
	if typeof(radius) == "number" and radius > 0 then
		local flat = Vector3.new(position.X, 0, position.Z)
		local limit = math.max(radius - 2, 0) -- เว้นขอบ 2 สตัด ไม่ให้ตัวละครซ้อนกำแพง
		if flat.Magnitude > limit then
			local limited = flat.Unit * limit
			position = Vector3.new(limited.X, position.Y, limited.Z)
		end
	end
	local min = map:GetAttribute("BoundsMin")
	local max = map:GetAttribute("BoundsMax")
	if typeof(min) ~= "Vector3" or typeof(max) ~= "Vector3" then
		return position
	end
	return Vector3.new(
		math.clamp(position.X, math.min(min.X, max.X), math.max(min.X, max.X)),
		math.clamp(position.Y, math.min(min.Y, max.Y), math.max(min.Y, max.Y)),
		math.clamp(position.Z, math.min(min.Z, max.Z), math.max(min.Z, max.Z))
	)
end

-- หาจุดปลายทางที่ไปได้จริง: ตรวจระยะ, clamp ขอบแมพ, raycast กันทะลุกำแพง
-- คืน nil ถ้าไปไม่ได้
function Movement.safeDestination(model: Model, from: Vector3, to: Vector3, maxDistance: number): Vector3?
	local distance = (to - from).Magnitude
	if distance ~= distance then
		return nil -- NaN
	end
	local limit = math.clamp(maxDistance, 0, MAX_TELEPORT)
	if distance > limit + 0.5 then
		return nil
	end
	local destination = Movement.clampToBounds(to)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- ไม่ให้ตัวละครอื่นบังการเช็กกำแพง (วาร์ปไปหลังศัตรูต้องเช็กผนังหลังศัตรูด้วย)
	local ignore: { Instance } = { model }
	for _, player in game:GetService("Players"):GetPlayers() do
		if player.Character then
			table.insert(ignore, player.Character)
		end
	end
	for _, state in require(script.Parent.State).all() do
		table.insert(ignore, state.model)
	end
	params.FilterDescendantsInstances = ignore
	local delta = destination - from
	if delta.Magnitude > 0.1 then
		local result = workspace:Raycast(from, delta, params)
		-- ชนสิ่งกีดขวาง (ไม่ใช่ตัวละคร) -> หยุดหน้าสิ่งกีดขวาง
		if result then
			local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
			if not (hitModel and hitModel:FindFirstChildOfClass("Humanoid")) then
				destination = result.Position - delta.Unit * 2
			end
		end
	end
	return destination
end

function Movement.moveTo(model: Model, position: Vector3, facing: Vector3?)
	local root = model:FindFirstChild("HumanoidRootPart")
	if not (root and root:IsA("BasePart")) then
		return
	end
	local look = facing or root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 1e-3 then
		flat = Vector3.new(0, 0, -1)
	end
	model:PivotTo(CFrame.lookAt(position, position + flat.Unit))
	root.AssemblyLinearVelocity = Vector3.zero
end

return Movement
