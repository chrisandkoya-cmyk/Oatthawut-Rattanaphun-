--!strict
-- บังคับความเร็วตัวละครชั่วคราว (ใช้กับแดช/พุ่ง/ถูกผลัก)
-- ตัวละครผู้เล่นต้องเรียกฝั่ง client เจ้าของ เพราะ client เป็นเจ้าของฟิสิกส์ตัวเอง
-- หุ่น/NPC เรียกฝั่งเซิร์ฟเวอร์ได้เลย

local Velocity = {}

local ATTACHMENT_NAME = "CombatVelocityAttachment"

function Velocity.apply(root: BasePart, velocity: Vector3, duration: number)
	local attachment = root:FindFirstChild(ATTACHMENT_NAME)
	if not attachment then
		local created = Instance.new("Attachment")
		created.Name = ATTACHMENT_NAME
		created.Parent = root
		attachment = created
	end

	-- ลบแรงเก่าก่อน ไม่ให้ซ้อนกัน
	for _, child in root:GetChildren() do
		if child:IsA("LinearVelocity") and child.Name == "CombatVelocity" then
			child:Destroy()
		end
	end

	local lv = Instance.new("LinearVelocity")
	lv.Name = "CombatVelocity"
	lv.Attachment0 = attachment :: Attachment
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.MaxForce = 1e6
	lv.VectorVelocity = velocity
	lv.Parent = root

	task.delay(duration, function()
		if lv.Parent then
			lv:Destroy()
		end
	end)
end

return Velocity
