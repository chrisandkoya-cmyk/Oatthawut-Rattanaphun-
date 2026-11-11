--!strict
-- หน้าตาโซลวาน: ผมสั้นตัดข้างสีเทาขี้เถ้า ผ้าคาดหน้าผากฟ้าอมเขียว เสื้อกั๊กเทาเข้มทับเสื้อยืดดำ
-- ผ้าพันมือเทอร์ควอยซ์ กางเกงเทา บูทสั้นดำ (ดูเอกสารออกแบบตัวละคร)
-- ร่างอันติ: ผมขาวปลายฟ้า เส้นแสงตามแขนเหมือนรอยร้าว วงแหวนแสงบางๆ ลอยหลังศีรษะ
-- ขนาด/ตำแหน่งเป็นค่าประมาณ ปรับที่ offset/size ได้ที่ไฟล์นี้ไฟล์เดียว

local Builder = require(script.Parent.Builder)

local SKIN = Color3.fromRGB(232, 185, 143)
local ASH = Color3.fromRGB(138, 143, 152)
local VEST = Color3.fromRGB(43, 47, 54)
local TEE = Color3.fromRGB(26, 26, 30)
local CYAN = Color3.fromRGB(63, 200, 224)
local TURQUOISE = Color3.fromRGB(31, 165, 154)
local PANTS = Color3.fromRGB(107, 112, 120)
local BOOT = Color3.fromRGB(20, 20, 22)
local WHITE = Color3.fromRGB(242, 244, 247)

local function hair(color: Color3, tip: Color3?): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		{ attach = "Head", size = Vector3.new(2.1, 0.5, 1.2), offset = CFrame.new(0, 0.55, 0.02), color = color },
		{ attach = "Head", size = Vector3.new(0.25, 0.7, 1.1), offset = CFrame.new(-1.0, 0.2, 0.05), color = color },
		{ attach = "Head", size = Vector3.new(0.25, 0.7, 1.1), offset = CFrame.new(1.0, 0.2, 0.05), color = color },
		{ attach = "Head", size = Vector3.new(2.0, 0.8, 0.3), offset = CFrame.new(0, 0.25, 0.55), color = color },
	}
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

-- ชิ้นส่วนที่ทั้งสองร่างใช้ร่วมกัน (เสื้อกั๊ก ผ้าพันมือ ผ้าคาดหัว)
local function outfit(bandColor: Color3, bandMaterial: Enum.Material): { Builder.PartSpec }
	return {
		{ attach = "UpperTorso", size = Vector3.new(2.1, 1.35, 1.1), offset = CFrame.new(0, 0.1, 0), color = VEST },
		{
			attach = "LeftHand",
			size = Vector3.new(1.15, 0.55, 1.15),
			offset = CFrame.new(0, 0.1, 0),
			color = TURQUOISE,
		},
		{
			attach = "RightHand",
			size = Vector3.new(1.15, 0.55, 1.15),
			offset = CFrame.new(0, 0.1, 0),
			color = TURQUOISE,
		},
		{
			attach = "Head",
			size = Vector3.new(2.15, 0.22, 1.15),
			offset = CFrame.new(0, 0.3, 0),
			color = bandColor,
			material = bandMaterial,
		},
	}
end

-- รายละเอียดเพิ่ม: สายคาดเอว ขอบบูท ชายผ้าคาดหัวห้อยหลัง
local function trim(accent: Color3, material: Enum.Material): { Builder.PartSpec }
	local list: { Builder.PartSpec } = {
		{
			attach = "LowerTorso",
			size = Vector3.new(2.1, 0.3, 1.1),
			offset = CFrame.new(0, 0.2, 0),
			color = accent,
			material = material,
		},
		{
			attach = "Head",
			size = Vector3.new(0.35, 1.1, 0.12),
			offset = CFrame.new(-0.4, -0.1, 0.65) * CFrame.Angles(0, 0, math.rad(8)),
			color = accent,
			material = material,
		},
		{
			attach = "Head",
			size = Vector3.new(0.35, 0.9, 0.12),
			offset = CFrame.new(0.1, -0.05, 0.66) * CFrame.Angles(0, 0, math.rad(-10)),
			color = accent,
			material = material,
		},
	}
	for _, foot in { "LeftFoot", "RightFoot" } do
		table.insert(list, {
			attach = foot,
			size = Vector3.new(1.1, 0.2, 1.2),
			offset = CFrame.new(0, 0.3, 0),
			color = accent,
			material = material,
		})
	end
	return list
end

local baseParts = hair(ASH, nil)
extend(baseParts, trim(TURQUOISE, Enum.Material.SmoothPlastic))
extend(baseParts, outfit(CYAN, Enum.Material.SmoothPlastic))

local ultParts = hair(WHITE, CYAN)
extend(ultParts, trim(CYAN, Enum.Material.Neon))
extend(ultParts, outfit(CYAN, Enum.Material.Neon))
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
	LeftLowerArm = SKIN,
	RightLowerArm = SKIN,
	LeftHand = SKIN,
	RightHand = SKIN,
	LeftUpperArm = TEE,
	RightUpperArm = TEE,
	UpperTorso = TEE,
	LowerTorso = TEE,
	LeftUpperLeg = PANTS,
	RightUpperLeg = PANTS,
	LeftLowerLeg = PANTS,
	RightLowerLeg = PANTS,
	LeftFoot = BOOT,
	RightFoot = BOOT,
}

local looks = {
	base = { colors = bodyColors, parts = baseParts } :: Builder.Look,
	ultimate = { colors = bodyColors, parts = ultParts } :: Builder.Look,
}

return looks
