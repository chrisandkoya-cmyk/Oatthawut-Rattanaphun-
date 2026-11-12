--!strict
-- หน้าตาแบรม: ผมยุ่งสีส้มอิฐ แว่นกันลมคาดหน้าผาก เสื้อฮู้ดตัดแขนสีม่วงแถบเหลืองมัสตาร์ด
-- กางเกงคาร์โก้เขียวขี้ม้า รองเท้าผ้าใบขาว พลาสเตอร์ที่คาง (ดูเอกสารออกแบบตัวละคร)
-- ร่างอันติ: เส้นเรืองแสงส้มทองเหมือนขดลวดสปริงตามแขนขา แว่นเลื่อนลงมาที่ตา
-- ฮู้ดสีดำแถบส้ม ประกายไฟเล็กๆ ขนาด/ตำแหน่งเป็นค่าประมาณ ปรับได้ที่ไฟล์นี้ไฟล์เดียว

local Builder = require(script.Parent.Builder)

local SKIN = Color3.fromRGB(201, 142, 98)
local ORANGE_HAIR = Color3.fromRGB(217, 98, 43)
local PURPLE = Color3.fromRGB(91, 63, 168)
local MUSTARD = Color3.fromRGB(232, 176, 48)
local OLIVE = Color3.fromRGB(94, 107, 58)
local SNEAKER = Color3.fromRGB(240, 240, 240)
local LENS = Color3.fromRGB(127, 211, 240)
local BLACK = Color3.fromRGB(24, 24, 26)
local GLOW = Color3.fromRGB(255, 154, 46)

local function spikes(): { Builder.PartSpec }
	-- ผมยุ่ง: ก้อนผมหลายชิ้นเอียงต่างกัน
	local list: { Builder.PartSpec } = {
		{ attach = "Head", size = Vector3.new(2.1, 0.5, 1.2), offset = CFrame.new(0, 0.55, 0.02), color = ORANGE_HAIR },
		{
			attach = "Head",
			size = Vector3.new(0.7, 0.7, 0.7),
			offset = CFrame.new(-0.6, 0.95, 0.1) * CFrame.Angles(0, 0, math.rad(20)),
			color = ORANGE_HAIR,
		},
		{
			attach = "Head",
			size = Vector3.new(0.7, 0.8, 0.7),
			offset = CFrame.new(0.2, 1.0, -0.1) * CFrame.Angles(0, 0, math.rad(-12)),
			color = ORANGE_HAIR,
		},
		{
			attach = "Head",
			size = Vector3.new(0.6, 0.7, 0.6),
			offset = CFrame.new(0.75, 0.9, 0.2) * CFrame.Angles(0, 0, math.rad(-28)),
			color = ORANGE_HAIR,
		},
		{ attach = "Head", size = Vector3.new(2.0, 0.9, 0.3), offset = CFrame.new(0, 0.2, 0.55), color = ORANGE_HAIR },
	}
	return list
end

-- แว่นกันลม: กรอบเหลือง + เลนส์ฟ้า ยกไว้บนหน้าผาก (ร่างปกติ) หรือเลื่อนลงที่ตา (ร่างอันติ)
local function goggles(y: number, frame: Color3): { Builder.PartSpec }
	return {
		{ attach = "Head", size = Vector3.new(2.15, 0.3, 1.15), offset = CFrame.new(0, y, 0), color = frame },
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.12, 0.6, 0.6),
			offset = CFrame.new(-0.5, y, -0.58) * CFrame.Angles(0, math.rad(90), 0),
			color = LENS,
			material = Enum.Material.Neon,
			transparency = 0.2,
		},
		{
			attach = "Head",
			shape = "Cylinder",
			size = Vector3.new(0.12, 0.6, 0.6),
			offset = CFrame.new(0.5, y, -0.58) * CFrame.Angles(0, math.rad(90), 0),
			color = LENS,
			material = Enum.Material.Neon,
			transparency = 0.2,
		},
	}
end

local function extend(into: { Builder.PartSpec }, from: { Builder.PartSpec })
	for _, spec in from do
		table.insert(into, spec)
	end
end

local function hoodie(main: Color3, stripe: Color3): { Builder.PartSpec }
	return {
		{ attach = "UpperTorso", size = Vector3.new(2.1, 1.35, 1.1), offset = CFrame.new(0, 0.1, 0), color = main },
		{
			attach = "UpperTorso",
			size = Vector3.new(2.15, 0.22, 1.15),
			offset = CFrame.new(0, -0.35, 0),
			color = stripe,
		},
		-- ฮู้ดพับอยู่ด้านหลังคอ
		{ attach = "UpperTorso", size = Vector3.new(1.4, 0.5, 0.5), offset = CFrame.new(0, 0.85, 0.55), color = main },
	}
end

-- รายละเอียดเพิ่ม: ข้อมือผ้าพัน เข็มขัด ขอบรองเท้า สายแว่น ให้ตัวดูมีชั้นเชิงขึ้น
local function details(accent: Color3, belt: Color3): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		{ attach = "LowerTorso", size = Vector3.new(2.1, 0.3, 1.1), offset = CFrame.new(0, 0.2, 0), color = belt },
		{
			attach = "LowerTorso",
			size = Vector3.new(0.5, 0.35, 0.15),
			offset = CFrame.new(0, 0.2, -0.55),
			color = accent,
			material = Enum.Material.Metal,
		},
		-- สายแว่นรอบหัว
		{ attach = "Head", size = Vector3.new(2.15, 0.14, 1.2), offset = CFrame.new(0, 0.1, 0.02), color = BLACK },
	}
	for _, hand in { "LeftHand", "RightHand" } do
		table.insert(
			list,
			{ attach = hand, size = Vector3.new(1.15, 0.45, 1.15), offset = CFrame.new(0, 0.2, 0), color = accent }
		)
	end
	for _, foot in { "LeftFoot", "RightFoot" } do
		table.insert(
			list,
			{ attach = foot, size = Vector3.new(1.1, 0.2, 1.2), offset = CFrame.new(0, 0.05, 0), color = accent }
		)
	end
	for _, leg in { "LeftLowerLeg", "RightLowerLeg" } do
		table.insert(
			list,
			{ attach = leg, size = Vector3.new(1.1, 0.25, 1.1), offset = CFrame.new(0, -0.35, 0), color = accent }
		)
	end
	return list
end

local baseParts = spikes()
extend(baseParts, details(MUSTARD, Color3.fromRGB(70, 50, 30)))
extend(baseParts, goggles(0.35, MUSTARD))
extend(baseParts, hoodie(PURPLE, MUSTARD))
-- พลาสเตอร์ที่คาง
table.insert(baseParts, {
	attach = "Head",
	size = Vector3.new(0.4, 0.2, 0.1),
	offset = CFrame.new(0.2, -0.4, -0.55),
	color = Color3.fromRGB(242, 236, 224),
})

local ultParts = spikes()
extend(ultParts, details(GLOW, BLACK))
extend(ultParts, goggles(0.0, GLOW))
extend(ultParts, hoodie(BLACK, GLOW))
table.insert(ultParts, {
	attach = "Head",
	size = Vector3.new(0.4, 0.2, 0.1),
	offset = CFrame.new(0.2, -0.4, -0.55),
	color = Color3.fromRGB(242, 236, 224),
})
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
	LowerTorso = OLIVE,
	LeftUpperLeg = OLIVE,
	RightUpperLeg = OLIVE,
	LeftLowerLeg = OLIVE,
	RightLowerLeg = OLIVE,
	LeftFoot = SNEAKER,
	RightFoot = SNEAKER,
}

-- โมเดลฟรีจาก Creator Store: "Luffy's Straw Hat (includes hair)" โดย MonkeyWizard_OOA (13178556114)
-- เอาเฉพาะ mesh ผม + หมวกฟาง ไม่ใช้สคริปต์ของเขา (ตรวจแล้วไม่มีสคริปต์) ก่อนปล่อยสาธารณะต้องเปลี่ยนหน้าตา
local LUFFY_SKIN = Color3.fromRGB(226, 160, 120)
local GEAR2_SKIN = Color3.fromRGB(240, 110, 100)
local HAIR_BLACK = Color3.fromRGB(20, 20, 20)
local VEST_RED = Color3.fromRGB(190, 30, 36)
local SHORTS_BLUE = Color3.fromRGB(40, 70, 150)
local STEAM = Color3.fromRGB(255, 255, 255)

local function luffyHead(): { Builder.PartSpec }
	return {
		{
			attach = "Head",
			meshId = "rbxassetid://943796917",
			size = Vector3.new(1.743, 1.486, 1.531),
			offset = CFrame.new(0, 0.2, 0),
			color = HAIR_BLACK,
		},
		{
			attach = "Head",
			meshId = "rbxassetid://5063791566",
			textureId = "rbxassetid://5063791598",
			size = Vector3.new(2.592, 1.415, 2.476),
			offset = CFrame.new(0, 0.46, 0.016) * CFrame.Angles(0, math.pi, 0),
			color = Color3.fromRGB(255, 255, 255),
		},
	}
end

local function luffyBody(skin: Color3): { Builder.PartSpec }
	return {
		{ attach = "UpperTorso", size = Vector3.new(2.1, 1.35, 1.1), offset = CFrame.new(0, 0.1, 0), color = VEST_RED },
		{ attach = "UpperTorso", size = Vector3.new(0.8, 1.4, 1.12), offset = CFrame.new(0, 0.1, 0), color = skin },
		{
			attach = "LowerTorso",
			size = Vector3.new(2.1, 0.5, 1.1),
			offset = CFrame.new(0, 0.1, 0),
			color = Color3.fromRGB(236, 216, 120),
		},
	}
end

local function bodyOf(skin: Color3): { [string]: Color3 }
	local colors: { [string]: Color3 } = {}
	for name in bodyColors do
		colors[name] = skin
	end
	for _, name in { "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg" } do
		colors[name] = SHORTS_BLUE
	end
	for _, name in { "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot" } do
		colors[name] = skin
	end
	return colors
end

local luffyBase: { Builder.PartSpec } = luffyHead()
extend(luffyBase, luffyBody(LUFFY_SKIN))

-- ร่างอันติ = Gear 2: ผิวแดงอมชมพู ไอน้ำขาวจากตัว
local luffyGear2: { Builder.PartSpec } = luffyHead()
extend(luffyGear2, luffyBody(GEAR2_SKIN))
for _, limb in { "LeftLowerArm", "RightLowerArm", "LeftLowerLeg", "RightLowerLeg", "UpperTorso" } do
	table.insert(luffyGear2, {
		attach = limb,
		size = Vector3.new(0.3, 0.3, 0.3),
		offset = CFrame.new(0, 0, 0),
		color = STEAM,
		transparency = 1,
		emitter = { color = STEAM, rate = 18, size = 1.2, lifetime = 0.9, speed = 3 },
	})
end

local looks = {
	base = { colors = bodyOf(LUFFY_SKIN), parts = luffyBase } :: Builder.Look,
	ultimate = { colors = bodyOf(GEAR2_SKIN), parts = luffyGear2 } :: Builder.Look,
}

return looks
