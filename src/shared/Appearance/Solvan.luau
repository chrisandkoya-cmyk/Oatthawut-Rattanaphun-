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

-- เดือยผมแหลม: 2 ท่อนซ้อนกัน ท่อนล่างกว้าง ท่อนบนเรียว เอียงตามทิศ ให้ได้ทรงผมตั้งแบบอนิเมะ
local function spike(
	x: number,
	z: number,
	lean: number,
	back: number,
	height: number,
	color: Color3
): { Builder.PartSpec }
	local base = CFrame.new(x, 0.75, z) * CFrame.Angles(math.rad(back), 0, math.rad(lean))
	return {
		{
			attach = "Head",
			size = Vector3.new(0.8, height * 0.6, 0.8),
			offset = base * CFrame.new(0, height * 0.25, 0),
			color = color,
		},
		{
			attach = "Head",
			size = Vector3.new(0.4, height * 0.6, 0.4),
			offset = base
				* CFrame.new(0, height * 0.7, 0)
				* CFrame.Angles(math.rad(back * 0.5), 0, math.rad(lean * 0.6)),
			color = color,
		},
	}
end

local function spikyHair(color: Color3): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {}
	local layout = {
		{ -0.75, -0.1, 34, -6, 2.2 },
		{ -0.3, -0.4, 14, -30, 2.0 },
		{ 0.25, -0.42, -10, -34, 2.3 },
		{ 0.75, -0.1, -34, -6, 2.1 },
		{ -0.55, 0.3, 26, 30, 2.3 },
		{ 0.0, 0.4, 0, 36, 2.6 },
		{ 0.55, 0.3, -24, 30, 2.2 },
		{ 0.0, -0.05, 0, 0, 2.8 },
	}
	for _, item in layout do
		for _, spec in spike(item[1], item[2], item[3], item[4], item[5], color) do
			table.insert(list, spec)
		end
	end
	return list
end

local function hair(color: Color3, tip: Color3?): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		{ attach = "Head", size = Vector3.new(2.1, 0.5, 1.2), offset = CFrame.new(0, 0.55, 0.02), color = color },
		{ attach = "Head", size = Vector3.new(0.25, 0.7, 1.1), offset = CFrame.new(-1.0, 0.2, 0.05), color = color },
		{ attach = "Head", size = Vector3.new(0.25, 0.7, 1.1), offset = CFrame.new(1.0, 0.2, 0.05), color = color },
		{ attach = "Head", size = Vector3.new(2.0, 0.8, 0.3), offset = CFrame.new(0, 0.25, 0.55), color = color },
	}
	for _, spec in spikyHair(color) do
		table.insert(list, spec)
	end
	if tip then
		-- ปลายผมสีฟ้า (ร่างอันติ)
		table.insert(
			list,
			{ attach = "Head", size = Vector3.new(2.15, 0.15, 1.25), offset = CFrame.new(0, 0.82, 0.02), color = tip }
		)
		table.insert(list, {
			attach = "Head",
			size = Vector3.new(2.05, 0.15, 0.35),
			offset = CFrame.new(0, -0.05, 0.57),
			color = tip,
		})
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
