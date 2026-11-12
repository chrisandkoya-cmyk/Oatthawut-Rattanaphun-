--!strict
-- สูตรเอฟเฟกต์สำเร็จรูปแบบหลายชั้น (ได้จากการรีเสิร์ชเกมต่อสู้อนิเมะ Roblox/งาน VFX ลำแสงสไตล์อนิเมะ):
--   ชาร์จ = ประกายถูกดูดเข้าหาลูกพลังซ้อนชั้น + ไฟ | ลำแสง = ฮาโลนอก + สีหลัก + แกนขาว + วงเกลียววิ่งตามลำ
--   + ปากกระบอกวาบ + แสงที่ปลาย | โดน = แสงวาบ + วงคลื่น + สะเก็ด + เศษหิน + กล้องสั่น (Juice)
-- ใช้ Part/Tween ล้วน ภาพอย่างเดียว ไม่มีผลต่อดาเมจ

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Lib = require(script.Parent.Lib)
local Juice = require(script.Parent.Juice)
local Particles = require(script.Parent.Particles)

local Recipes = {}

local WHITE = Color3.new(1, 1, 1)

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

local function tween(instance: Instance, seconds: number, goal: { [string]: any }, style: Enum.EasingStyle?)
	TweenService
		:Create(instance, TweenInfo.new(seconds, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
		:Play()
end

-- แสงไฟกระพริบ ณ จุดหนึ่ง (ส่องพื้น/ตัวละครรอบๆ ให้ดูมีพลัง)
function Recipes.light(position: Vector3, color: Color3, brightness: number, range: number, seconds: number)
	local holder = newPart()
	holder.Transparency = 1
	holder.Size = Vector3.one * 0.2
	holder.Position = position
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Parent = holder
	tween(light, seconds, { Brightness = 0 })
	Debris:AddItem(holder, seconds + 0.1)
end

-- ประกายถูกดูดเข้าหาจุดศูนย์กลางจากทรงกลมรอบๆ (ฉากชาร์จพลัง)
function Recipes.converge(center: Vector3, color: Color3, count: number, radius: number, seconds: number)
	for i = 1, count do
		local direction = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		if direction.Magnitude < 0.01 then
			direction = Vector3.xAxis
		end
		local start = center + direction.Unit * radius * (0.7 + math.random() * 0.5)
		local part = newPart()
		part.Shape = Enum.PartType.Ball
		part.Color = if i % 3 == 0 then WHITE else color
		part.Size = Vector3.one * (0.35 + math.random() * 0.35)
		part.Position = start
		part.Transparency = 0.1
		local delay = math.random() * seconds * 0.6
		task.delay(delay, function()
			if part.Parent then
				tween(part, seconds - delay, { Position = center, Size = Vector3.one * 0.05, Transparency = 1 })
			end
		end)
		Debris:AddItem(part, seconds + 0.2)
	end
end

-- ชาร์จพลัง: ลูกพลังซ้อน 3 ชั้น (ขาว/สี/ฮาโล) ขยายแล้วหดวาบ + ประกายถูกดูด + ไฟ
function Recipes.charge(root: BasePart, color: Color3, seconds: number, radius: number?)
	local size = radius or 3.5
	local center = root.Position + root.CFrame.LookVector * 2.5
	for layer = 1, 3 do
		local sphere = newPart()
		sphere.Shape = Enum.PartType.Ball
		sphere.Color = if layer == 1 then WHITE elseif layer == 2 then color else color:Lerp(WHITE, 0.3)
		sphere.Transparency = if layer == 1 then 0.1 elseif layer == 2 then 0.35 else 0.75
		local scale = if layer == 1 then 0.5 elseif layer == 2 then 0.8 else 1.2
		sphere.Size = Vector3.one * 0.5
		sphere.Position = center
		tween(sphere, seconds, { Size = Vector3.one * size * scale })
		-- ตามตัวละครระหว่างชาร์จ
		local offset = center - root.Position
		local connection: RBXScriptConnection? = nil
		connection = game:GetService("RunService").RenderStepped:Connect(function()
			if not sphere.Parent or not root.Parent then
				if connection then
					connection:Disconnect()
				end
				return
			end
			sphere.Position = root.Position + offset
		end)
		Debris:AddItem(sphere, seconds + 0.05)
	end
	Recipes.converge(center, color, 26, size * 2.6, seconds)
	Recipes.light(center, color, 3, 24, seconds)
	Particles.emit("spark", center, color, 1, true)
end

-- วงเกลียววิ่งตามลำแสง (สร้างความรู้สึกหมุนวน)
local function spiralRings(from: Vector3, to: Vector3, color: Color3, width: number, seconds: number)
	local axis = to - from
	local distance = axis.Magnitude
	if distance < 1 then
		return
	end
	local cf = CFrame.lookAt(from, to)
	local rings = math.clamp(math.floor(distance / 7), 3, 9)
	for i = 1, rings do
		local ring = newPart()
		ring.Shape = Enum.PartType.Cylinder
		ring.Color = if i % 2 == 0 then WHITE else color
		ring.Transparency = 0.2
		ring.Size = Vector3.new(0.35, width * 1.6, width * 1.6)
		local startAt = cf
			* CFrame.new(0, 0, -distance * ((i - 1) / rings))
			* CFrame.Angles(0, math.rad(90), math.rad(i * 25))
		ring.CFrame = startAt
		tween(ring, seconds, {
			CFrame = startAt * CFrame.new(0, 0, -distance * 0.35),
			Size = Vector3.new(0.2, width * 2.4, width * 2.4),
			Transparency = 1,
		})
		Debris:AddItem(ring, seconds + 0.1)
	end
end

-- ลำแสงใหญ่หลายชั้น: ปากกระบอก (พอร์ทัล) + ลำฮาโล/สี/แกนขาว + วงเกลียว + หัวลำ + ผลกระแทกที่ปลาย
function Recipes.kiBeam(
	root: BasePart,
	color: Color3,
	length: number,
	width: number,
	seconds: number,
	hitAtEnd: boolean?
)
	local forward = root.CFrame.LookVector
	local origin = root.Position + forward * 2.5
	local target = origin + forward * length
	-- ปากกระบอกวาบ
	Lib.orb(origin, WHITE, width * 1.2, width * 3, 0.25)
	Lib.ring(origin, color, width * 1.8, 0.35, CFrame.lookAt(origin, target) * CFrame.Angles(0, math.rad(90), 0))
	Recipes.light(origin, color, 4, 30, seconds)
	-- ลำ 3 ชั้น
	Lib.beam(origin, target, color, width, seconds)
	Lib.beam(origin, target, WHITE, width * 0.5, seconds)
	spiralRings(origin, target, color, width, seconds * 0.7)
	-- หัวลำพุ่งไปปลายทาง
	local head = newPart()
	head.Shape = Enum.PartType.Ball
	head.Color = WHITE
	head.Size = Vector3.one * width * 1.6
	head.Position = origin
	tween(head, math.min(seconds, 0.4), { Position = target, Size = Vector3.one * width * 0.6, Transparency = 0.6 })
	Debris:AddItem(head, seconds)
	Lib.rayBurst(origin, target, color, 1 + width / 8)
	if hitAtEnd then
		task.delay(math.min(seconds, 0.4), function()
			Lib.impact(target, color, 1 + width / 6)
			Recipes.light(target, color, 5, 36, 0.5)
			Juice.shockwave(Vector3.new(target.X, root.Position.Y - 2.5, target.Z), color, math.clamp(width * 2, 8, 20))
		end)
	end
end

-- ฟันเสี้ยวพระจันทร์ซ้อน 2 ชั้นพร้อมประกาย (M1/ท่าฟัน)
function Recipes.slash(root: BasePart, color: Color3, size: number, tilt: number)
	Lib.slash(root, color, size, tilt)
	Lib.slash(root, WHITE, size * 0.7, tilt + 8)
	Lib.afterimage(root.Position - root.CFrame.LookVector * 1.5, color, 0.25)
end

-- แดช/พุ่ง: ภาพค้างหลายก้อนไล่ตามเส้นทางด้านหลัง + เส้นสปีด
function Recipes.dash(root: BasePart, color: Color3)
	for i = 1, 5 do
		Lib.afterimage(root.Position - root.CFrame.LookVector * (i * 2.2), color, 0.2 + i * 0.05)
	end
	Juice.speedLines(root, color, 12, 12)
	Lib.burst(root.Position, color, 8, 14)
end

-- ทุบพื้น: โดมกระแทก + วงอนุภาคพื้น + ฝุ่น + เศษหิน
function Recipes.slam(ground: Vector3, color: Color3, radius: number)
	Juice.shockwave(ground, color, radius)
	Lib.groundBurst(ground, color, radius / 12)
	Lib.burst(ground + Vector3.new(0, 1, 0), Color3.fromRGB(170, 150, 120), 14, 22, 0.7)
	Recipes.light(ground + Vector3.new(0, 2, 0), color, 4, radius * 3, 0.5)
end

-- ออร่าตอนแปลงร่าง: ประกายลอยขึ้น + เสาแสงบาง + วงกระแทก
function Recipes.aura(root: BasePart, color: Color3, seconds: number)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 1
	emitter.Rate = 60
	emitter.Lifetime = NumberRange.new(0.6, 1.1)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(25, 25)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = root
	Debris:AddItem(emitter, seconds)
	task.delay(seconds - 0.8, function()
		if emitter.Parent then
			emitter.Enabled = false
		end
	end)
end

return Recipes
