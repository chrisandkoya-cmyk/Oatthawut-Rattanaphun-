--!strict
-- ตัวช่วยสร้างเอฟเฟกต์ภาพ (ระเบิดแสง วงแหวน ลำแสง แขนยืด) ใช้ Part/Tween ล้วนๆ ไม่ใช้รูปหรือเสียงจากภายนอก
-- เป็นภาพอย่างเดียว (client) ไม่มีผลต่อดาเมจ

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Lib = {}

local function newPart(): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Parent = workspace
	return part
end

local function fadeOut(part: Part, seconds: number, extra: { [string]: any }?)
	local goal: { [string]: any } = { Transparency = 1 }
	if extra then
		for key, value in extra do
			goal[key] = value
		end
	end
	TweenService:Create(part, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
	Debris:AddItem(part, seconds + 0.1)
end

function Lib.rootOf(model: Model?): BasePart?
	local root = model and model:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

-- ลูกแสงเล็กๆ ระเบิดออก
function Lib.burst(position: Vector3, color: Color3, count: number, speed: number, seconds: number?)
	local life = seconds or 0.7
	for _ = 1, count do
		local part = newPart()
		part.Shape = Enum.PartType.Ball
		part.Color = color
		part.Size = Vector3.one * (0.7 + math.random() * 0.5)
		part.Position = position
		local direction = Vector3.new(math.random() - 0.5, math.random() - 0.3, math.random() - 0.5)
		if direction.Magnitude < 0.01 then
			direction = Vector3.yAxis
		end
		TweenService:Create(
			part,
			TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = position + direction.Unit * speed * life, Size = Vector3.one * 0.05, Transparency = 1 }
		):Play()
		Debris:AddItem(part, life + 0.1)
	end
end

-- วงแหวนขยายออก (แนวนอนบนพื้น)
function Lib.ring(position: Vector3, color: Color3, radius: number, seconds: number?, vertical: CFrame?)
	local life = seconds or 0.4
	local part = newPart()
	part.Shape = Enum.PartType.Cylinder
	part.Color = color
	part.Transparency = 0.2
	part.Size = Vector3.new(0.3, 1, 1)
	part.CFrame = (vertical or CFrame.new(position)) * CFrame.Angles(0, 0, math.rad(90))
	TweenService:Create(
		part,
		TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.3, radius * 2, radius * 2), Transparency = 1 }
	):Play()
	Debris:AddItem(part, life + 0.1)
end

-- ทรงกลมแสงขยาย/หด (ชาร์จพลัง ระเบิด)
function Lib.orb(position: Vector3, color: Color3, from: number, to: number, seconds: number, follow: BasePart?)
	local part = newPart()
	part.Shape = Enum.PartType.Ball
	part.Color = color
	part.Transparency = 0.3
	part.Size = Vector3.one * from
	part.Position = position
	TweenService:Create(part, TweenInfo.new(seconds, Enum.EasingStyle.Quad), { Size = Vector3.one * to }):Play()
	if follow then
		local offset = position - follow.Position
		local connection: RBXScriptConnection? = nil
		connection = game:GetService("RunService").RenderStepped:Connect(function()
			if not part.Parent or not follow.Parent then
				if connection then
					connection:Disconnect()
				end
				return
			end
			part.Position = follow.Position + offset
		end)
	end
	fadeOut(part, seconds, { Size = Vector3.one * to })
end

-- แท่งแสงจากจุด a ไป b (ลำแสง/แขนยืด) ค่อยๆ จางหาย
function Lib.beam(from: Vector3, to: Vector3, color: Color3, width: number, seconds: number, material: Enum.Material?)
	local distance = (to - from).Magnitude
	if distance < 0.05 then
		return
	end
	local part = newPart()
	part.Color = color
	part.Material = material or Enum.Material.Neon
	part.Size = Vector3.new(width, width, distance)
	part.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -distance / 2)
	TweenService:Create(
		part,
		TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = Vector3.new(width * 0.1, width * 0.1, distance), Transparency = 1 }
	):Play()
	Debris:AddItem(part, seconds + 0.1)
end

-- รอยฟันฟ้า (ครึ่งวงกลมตามการเหวี่ยง) หน้าตัวละคร
function Lib.slash(root: BasePart, color: Color3, size: number, tilt: number)
	local part = newPart()
	part.Color = color
	part.Transparency = 0.25
	part.Size = Vector3.new(size, 0.2, size * 0.5)
	part.CFrame = root.CFrame * CFrame.new(0, 0.5, -3) * CFrame.Angles(0, 0, math.rad(tilt))
	fadeOut(part, 0.2, { Size = Vector3.new(size * 1.4, 0.05, size * 0.7) })
end

-- ภาพตามหลัง (afterimage) ของตัวละคร: ก๊อปสีเป็นแท่งโปร่งใสที่จุดนั้น
function Lib.afterimage(position: Vector3, color: Color3, seconds: number)
	local part = newPart()
	part.Color = color
	part.Transparency = 0.5
	part.Size = Vector3.new(2, 5, 1)
	part.Position = position
	fadeOut(part, seconds)
end

-- แขนยืด: แท่งสีผิว + กำปั้นกลมที่ปลาย ยืดจากไหล่ไปจุดปลายแล้วหด
function Lib.stretchArm(root: BasePart, side: number, length: number, color: Color3, seconds: number, yaw: number?)
	local facing = root.CFrame * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local origin = root.CFrame * Vector3.new(1.2 * side, 0.6, -0.8)
	local target = origin + facing.LookVector * length
	local arm = newPart()
	arm.Material = Enum.Material.SmoothPlastic
	arm.Color = color
	arm.Size = Vector3.new(0.7, 0.7, 0.2)
	arm.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -0.1)
	local fist = newPart()
	fist.Material = Enum.Material.SmoothPlastic
	fist.Shape = Enum.PartType.Ball
	fist.Color = color
	fist.Size = Vector3.one * 1.3
	fist.Position = origin
	local out = seconds * 0.4
	local back = seconds * 0.6
	local reach = (target - origin).Magnitude
	TweenService:Create(arm, TweenInfo.new(out, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.7, 0.7, reach),
		CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -reach / 2),
	}):Play()
	TweenService
		:Create(fist, TweenInfo.new(out, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = target })
		:Play()
	task.delay(out, function()
		TweenService:Create(arm, TweenInfo.new(back, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = Vector3.new(0.7, 0.7, 0.2),
			CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -0.1),
		}):Play()
		TweenService
			:Create(fist, TweenInfo.new(back, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = origin })
			:Play()
	end)
	Debris:AddItem(arm, seconds + 0.1)
	Debris:AddItem(fist, seconds + 0.1)
end

return Lib
