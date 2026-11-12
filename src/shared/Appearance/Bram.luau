--!strict
-- หน้าตาแบรม (ตามภาพอ้างอิงที่คริสให้): ผิวแทน หมวกฟางปีกกว้างแถบแดง ผมดำสั้นยุ่ง แผลใต้ตา
-- เสื้อกั๊กน้ำเงินเปิดอกเห็นกล้าม กระดุมทอง กางเกงขาสั้นดำขอบขาวฟู รองเท้าแตะ ปลอกแขนดำที่แขนซ้าย
-- ร่างอันติ: ส่วนเดิมคงไว้ + เส้นเรืองแสงส้มทองเหมือนขดลวดสปริงตามแขนขา กระดุม/แถบหมวกเรืองแสง ประกายไฟที่กำปั้น
-- ใช้ Part ล้วน ขนาด/ตำแหน่งเป็นค่าประมาณ ปรับที่ไฟล์นี้ไฟล์เดียว

local Builder = require(script.Parent.Builder)

local SKIN = Color3.fromRGB(214, 156, 106)
local SKIN_SHADE = Color3.fromRGB(176, 118, 74)
local HAIR = Color3.fromRGB(24, 22, 24)
local STRAW = Color3.fromRGB(232, 196, 112)
local STRAW_DARK = Color3.fromRGB(196, 158, 82)
local RED = Color3.fromRGB(196, 30, 30)
local VEST = Color3.fromRGB(26, 62, 158)
local GOLD = Color3.fromRGB(240, 196, 60)
local SHORTS = Color3.fromRGB(22, 22, 26)
local FLUFF = Color3.fromRGB(244, 244, 244)
local SANDAL = Color3.fromRGB(96, 62, 36)
local BLACK = Color3.fromRGB(24, 24, 26)
local GLOW = Color3.fromRGB(255, 154, 46)

local function extend(into: { Builder.PartSpec }, from: { Builder.PartSpec })
	for _, spec in from do
		table.insert(into, spec)
	end
end

-- หมวกฟาง: ปีกกว้างแบน + ยอดกลม + แถบแดงรอบฐาน (หน้าตาตามแบบ ใช้ Cylinder ซ้อน)
local function strawHat(band: Color3, material: Enum.Material): { Builder.PartSpec }
	return {
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.18, 4.2, 4.2),
			offset = CFrame.new(0, 0.62, 0) * CFrame.Angles(0, 0, math.rad(90)),
			color = STRAW,
		},
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.12, 3.2, 3.2),
			offset = CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, math.rad(90)),
			color = STRAW_DARK,
		},
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.9, 2.4, 2.4),
			offset = CFrame.new(0, 1.0, 0) * CFrame.Angles(0, 0, math.rad(90)),
			color = STRAW,
		},
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.35, 2.5, 2.5),
			offset = CFrame.new(0, 0.78, 0) * CFrame.Angles(0, 0, math.rad(90)),
			color = band,
			material = material,
		},
	}
end

-- ผมดำสั้นยุ่งโผล่ใต้หมวก: ก้อนกลมซ้อนกัน (หัวต้องไม่เหลี่ยม) ปอยหน้าผาก ผมข้าง ผมหลัง
local function hairBall(x: number, y: number, z: number, d: number): Builder.PartSpec
	return {
		attach = "Head",
		shape = "Ball",
		size = Vector3.new(d, d, d),
		offset = CFrame.new(x, y, z),
		color = HAIR,
	}
end

local function hair(): { Builder.PartSpec }
	return {
		hairBall(0, 0.4, 0.2, 1.7),
		hairBall(-0.8, 0.15, 0.1, 1.1),
		hairBall(0.8, 0.15, 0.1, 1.1),
		hairBall(0, 0.1, 0.45, 1.5),
		-- ปอยหน้าผากยุ่ง
		hairBall(-0.55, 0.6, -0.3, 0.65),
		hairBall(-0.1, 0.62, -0.32, 0.7),
		hairBall(0.45, 0.6, -0.3, 0.65),
		-- แผลเป็นใต้ตาซ้าย
		{
			attach = "Head",
			size = Vector3.new(0.4, 0.07, 0.05),
			offset = CFrame.new(-0.45, -0.12, -0.59) * CFrame.Angles(0, 0, math.rad(-8)),
			color = Color3.fromRGB(150, 60, 50),
		},
	}
end

-- เสื้อกั๊กน้ำเงินเปิดอก + กระดุมทอง + กล้ามท้อง + ปลอกแขนดำซ้าย
local function outfit(gold: Color3, goldMaterial: Enum.Material): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		{
			attach = "UpperTorso",
			size = Vector3.new(0.7, 1.45, 0.15),
			offset = CFrame.new(-0.7, 0.05, -0.52),
			color = VEST,
		},
		{
			attach = "UpperTorso",
			size = Vector3.new(0.7, 1.45, 0.15),
			offset = CFrame.new(0.7, 0.05, -0.52),
			color = VEST,
		},
		{ attach = "UpperTorso", size = Vector3.new(2.1, 1.5, 0.15), offset = CFrame.new(0, 0.05, 0.52), color = VEST },
		-- ขอบคอเสื้อ (ปกเอียงเป็นตัววี)
		{
			attach = "UpperTorso",
			size = Vector3.new(0.45, 0.9, 0.17),
			offset = CFrame.new(-0.45, 0.35, -0.53) * CFrame.Angles(0, 0, math.rad(-14)),
			color = VEST,
		},
		{
			attach = "UpperTorso",
			size = Vector3.new(0.45, 0.9, 0.17),
			offset = CFrame.new(0.45, 0.35, -0.53) * CFrame.Angles(0, 0, math.rad(14)),
			color = VEST,
		},
		-- กระดุมทอง 2 เม็ดที่ฝั่งซ้ายของเสื้อ
		{
			attach = "UpperTorso",
			shape = "Ball",
			size = Vector3.new(0.22, 0.22, 0.22),
			offset = CFrame.new(-0.62, 0.0, -0.62),
			color = gold,
			material = goldMaterial,
		},
		{
			attach = "UpperTorso",
			shape = "Ball",
			size = Vector3.new(0.22, 0.22, 0.22),
			offset = CFrame.new(-0.62, -0.45, -0.62),
			color = gold,
			material = goldMaterial,
		},
		-- เส้นกล้ามหน้าอก/ท้อง (เงาผิวเข้ม)
		{
			attach = "UpperTorso",
			size = Vector3.new(0.9, 0.08, 0.06),
			offset = CFrame.new(0, 0.1, -0.52),
			color = SKIN_SHADE,
		},
		{
			attach = "UpperTorso",
			size = Vector3.new(0.08, 0.8, 0.06),
			offset = CFrame.new(0, -0.35, -0.52),
			color = SKIN_SHADE,
		},
		{
			attach = "LowerTorso",
			size = Vector3.new(0.7, 0.08, 0.06),
			offset = CFrame.new(0, 0.1, -0.52),
			color = SKIN_SHADE,
		},
		-- ปลอกแขนดำที่แขนซ้าย 2 เส้น
		{ attach = "LeftUpperArm", size = Vector3.new(1.2, 0.35, 1.2), offset = CFrame.new(0, 0.05, 0), color = BLACK },
		{ attach = "LeftUpperArm", size = Vector3.new(1.2, 0.2, 1.2), offset = CFrame.new(0, -0.38, 0), color = BLACK },
	}
	-- ขอบกางเกงขาสั้นสีขาวฟู + รองเท้าแตะ
	for _, leg in { "LeftUpperLeg", "RightUpperLeg" } do
		table.insert(list, {
			attach = leg,
			size = Vector3.new(1.2, 0.3, 1.2),
			offset = CFrame.new(0, -0.45, 0),
			color = FLUFF,
		})
	end
	for _, foot in { "LeftFoot", "RightFoot" } do
		table.insert(list, {
			attach = foot,
			size = Vector3.new(1.1, 0.14, 1.25),
			offset = CFrame.new(0, -0.3, 0),
			color = SANDAL,
		})
		table.insert(list, {
			attach = foot,
			size = Vector3.new(1.1, 0.1, 0.25),
			offset = CFrame.new(0, 0.0, -0.1),
			color = SANDAL,
		})
	end
	return list
end

local baseParts = hair()
extend(baseParts, strawHat(RED, Enum.Material.SmoothPlastic))
extend(baseParts, outfit(GOLD, Enum.Material.Metal))

local ultParts = hair()
extend(ultParts, strawHat(GLOW, Enum.Material.Neon))
extend(ultParts, outfit(GLOW, Enum.Material.Neon))
-- เส้นเรืองแสงเหมือนขดลวดสปริงตามแขนขา
for _, limb in
	{
		"LeftUpperArm",
		"RightUpperArm",
		"LeftLowerArm",
		"RightLowerArm",
		"LeftUpperLeg",
		"RightUpperLeg",
		"LeftLowerLeg",
		"RightLowerLeg",
	}
do
	for i = 1, 3 do
		table.insert(ultParts, {
			attach = limb,
			size = Vector3.new(1.15, 0.1, 1.15),
			offset = CFrame.new(0, 0.55 - i * 0.28, 0),
			color = GLOW,
			material = Enum.Material.Neon,
			transparency = 0.1,
		})
	end
end
-- ประกายไฟเล็กๆ ที่กำปั้น
for _, hand in { "LeftHand", "RightHand" } do
	table.insert(ultParts, {
		attach = hand,
		size = Vector3.new(0.3, 0.3, 0.3),
		offset = CFrame.new(0, -0.3, 0),
		color = GLOW,
		material = Enum.Material.Neon,
		transparency = 1,
		emitter = { color = GLOW, rate = 15, size = 0.4, lifetime = 0.5, speed = 4 },
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
	UpperTorso = SKIN,
	LowerTorso = SHORTS,
	LeftUpperLeg = SHORTS,
	RightUpperLeg = SHORTS,
	LeftLowerLeg = SKIN,
	RightLowerLeg = SKIN,
	LeftFoot = SKIN,
	RightFoot = SKIN,
}

local looks = {
	base = { colors = bodyColors, parts = baseParts } :: Builder.Look,
	ultimate = { colors = bodyColors, parts = ultParts } :: Builder.Look,
}

return looks
