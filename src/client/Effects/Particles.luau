--!strict
-- พรีเซ็ตอนุภาคที่ดึงค่ามาจากไฟล์เอฟเฟกต์ฟรี "thats red and pink.rbxl" ที่คริสให้ (ค่า ParticleEmitter เท่านั้น
-- ไม่ใช้สคริปต์จากไฟล์) texture เป็น rbxassetid ของเจ้าของไฟล์ ถ้าโหลดไม่ขึ้นให้ตัวเอฟเฟกต์เดิมใน Lib ยังทำงานตามปกติ
-- ใช้ผ่าน Particles.emit(ชื่อพรีเซ็ต, ตำแหน่ง/CFrame, สี, สเกล) สีจะย้อนแทนสีชมพูเดิมทั้งหมด

local Debris = game:GetService("Debris")

export type Spec = {
	tex: string,
	size: { { number } }, -- { เวลา, ค่า, ช่วงสุ่ม }
	transparency: { { number } },
	life: { number },
	speed: { number },
	rotation: { number },
	rotSpeed: { number },
	spread: { number },
	orientation: number,
	zOffset: number,
	brightness: number,
	lightEmission: number,
	count: number,
	delay: number,
}

local Particles = {}

local presets: { [string]: { Spec } } = {
	hit = {
		{
			tex = "rbxassetid://18675294168",
			size = { { 0, 3, 0 }, { 1, 3, 0.746 } },
			transparency = { { 0, 0, 0 }, { 1, 1, 0 } },
			life = { 0.6, 1 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0.1,
			brightness = 10,
			lightEmission = 0,
			count = 3,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://18675294168",
			size = { { 0, 3, 0 }, { 1, 3, 0.746 } },
			transparency = { { 0, 0, 0 }, { 1, 1, 0 } },
			life = { 0.6, 1.2 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0,
			brightness = 0.5,
			lightEmission = 0,
			count = 3,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://18324838775",
			size = { { 0, 1.343, 1.343 }, { 1, 8.806, 1.194 } },
			transparency = { { 0, 0.568, 0.126 }, { 1, 1, 0 } },
			life = { 0.6, 1.2 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 50, 120 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0.01,
			brightness = 1,
			lightEmission = 0,
			count = 8,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16892346551",
			size = { { 0, 4.527, 1.244 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.05, 0.15 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { 0, 0 },
			orientation = 0,
			zOffset = 5,
			brightness = 3,
			lightEmission = 0,
			count = 3,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16892346551",
			size = { { 0, 5.522, 2.189 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.05, 0.1 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0.2,
			brightness = 5,
			lightEmission = 0,
			count = 3,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 0, 0 }, { 0.2, 1.642, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 5,
			brightness = 5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 0, 0 }, { 0.2, 1.642, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 4.9,
			brightness = 0.5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16879573368",
			size = { { 0, 0, 0 }, { 0.197, 0.945, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 4,
			brightness = 0.5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16879573368",
			size = { { 0, 0, 0 }, { 0.197, 0.945, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 4,
			brightness = 5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16867347280",
			size = { { 0, 0, 0 }, { 0.191, 1.642, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0.738, 0.06 }, { 1, 1, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 3.9,
			brightness = 0.5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
		{
			tex = "rbxassetid://16867347280",
			size = { { 0, 0, 0 }, { 0.191, 1.642, 0.448 }, { 1, 0, 0 } },
			transparency = { { 0, 0.738, 0.06 }, { 1, 1, 0 } },
			life = { 0.5, 1 },
			speed = { 5, 10 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 3.9,
			brightness = 5,
			lightEmission = 0,
			count = 15,
			delay = 0.1,
		},
	},
	ray = {
		{
			tex = "rbxassetid://16879845558",
			size = { { 0, 2, 0 }, { 0.803, 2, 0 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 0, 60 },
			rotation = { 90, 90 },
			rotSpeed = { 0, 0 },
			spread = { -1, 1 },
			orientation = 2,
			zOffset = 1,
			brightness = 4,
			lightEmission = 0,
			count = 25,
			delay = 0,
		},
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 1.045, 0.647 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 0, 50 },
			rotation = { 90, 90 },
			rotSpeed = { 0, 0 },
			spread = { -5, 5 },
			orientation = 2,
			zOffset = 0,
			brightness = 4,
			lightEmission = 0,
			count = 45,
			delay = 0,
		},
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 1.045, 0.647 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.5, 1 },
			speed = { 0, 50 },
			rotation = { 90, 90 },
			rotSpeed = { 0, 0 },
			spread = { -5, 5 },
			orientation = 2,
			zOffset = -0.01,
			brightness = 0.5,
			lightEmission = 0,
			count = 45,
			delay = 0,
		},
	},
	floor = {
		{
			tex = "rbxassetid://17062454564",
			size = {
				{ 0, 10, 0 },
				{ 0.1, 1.539, 0 },
				{ 0.2, 0.716, 0 },
				{ 0.3, 0.361, 0 },
				{ 0.4, 0.182, 0 },
				{ 0.5, 0.088, 0 },
				{ 0.6, 0.038, 0 },
				{ 0.7, 0.014, 0 },
				{ 0.8, 0.004, 0 },
				{ 0.9, 0, 0 },
				{ 1, 0, 0 },
				{ 1, 0, 0 },
			},
			transparency = { { 0, 1, 0 }, { 0.08, 0, 0 }, { 0.91, 0, 0 }, { 1, 1, 0 } },
			life = { 1, 1 },
			speed = { 0.001, 0.001 },
			rotation = { 0, 0 },
			rotSpeed = { 180, 180 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0,
			brightness = 4,
			lightEmission = 0,
			count = 3,
			delay = 0,
		},
		{
			tex = "rbxassetid://17062454564",
			size = {
				{ 0, 20, 0 },
				{ 0.1, 3.077, 0 },
				{ 0.2, 1.431, 0 },
				{ 0.3, 0.722, 0 },
				{ 0.4, 0.365, 0 },
				{ 0.5, 0.176, 0 },
				{ 0.6, 0.077, 0 },
				{ 0.7, 0.028, 0 },
				{ 0.8, 0.007, 0 },
				{ 0.9, 0.001, 0 },
				{ 1, 0, 0 },
				{ 1, 0, 0 },
			},
			transparency = { { 0, 1, 0 }, { 0.08, 0, 0 }, { 0.91, 0, 0 }, { 1, 1, 0 } },
			life = { 1, 1 },
			speed = { 0.001, 0.001 },
			rotation = { 0, 0 },
			rotSpeed = { 180, 180 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = -0.01,
			brightness = 0.5,
			lightEmission = 0,
			count = 3,
			delay = 0,
		},
		{
			tex = "rbxassetid://18690420192",
			size = {
				{ 0, 1, 0 },
				{ 0.1, 1.192, 0 },
				{ 0.2, 1.929, 0 },
				{ 0.3, 3.155, 0 },
				{ 0.4, 4.78, 0 },
				{ 0.5, 6.734, 0 },
				{ 0.6, 8.965, 0 },
				{ 0.7, 11.435, 0 },
				{ 0.8, 14.112, 0 },
				{ 0.9, 16.974, 0 },
				{ 1, 20, 0 },
				{ 1, 20, 0 },
			},
			transparency = { { 0, 0.678, 0.055 }, { 1, 1, 0 } },
			life = { 1, 1.3 },
			speed = { 0.001, 0.001 },
			rotation = { -360, 360 },
			rotSpeed = { 0, 0 },
			spread = { 0, 0 },
			orientation = 3,
			zOffset = 0.01,
			brightness = 1,
			lightEmission = 0,
			count = 3,
			delay = 0,
		},
	},
	spark = {
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 0, 0 }, { 0.03, 2.139, 1.095 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.1, 0.35 },
			speed = { 2, 8 },
			rotation = { 0, 0 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 2,
			brightness = 3.8,
			lightEmission = 0,
			count = 20,
			delay = 0,
		},
		{
			tex = "rbxassetid://17062454564",
			size = { { 0, 0, 0 }, { 0.03, 2.139, 1.095 }, { 1, 0, 0 } },
			transparency = { { 0, 0, 0 }, { 1, 0, 0 } },
			life = { 0.1, 0.35 },
			speed = { 2, 8 },
			rotation = { 0, 0 },
			rotSpeed = { 0, 0 },
			spread = { -360, 360 },
			orientation = 0,
			zOffset = 2,
			brightness = 0.5,
			lightEmission = 0,
			count = 20,
			delay = 0,
		},
	},
}

local function numberSequence(points: { { number } }, scale: number): NumberSequence
	local keys = {}
	local last = -1
	for _, point in points do
		if point[1] > last then -- ข้ามคีย์ที่เวลาซ้ำ
			table.insert(keys, NumberSequenceKeypoint.new(point[1], point[2] * scale, (point[3] or 0) * scale))
			last = point[1]
		end
	end
	return NumberSequence.new(keys)
end

local function plainSequence(points: { { number } }): NumberSequence
	local keys = {}
	local last = -1
	for _, point in points do
		if point[1] > last then
			table.insert(keys, NumberSequenceKeypoint.new(point[1], point[2], point[3] or 0))
			last = point[1]
		end
	end
	return NumberSequence.new(keys)
end

-- เล่นพรีเซ็ตที่ตำแหน่ง/CFrame: สร้างพาร์ตล่องหนชั่วคราวพร้อมอนุภาค แล้วทิ้งเองเมื่อจบ
function Particles.emit(name: string, where: Vector3 | CFrame, tint: Color3, scale: number?, faceCamera: boolean?)
	local list = presets[name]
	if not list then
		return
	end
	local factor = scale or 1
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.CastShadow = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one * 0.2
	local placed = if typeof(where) == "CFrame" then where else CFrame.new(where)
	local camera = workspace.CurrentCamera
	if faceCamera and camera and (camera.CFrame.Position - placed.Position).Magnitude > 0.1 then
		-- ให้แกน Y (ทิศปล่อยอนุภาค) ชี้เข้าหากล้อง สไปรต์แนว VelocityPerpendicular จะหันหน้าเข้าหาผู้เล่น
		placed = CFrame.lookAt(placed.Position, camera.CFrame.Position) * CFrame.Angles(math.rad(-90), 0, 0)
	end
	anchor.CFrame = placed
	anchor.Parent = workspace
	local longest = 0.5
	for _, spec in list do
		local emitter = Instance.new("ParticleEmitter")
		emitter.Texture = spec.tex
		emitter.Color = ColorSequence.new(tint)
		emitter.Size = numberSequence(spec.size, factor)
		emitter.Transparency = plainSequence(spec.transparency)
		emitter.Lifetime = NumberRange.new(spec.life[1], spec.life[2])
		emitter.Speed = NumberRange.new(spec.speed[1] * factor, spec.speed[2] * factor)
		emitter.Rotation = NumberRange.new(spec.rotation[1], spec.rotation[2])
		emitter.RotSpeed = NumberRange.new(spec.rotSpeed[1], spec.rotSpeed[2])
		emitter.SpreadAngle = Vector2.new(spec.spread[1], spec.spread[2])
		emitter.Orientation = (Enum.ParticleOrientation :: any):FromValue(spec.orientation)
			or Enum.ParticleOrientation.FacingCamera
		emitter.ZOffset = spec.zOffset
		emitter.Brightness = spec.brightness
		emitter.LightEmission = spec.lightEmission
		emitter.Rate = 0
		emitter.Enabled = false
		emitter.Parent = anchor
		longest = math.max(longest, spec.delay + spec.life[2])
		task.delay(spec.delay, function()
			if emitter.Parent then
				emitter:Emit(spec.count)
			end
		end)
	end
	Debris:AddItem(anchor, longest + 0.5)
end

return Particles
