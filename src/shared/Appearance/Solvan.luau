--!strict
-- หน้าตาโซลวาน (ตามภาพอ้างอิงที่คริสให้): ผมดำตั้งแหลมหลายแฉก คิ้วขมวด ชุดกี่ส้ม เสื้อในน้ำเงิน
-- สายคาดเอวน้ำเงินผูกปมห้อยหน้า ปลอกแขนน้ำเงิน แขนเปลือยเห็นกล้าม รองเท้าน้ำเงินขอบแดง
-- ร่างอันติ: ผมขาวปลายฟ้า ส่วนสีน้ำเงินกลายเป็นแสงฟ้าเรือง เส้นแสงตามแขน วงแหวนแสงหลังศีรษะ
-- ใช้ Part ล้วน ขนาด/ตำแหน่งเป็นค่าประมาณ ปรับที่ไฟล์นี้ไฟล์เดียว (ไม่ใส่ตัวอักษรบนอก ใช้วงกลมขาวเรียบแทน)

local Builder = require(script.Parent.Builder)

local SKIN = Color3.fromRGB(240, 196, 150)
local SKIN_SHADE = Color3.fromRGB(205, 150, 105)
local BLACK = Color3.fromRGB(28, 28, 32)
local ORANGE = Color3.fromRGB(247, 148, 29)
local ORANGE_DARK = Color3.fromRGB(205, 112, 14)
local BLUE = Color3.fromRGB(30, 62, 160)
local BLUE_DARK = Color3.fromRGB(18, 38, 105)
local RED = Color3.fromRGB(196, 32, 32)
local CYAN = Color3.fromRGB(63, 200, 224)
local WHITE = Color3.fromRGB(242, 244, 247)

-- ทรงผมตั้งแหลมแบบอนิเมะ: เดือยใหญ่เป็นแท่ง 3 ท่อนเรียวขึ้นและโค้งเล็กน้อย เรียงเป็นพัดชัดเจน
-- (ด้านหลัง 3 / ด้านข้าง 2 / ด้านบน 3 / ปอยหน้าม้า 3 ที่เอนไปข้างหน้า) ฐานผมเป็นก้อนกลม
local function ball(
	x: number,
	y: number,
	z: number,
	d: number,
	color: Color3,
	material: Enum.Material?
): Builder.PartSpec
	return {
		attach = "Head",
		shape = "Ball",
		size = Vector3.new(d, d, d),
		offset = CFrame.new(x, y, z),
		color = color,
		material = material,
	}
end

-- back = เอนไปหลัง (+) หรือหน้า (-) องศา, lean = เอนไปข้างองศา (+ = ซ้ายของภาพ)
local function spike(
	x: number,
	y: number,
	z: number,
	lean: number,
	back: number,
	height: number,
	color: Color3
): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {}
	local cur = CFrame.new(x, y, z) * CFrame.Angles(math.rad(back), 0, math.rad(lean))
	local widths = { 0.95, 0.65, 0.35 }
	local shares = { 0.42, 0.34, 0.24 }
	for i, width in widths do
		local length = height * shares[i]
		table.insert(list, {
			attach = "Head",
			size = Vector3.new(width, length, width * 0.7),
			offset = cur * CFrame.new(0, length / 2, 0),
			color = color,
		})
		-- ท่อนถัดไปโค้งตามทิศเดิมเพิ่มอีกนิด
		cur = cur * CFrame.new(0, length * 0.92, 0) * CFrame.Angles(math.rad(back * 0.18), 0, math.rad(lean * 0.2))
	end
	return list
end

local function spikyHair(color: Color3): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {}
	-- { x, y, z, lean, back, height }
	local layout = {
		-- ด้านหลัง (พุ่งไปหลังและขึ้น)
		{ 0.0, 0.5, 0.3, 0, 38, 2.4 },
		{ -0.6, 0.5, 0.25, 30, 30, 2.2 },
		{ 0.6, 0.5, 0.25, -30, 30, 2.2 },
		-- ด้านข้าง (พุ่งออกข้าง)
		{ -0.8, 0.45, 0.0, 62, 6, 1.9 },
		{ 0.8, 0.45, 0.0, -62, 6, 1.9 },
		-- ด้านบน
		{ -0.4, 0.6, -0.05, 18, -6, 2.3 },
		{ 0.0, 0.62, -0.1, 0, -4, 2.5 },
		{ 0.4, 0.6, -0.05, -16, -6, 2.2 },
		-- ปอยหน้าม้าเอนไปข้างหน้าเหนือคิ้ว
		{ -0.45, 0.62, -0.3, 8, -68, 1.3 },
		{ 0.15, 0.64, -0.32, -6, -72, 1.2 },
		{ 0.6, 0.6, -0.25, -20, -58, 1.0 },
	}
	for _, item in layout do
		for _, spec in spike(item[1], item[2], item[3], item[4], item[5], item[6], color) do
			table.insert(list, spec)
		end
	end
	return list
end

local function hair(color: Color3, tip: Color3?): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		ball(0, 0.4, 0.2, 1.75, color), -- กระหม่อม (ไม่ล้ำหน้าผาก)
		ball(-0.85, 0.2, 0.2, 0.95, color), -- จอนผมซ้าย
		ball(0.85, 0.2, 0.2, 0.95, color), -- จอนผมขวา
		ball(0, 0.05, 0.5, 1.5, color), -- ท้ายทอย
	}
	for _, spec in spikyHair(color) do
		table.insert(list, spec)
	end
	if tip then
		-- ปลายผมสีฟ้า (ร่างอันติ)
		table.insert(list, ball(0, 0.85, 0.2, 1.3, tip, Enum.Material.Neon))
		table.insert(list, ball(0, 0.0, 0.55, 1.2, tip, Enum.Material.Neon))
	end
	return list
end

local function extend(into: { Builder.PartSpec }, from: { Builder.PartSpec })
	for _, spec in from do
		table.insert(into, spec)
	end
end

-- ชุดกี่: คอเสื้อในน้ำเงิน ปกเสื้อส้มไขว้ วงกลมขาวบนอก ผ้าพับไหล่ กล้ามแขน ปลอกแขน สายคาดเอวผูกปม รองเท้า
-- accent = สีน้ำเงินของชุด (ร่างอันติเปลี่ยนเป็นแสงฟ้า), dark = น้ำเงินเข้มของชายผ้า
local function gi(accent: Color3, dark: Color3, material: Enum.Material): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		-- คิ้วขมวด (ปลายด้านในต่ำ)
		{
			attach = "Head",
			size = Vector3.new(0.6, 0.14, 0.1),
			offset = CFrame.new(-0.4, 0.3, -0.58) * CFrame.Angles(0, 0, math.rad(-20)),
			color = BLACK,
		},
		{
			attach = "Head",
			size = Vector3.new(0.6, 0.14, 0.1),
			offset = CFrame.new(0.4, 0.3, -0.58) * CFrame.Angles(0, 0, math.rad(20)),
			color = BLACK,
		},
		-- เสื้อในน้ำเงินตรงคอ + ปกส้มไขว้เป็นรูปตัววี
		{
			attach = "UpperTorso",
			size = Vector3.new(0.95, 0.5, 0.1),
			offset = CFrame.new(0, 0.55, -0.52),
			color = accent,
			material = material,
		},
		{
			attach = "UpperTorso",
			size = Vector3.new(1.1, 0.32, 0.12),
			offset = CFrame.new(-0.55, 0.45, -0.55) * CFrame.Angles(0, 0, math.rad(-32)),
			color = ORANGE_DARK,
		},
		{
			attach = "UpperTorso",
			size = Vector3.new(1.1, 0.32, 0.12),
			offset = CFrame.new(0.55, 0.45, -0.55) * CFrame.Angles(0, 0, math.rad(32)),
			color = ORANGE_DARK,
		},
		-- วงกลมขาวบนอกซ้าย (ไม่มีตัวอักษร)
		{
			attach = "UpperTorso",
			shape = "Cylinder",
			size = Vector3.new(0.08, 0.5, 0.5),
			offset = CFrame.new(0.55, 0.05, -0.52) * CFrame.Angles(0, math.rad(90), 0),
			color = WHITE,
		},
		-- ผ้าไหล่สีน้ำเงินพับลง
		{
			attach = "LeftUpperArm",
			size = Vector3.new(1.25, 0.3, 1.25),
			offset = CFrame.new(0, 0.5, 0),
			color = accent,
			material = material,
		},
		{
			attach = "RightUpperArm",
			size = Vector3.new(1.25, 0.3, 1.25),
			offset = CFrame.new(0, 0.5, 0),
			color = accent,
			material = material,
		},
		-- สายคาดเอวผูกปมห้อยชายผ้า 2 เส้นด้านหน้า
		{
			attach = "LowerTorso",
			size = Vector3.new(2.15, 0.5, 1.15),
			offset = CFrame.new(0, 0.2, 0),
			color = accent,
			material = material,
		},
		{
			attach = "LowerTorso",
			size = Vector3.new(0.6, 0.6, 0.3),
			offset = CFrame.new(0, 0.2, -0.65),
			color = dark,
		},
		{
			attach = "LowerTorso",
			size = Vector3.new(0.4, 1.2, 0.1),
			offset = CFrame.new(-0.2, -0.55, -0.7) * CFrame.Angles(0, 0, math.rad(8)),
			color = dark,
		},
		{
			attach = "LowerTorso",
			size = Vector3.new(0.4, 1.0, 0.1),
			offset = CFrame.new(0.25, -0.5, -0.7) * CFrame.Angles(0, 0, math.rad(-10)),
			color = accent,
			material = material,
		},
	}
	for _, hand in { "LeftHand", "RightHand" } do
		-- ปลอกแขนน้ำเงิน
		table.insert(list, {
			attach = hand,
			size = Vector3.new(1.15, 0.45, 1.15),
			offset = CFrame.new(0, 0.3, 0),
			color = accent,
			material = material,
		})
	end
	for _, side in { "LeftUpperArm", "RightUpperArm" } do
		-- เส้นกล้ามแขน (เงาผิวเข้ม)
		table.insert(list, {
			attach = side,
			size = Vector3.new(0.12, 0.8, 0.12),
			offset = CFrame.new(0, -0.05, -0.5),
			color = SKIN_SHADE,
		})
		table.insert(list, {
			attach = side,
			size = Vector3.new(0.5, 0.12, 0.12),
			offset = CFrame.new(0, 0.3, -0.5),
			color = SKIN_SHADE,
		})
	end
	for _, leg in { "LeftLowerLeg", "RightLowerLeg" } do
		-- ขอบรองเท้าแดง + ปลอกรองเท้าน้ำเงิน
		table.insert(list, {
			attach = leg,
			size = Vector3.new(1.12, 0.45, 1.12),
			offset = CFrame.new(0, -0.35, 0),
			color = accent,
			material = material,
		})
		table.insert(
			list,
			{ attach = leg, size = Vector3.new(1.14, 0.12, 1.14), offset = CFrame.new(0, -0.08, 0), color = RED }
		)
	end
	return list
end

local baseParts = hair(BLACK, nil)
extend(baseParts, gi(BLUE, BLUE_DARK, Enum.Material.SmoothPlastic))

local ultParts = hair(WHITE, CYAN)
extend(ultParts, gi(CYAN, BLUE, Enum.Material.Neon))
-- เส้นแสงตามแขนเหมือนรอยร้าว
for _, side in { "Left", "Right" } do
	for _, segment in { "UpperArm", "LowerArm" } do
		table.insert(ultParts, {
			attach = side .. segment,
			size = Vector3.new(0.12, 0.9, 0.12),
			offset = CFrame.new(side == "Left" and 0.42 or -0.42, 0, -0.2),
			color = CYAN,
			material = Enum.Material.Neon,
		})
	end
end
-- วงแหวนแสงบางๆ ลอยหลังศีรษะ
table.insert(ultParts, {
	attach = "Head",
	shape = "Cylinder",
	size = Vector3.new(0.08, 2.8, 2.8),
	offset = CFrame.new(0, 0.7, 1.1) * CFrame.Angles(0, math.rad(90), 0),
	color = CYAN,
	material = Enum.Material.Neon,
	transparency = 0.25,
})
-- ประกายแสงจากมือ
for _, hand in { "LeftHand", "RightHand" } do
	table.insert(ultParts, {
		attach = hand,
		size = Vector3.new(0.3, 0.3, 0.3),
		offset = CFrame.new(0, -0.3, 0),
		color = CYAN,
		material = Enum.Material.Neon,
		transparency = 1,
		emitter = { color = CYAN, rate = 12, size = 0.5, lifetime = 0.6, speed = 2 },
	})
end

local bodyColors: { [string]: Color3 } = {
	Head = SKIN,
	LeftUpperArm = SKIN,
	RightUpperArm = SKIN,
	LeftLowerArm = SKIN,
	RightLowerArm = SKIN,
	LeftHand = SKIN,
	RightHand = SKIN,
	UpperTorso = ORANGE,
	LowerTorso = ORANGE,
	LeftUpperLeg = ORANGE,
	RightUpperLeg = ORANGE,
	LeftLowerLeg = ORANGE,
	RightLowerLeg = ORANGE,
	LeftFoot = BLUE,
	RightFoot = BLUE,
}

local looks = {
	base = { colors = bodyColors, parts = baseParts } :: Builder.Look,
	ultimate = { colors = bodyColors, parts = ultParts } :: Builder.Look,
}

return looks
