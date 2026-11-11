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

-- ประกายระเบิดออก: แท่งสะเก็ดสีของท่า + ลูกแสงขาวร้อนเล็กๆ ปนกัน
function Lib.burst(position: Vector3, color: Color3, count: number, speed: number, seconds: number?)
	local life = seconds or 0.7
	for i = 1, count do
		local direction = Vector3.new(math.random() - 0.5, math.random() - 0.3, math.random() - 0.5)
		if direction.Magnitude < 0.01 then
			direction = Vector3.yAxis
		end
		direction = direction.Unit
		local part = newPart()
		local goalPosition = position + direction * speed * life
		if i % 3 == 0 then
			-- ลูกแสงขาวร้อน
			part.Shape = Enum.PartType.Ball
			part.Color = Color3.new(1, 1, 1)
			part.Size = Vector3.one * (0.5 + math.random() * 0.4)
			part.Position = position
			TweenService:Create(
				part,
				TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = goalPosition, Size = Vector3.one * 0.05, Transparency = 1 }
			):Play()
		else
			-- สะเก็ดยาวพุ่งตามทิศ
			part.Color = color
			local length = 1.2 + math.random() * 1.6
			part.Size = Vector3.new(0.25, 0.25, length)
			part.CFrame = CFrame.lookAt(position, position + direction)
			TweenService:Create(part, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.lookAt(goalPosition, goalPosition + direction),
				Size = Vector3.new(0.05, 0.05, 0.2),
				Transparency = 1,
			}):Play()
		end
		Debris:AddItem(part, life + 0.1)
	end
end

-- แสงวาบตอนโดน: ลูกแสงขาวขยายแล้วหาย + วงคลื่นกระแทกซ้อนสองชั้น + สะเก็ด
function Lib.impact(position: Vector3, color: Color3, size: number?)
	local scale = size or 1
	local flash = newPart()
	flash.Shape = Enum.PartType.Ball
	flash.Color = Color3.new(1, 1, 1)
	flash.Size = Vector3.one * 1.5 * scale
	flash.Position = position
	TweenService:Create(
		flash,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.one * 5 * scale, Transparency = 1 }
	):Play()
	Debris:AddItem(flash, 0.3)
	local glow = newPart()
	glow.Shape = Enum.PartType.Ball
	glow.Color = color
	glow.Transparency = 0.5
	glow.Size = Vector3.one * 2 * scale
	glow.Position = position
	TweenService:Create(
		glow,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.one * 8 * scale, Transparency = 1 }
	):Play()
	Debris:AddItem(glow, 0.4)
	Lib.ring(position, color, 4 * scale, 0.3, CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)))
	Lib.ring(position, Color3.new(1, 1, 1), 2.5 * scale, 0.22, CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0))
	Lib.burst(position, color, math.floor(8 * scale), 18 * scale, 0.45)
end

-- วงแหวนขยายออก (แนวนอนบนพื้น) มีวงขาวบางซ้อนข้างใน ให้ดูเรืองแสง
function Lib.ring(position: Vector3, color: Color3, radius: number, seconds: number?, vertical: CFrame?)
	local life = seconds or 0.4
	local base = vertical or (CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)))
	for layer = 1, 2 do
		local part = newPart()
		part.Shape = Enum.PartType.Cylinder
		part.Color = if layer == 1 then color else Color3.new(1, 1, 1)
		part.Transparency = if layer == 1 then 0.25 else 0.1
		part.Size = Vector3.new(0.3, 1, 1)
		part.CFrame = base
		local goal = radius * 2 * (if layer == 1 then 1 else 0.82)
		TweenService:Create(
			part,
			TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = Vector3.new(if layer == 1 then 0.3 else 0.12, goal, goal), Transparency = 1 }
		):Play()
		Debris:AddItem(part, life + 0.1)
	end
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
function Lib.beam(
	from: Vector3,
	to: Vector3,
	color: Color3,
	width: number,
	seconds: number,
	material: Enum.Material?,
	startTransparency: number?
)
	local distance = (to - from).Magnitude
	if distance < 0.05 then
		return
	end
	local part = newPart()
	part.Color = color
	part.Material = material or Enum.Material.Neon
	part.Transparency = startTransparency or 0
	part.Size = Vector3.new(width, width, distance)
	part.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -distance / 2)
	TweenService:Create(
		part,
		TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = Vector3.new(width * 0.1, width * 0.1, distance), Transparency = 1 }
	):Play()
	Debris:AddItem(part, seconds + 0.1)
	if (material or Enum.Material.Neon) == Enum.Material.Neon then
		-- ฮาโลโปร่งรอบนอก + แกนขาวเรียวข้างใน ให้ลำแสงดูมีมิติ
		for layer = 1, 2 do
			local extra = newPart()
			extra.Color = if layer == 1 then color else Color3.new(1, 1, 1)
			extra.Transparency = if layer == 1 then 0.65 else (startTransparency or 0.1)
			local w = if layer == 1 then width * 1.8 else width * 0.45
			extra.Size = Vector3.new(w, w, distance)
			extra.CFrame = part.CFrame
			TweenService:Create(
				extra,
				TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Size = Vector3.new(w * 0.1, w * 0.1, distance), Transparency = 1 }
			):Play()
			Debris:AddItem(extra, seconds + 0.1)
		end
	end
end

-- รอยฟัน/คลื่นหมัด: วงแสงตั้งฉากทิศที่หัน ขยายพุ่งไปข้างหน้า เห็นชัดจากกล้องหลังตัว
function Lib.slash(root: BasePart, color: Color3, size: number, tilt: number)
	local part = newPart()
	part.Shape = Enum.PartType.Cylinder
	part.Color = color
	part.Transparency = 0.3
	part.Size = Vector3.new(1.4, size * 0.6, size * 0.6)
	local start = root.CFrame * CFrame.new(0, 0.8, -3) * CFrame.Angles(0, math.rad(90), math.rad(tilt))
	part.CFrame = start
	TweenService:Create(
		part,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.8, size * 2, size * 2), Transparency = 1, CFrame = start * CFrame.new(-3, 0, 0) }
	):Play()
	Debris:AddItem(part, 0.35)
	-- แกนสีขาวซ้อนข้างใน ให้ดูเรืองแสงและเด่นขึ้น
	local core = newPart()
	core.Shape = Enum.PartType.Cylinder
	core.Color = Color3.new(1, 1, 1)
	core.Size = Vector3.new(0.6, size * 0.45, size * 0.45)
	core.CFrame = start
	TweenService:Create(
		core,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.4, size * 1.5, size * 1.5), Transparency = 1, CFrame = start * CFrame.new(-3, 0, 0) }
	):Play()
	Debris:AddItem(core, 0.3)
	Lib.burst(root.Position + root.CFrame.LookVector * 4, color, 8, 14, 0.4)
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

-- แขนยืด (ยาง): แท่งสีผิวหนา + กำปั้นเป็นก้อนมีข้อนิ้ว ยืดออกแบบเด้งยืดหยุ่นแล้วหดกลับ
function Lib.stretchArm(root: BasePart, side: number, length: number, color: Color3, seconds: number, yaw: number?)
	local facing = root.CFrame * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local origin = root.CFrame * Vector3.new(1.2 * side, 0.6, -0.8)
	local target = origin + facing.LookVector * length
	local thick = 1.3

	local arm = newPart()
	arm.Material = Enum.Material.SmoothPlastic
	arm.Reflectance = 0.08
	arm.Color = color
	arm.Size = Vector3.new(thick, thick, 0.2)
	arm.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -0.1)

	local fist = newPart()
	fist.Material = Enum.Material.SmoothPlastic
	fist.Reflectance = 0.08
	fist.Color = color
	fist.Size = Vector3.new(2, 1.8, 2)
	fist.CFrame = CFrame.lookAt(origin, target)
	-- ข้อนิ้ว 4 ก้อนด้านหน้ากำปั้น
	local knuckles: { Part } = {}
	for _ = 1, 4 do
		local knuckle = newPart()
		knuckle.Material = Enum.Material.SmoothPlastic
		knuckle.Shape = Enum.PartType.Ball
		knuckle.Color = color
		knuckle.Size = Vector3.one * 0.7
		knuckle.CFrame = fist.CFrame
		table.insert(knuckles, knuckle)
	end
	local function placeKnuckles(base: CFrame)
		for i, knuckle in knuckles do
			knuckle.CFrame = base * CFrame.new(-0.75 + (i - 1) * 0.5, 0.15, -1.05)
		end
	end
	placeKnuckles(fist.CFrame)

	local out = seconds * 0.45
	local back = seconds * 0.55
	local reach = (target - origin).Magnitude
	local stretched = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -reach / 2)
	local folded = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -0.1)
	local fistOut = CFrame.lookAt(target, target + facing.LookVector)
	local fistHome = CFrame.lookAt(origin, target)

	-- แถบสว่างบนแขน (ไฮไลต์ยาง) + รัศมีส้มโปร่งรอบแขนและกำปั้น ให้ดูเรืองและสวยขึ้น
	local shine = newPart()
	shine.Material = Enum.Material.SmoothPlastic
	shine.Color = color:Lerp(Color3.new(1, 1, 1), 0.45)
	shine.Size = Vector3.new(thick * 0.3, thick * 0.3, 0.2)
	shine.CFrame = folded * CFrame.new(0, thick * 0.4, 0)
	local halo = newPart()
	halo.Color = Color3.fromRGB(255, 190, 90)
	halo.Transparency = 0.7
	halo.Size = Vector3.new(thick * 2.2, thick * 2.2, 0.2)
	halo.CFrame = folded
	local fistGlow = newPart()
	fistGlow.Shape = Enum.PartType.Ball
	fistGlow.Color = Color3.fromRGB(255, 190, 90)
	fistGlow.Transparency = 0.6
	fistGlow.Size = Vector3.one * 3.4
	fistGlow.CFrame = fist.CFrame
	local elastic = TweenInfo.new(out, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(arm, elastic, { Size = Vector3.new(thick, thick, reach), CFrame = stretched }):Play()
	TweenService:Create(
		shine,
		elastic,
		{ Size = Vector3.new(thick * 0.3, thick * 0.3, reach), CFrame = stretched * CFrame.new(0, thick * 0.4, 0) }
	):Play()
	TweenService:Create(
		halo,
		elastic,
		{ Size = Vector3.new(thick * 2.2, thick * 2.2, reach), CFrame = stretched, Transparency = 0.85 }
	):Play()
	TweenService:Create(fistGlow, elastic, { CFrame = fistOut }):Play()
	task.delay(out, function()
		-- ถึงปลายทาง: แสงกระแทกที่กำปั้น (แขนที่ยืดไกลกระแทกแรงกว่า)
		Lib.impact(target, color:Lerp(Color3.fromRGB(255, 160, 60), 0.5), math.clamp(reach / 15, 0.6, 2.2))
	end)
	TweenService:Create(fist, elastic, { CFrame = fistOut }):Play()
	-- ข้อนิ้วตามกำปั้นทุกเฟรมระหว่างเคลื่อนที่
	local connection: RBXScriptConnection? = nil
	connection = game:GetService("RunService").RenderStepped:Connect(function()
		if not fist.Parent then
			if connection then
				connection:Disconnect()
			end
			return
		end
		placeKnuckles(fist.CFrame)
		fistGlow.CFrame = fist.CFrame
	end)
	task.delay(out + 0.12, function()
		local retract = TweenInfo.new(back, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(arm, retract, { Size = Vector3.new(thick, thick, 0.2), CFrame = folded }):Play()
		TweenService:Create(fist, retract, { CFrame = fistHome }):Play()
		TweenService:Create(shine, retract, {
			Size = Vector3.new(thick * 0.3, thick * 0.3, 0.2),
			CFrame = folded * CFrame.new(0, thick * 0.4, 0),
			Transparency = 1,
		}):Play()
		TweenService
			:Create(
				halo,
				retract,
				{ Size = Vector3.new(thick * 2.2, thick * 2.2, 0.2), CFrame = folded, Transparency = 1 }
			)
			:Play()
		TweenService:Create(fistGlow, retract, { CFrame = fistHome, Transparency = 1 }):Play()
	end)
	local life = seconds + 0.3
	Debris:AddItem(arm, life)
	Debris:AddItem(fist, life)
	Debris:AddItem(shine, life)
	Debris:AddItem(halo, life)
	Debris:AddItem(fistGlow, life)
	for _, knuckle in knuckles do
		Debris:AddItem(knuckle, life)
	end
end

return Lib
