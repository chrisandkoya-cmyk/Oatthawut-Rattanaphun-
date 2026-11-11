--!strict
-- ตำแหน่งและขนาดชิ้นส่วนของแมพ "ลานวัดร้าง" (ข้อมูลล้วน ไม่มีโค้ดสร้างของ)
-- หน่วยเป็น stud, จุดกึ่งกลางลานอยู่ที่ (0, 0, 0) และพื้นลานสูง Y = 0
--
-- ผังจากด้านบน (ทิศเหนือ = -Z)
--   +---------------- กำแพง ----------------+
--   |  S         [ แท่นสูงทิศเหนือ ]       S  |
--   |      o            o            o        |
--   |   ##                              ##    |
--   |  S      o    ( แท่นกลาง+รูปปั้น )  o   S |
--   |   ##                              ##    |
--   |      o            o            o        |
--   |  S         [ แท่นสูงทิศใต้ ]        S  |
--   +-----------------------------------------+
--   S = จุดเกิด  o = เสา  ## = กองหินกำบัง

export type Shape = "Block" | "Cylinder" | "Wedge"

export type PartSpec = {
	Name: string,
	Shape: Shape,
	Size: Vector3,
	CFrame: CFrame,
	Look: string, -- คีย์ใน Theme.Looks
	Group: string, -- โฟลเดอร์ปลายทางในโมเดลแมพ
	CanCollide: boolean?,
	Tags: { string }?,
}

local Layout = {}

Layout.ArenaSize = 200 -- ความกว้างลาน (สี่เหลี่ยมจัตุรัส)
Layout.WallHeight = 26
Layout.BarrierHeight = 120 -- กำแพงล่องหนกันกระโดด/โดนกระเด็นออกนอกแมพ
Layout.SpawnCount = 8 -- รองรับผู้เล่นพร้อมกันได้ถึง 8 คน

local HALF = Layout.ArenaSize / 2
local WALL_T = 4

local parts: { PartSpec } = {}

local function add(spec: PartSpec)
	table.insert(parts, spec)
end

-- พื้น ---------------------------------------------------------------
add({
	Name = "Floor",
	Shape = "Block",
	Size = Vector3.new(Layout.ArenaSize, 4, Layout.ArenaSize),
	CFrame = CFrame.new(0, -2, 0),
	Look = "Floor",
	Group = "Ground",
})
add({
	Name = "OuterGrass",
	Shape = "Block",
	Size = Vector3.new(Layout.ArenaSize + 160, 4, Layout.ArenaSize + 160),
	CFrame = CFrame.new(0, -2.5, 0),
	Look = "Grass",
	Group = "Ground",
})
-- ทางเดินหินไขว้กลางลาน (แต่งพื้นให้ไม่โล่ง)
add({
	Name = "PathNS",
	Shape = "Block",
	Size = Vector3.new(16, 0.2, Layout.ArenaSize - 8),
	CFrame = CFrame.new(0, 0.1, 0),
	Look = "FloorTrim",
	Group = "Ground",
	CanCollide = false, -- ลายพื้นเฉยๆ ไม่ให้เป็นขอบนูนสะดุด
})
add({
	Name = "PathEW",
	Shape = "Block",
	Size = Vector3.new(Layout.ArenaSize - 8, 0.2, 16),
	CFrame = CFrame.new(0, 0.1, 0),
	Look = "FloorTrim",
	Group = "Ground",
	CanCollide = false, -- ลายพื้นเฉยๆ ไม่ให้เป็นขอบนูนสะดุด
})

-- กำแพงรอบลาน + กำแพงล่องหน ----------------------------------------
local sides = {
	{
		name = "North",
		cf = CFrame.new(0, 0, -HALF - WALL_T / 2),
		size = Vector3.new(Layout.ArenaSize + WALL_T * 2, 0, WALL_T),
	},
	{
		name = "South",
		cf = CFrame.new(0, 0, HALF + WALL_T / 2),
		size = Vector3.new(Layout.ArenaSize + WALL_T * 2, 0, WALL_T),
	},
	{ name = "East", cf = CFrame.new(HALF + WALL_T / 2, 0, 0), size = Vector3.new(WALL_T, 0, Layout.ArenaSize) },
	{ name = "West", cf = CFrame.new(-HALF - WALL_T / 2, 0, 0), size = Vector3.new(WALL_T, 0, Layout.ArenaSize) },
}
for _, side in sides do
	add({
		Name = "Wall" .. side.name,
		Shape = "Block",
		Size = Vector3.new(side.size.X, Layout.WallHeight, side.size.Z),
		CFrame = side.cf * CFrame.new(0, Layout.WallHeight / 2, 0),
		Look = "Wall",
		Group = "Walls",
	})
	add({
		Name = "WallCap" .. side.name,
		Shape = "Block",
		Size = Vector3.new(side.size.X + 2, 2, side.size.Z + 2),
		CFrame = side.cf * CFrame.new(0, Layout.WallHeight + 1, 0),
		Look = "WallCap",
		Group = "Walls",
	})
	add({
		Name = "Barrier" .. side.name,
		Shape = "Block",
		Size = Vector3.new(side.size.X, Layout.BarrierHeight, side.size.Z),
		CFrame = side.cf * CFrame.new(0, Layout.WallHeight + 2 + Layout.BarrierHeight / 2, 0),
		Look = "Barrier",
		Group = "Barriers",
	})
end
-- เพดานล่องหน กันลอยออกจากด้านบน
add({
	Name = "BarrierCeiling",
	Shape = "Block",
	Size = Vector3.new(Layout.ArenaSize + WALL_T * 2, 4, Layout.ArenaSize + WALL_T * 2),
	CFrame = CFrame.new(0, Layout.WallHeight + 2 + Layout.BarrierHeight + 2, 0),
	Look = "Barrier",
	Group = "Barriers",
})

-- แท่นกลาง + รูปปั้นหักพัง (รูปทรงนามธรรม ไม่อิงตัวละครใด) -------------
add({
	Name = "DaisLower",
	Shape = "Cylinder",
	Size = Vector3.new(2, 44, 44), -- Cylinder ของ Roblox ยาวตามแกน X
	CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, math.rad(90)),
	Look = "Dais",
	Group = "Centerpiece",
})
add({
	Name = "DaisUpper",
	Shape = "Cylinder",
	Size = Vector3.new(2, 28, 28),
	CFrame = CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, math.rad(90)),
	Look = "Dais",
	Group = "Centerpiece",
})
add({
	Name = "StatueBase",
	Shape = "Block",
	Size = Vector3.new(10, 6, 10),
	CFrame = CFrame.new(0, 7, 0),
	Look = "Statue",
	Group = "Centerpiece",
	Tags = { "ArenaCover" },
})
add({
	Name = "StatueBody",
	Shape = "Block",
	Size = Vector3.new(6, 14, 5),
	CFrame = CFrame.new(0, 17, 0) * CFrame.Angles(0, math.rad(20), math.rad(6)),
	Look = "Statue",
	Group = "Centerpiece",
	Tags = { "ArenaCover" },
})
add({
	Name = "StatueFallenPiece",
	Shape = "Block",
	Size = Vector3.new(5, 4, 9),
	CFrame = CFrame.new(9, 6, 7) * CFrame.Angles(math.rad(15), math.rad(35), math.rad(-10)),
	Look = "Statue",
	Group = "Centerpiece",
	Tags = { "ArenaCover" },
})

-- เสา 8 ต้น (บางต้นหัก ให้ความสูงต่างกัน) ------------------------------
local pillarSpots = {
	{ x = -55, z = -40, h = 24 },
	{ x = 0, z = -48, h = 14 },
	{ x = 55, z = -40, h = 24 },
	{ x = -48, z = 0, h = 10 },
	{ x = 48, z = 0, h = 10 },
	{ x = -55, z = 40, h = 24 },
	{ x = 0, z = 48, h = 14 },
	{ x = 55, z = 40, h = 24 },
}
for i, spot in pillarSpots do
	add({
		Name = "PillarBase" .. i,
		Shape = "Block",
		Size = Vector3.new(9, 2, 9),
		CFrame = CFrame.new(spot.x, 1, spot.z),
		Look = "FloorTrim",
		Group = "Pillars",
	})
	add({
		Name = "Pillar" .. i,
		Shape = "Cylinder",
		Size = Vector3.new(spot.h, 6, 6),
		CFrame = CFrame.new(spot.x, 2 + spot.h / 2, spot.z) * CFrame.Angles(0, 0, math.rad(90)),
		Look = "Pillar",
		Group = "Pillars",
		Tags = { "ArenaCover" },
	})
end

-- แท่นสูงทิศเหนือ/ใต้ พร้อมทางลาดขึ้น 2 ข้าง ---------------------------
local PLATFORM_H = 8
for _, dir in { { name = "North", z = -78 }, { name = "South", z = 78 } } do
	local facing = if dir.z < 0 then 1 else -1 -- ด้านที่หันเข้ากลางลาน
	add({
		Name = "Platform" .. dir.name,
		Shape = "Block",
		Size = Vector3.new(44, PLATFORM_H, 18),
		CFrame = CFrame.new(0, PLATFORM_H / 2, dir.z),
		Look = "Platform",
		Group = "Platforms",
	})
	-- ทางลาดซ้าย/ขวา (Wedge ลาดขึ้นไปทางแท่น)
	for _, sx in { -1, 1 } do
		add({
			Name = "Ramp" .. dir.name .. (if sx < 0 then "W" else "E"),
			Shape = "Wedge",
			Size = Vector3.new(18, PLATFORM_H, 20),
			CFrame = CFrame.new(sx * 32, PLATFORM_H / 2, dir.z) * CFrame.Angles(0, math.rad(sx * -90), 0),
			Look = "Platform",
			Group = "Platforms",
		})
	end
	-- ซุ้มไม้เล็กบนแท่น (ตกแต่ง + ที่หลบ)
	for _, px in { -18, 18 } do
		add({
			Name = "ShrinePost" .. dir.name .. px,
			Shape = "Block",
			Size = Vector3.new(2, 12, 2),
			CFrame = CFrame.new(px, PLATFORM_H + 6, dir.z - facing * 6),
			Look = "Wood",
			Group = "Platforms",
		})
	end
	add({
		Name = "ShrineRoof" .. dir.name,
		Shape = "Block",
		Size = Vector3.new(42, 2, 8),
		CFrame = CFrame.new(0, PLATFORM_H + 13, dir.z - facing * 6),
		Look = "Roof",
		Group = "Platforms",
	})
end

-- กองหินกำบังเตี้ย 4 จุด (ซ่อนตัว/ยืนหลบสกิล) ------------------------
for i, spot in { { x = -72, z = -20 }, { x = 72, z = -20 }, { x = -72, z = 20 }, { x = 72, z = 20 } } do
	add({
		Name = "Rubble" .. i .. "A",
		Shape = "Block",
		Size = Vector3.new(10, 5, 6),
		CFrame = CFrame.new(spot.x, 2.5, spot.z) * CFrame.Angles(0, math.rad(i * 25), 0),
		Look = "Rubble",
		Group = "Cover",
		Tags = { "ArenaCover" },
	})
	add({
		Name = "Rubble" .. i .. "B",
		Shape = "Block",
		Size = Vector3.new(5, 4, 5),
		CFrame = CFrame.new(spot.x + 4, 7, spot.z + 1) * CFrame.Angles(math.rad(10), math.rad(i * 40), math.rad(8)),
		Look = "Rubble",
		Group = "Cover",
		Tags = { "ArenaCover" },
	})
end

Layout.Parts = parts

-- จุดเกิด 8 จุด หันหน้าเข้ากลางลาน ----------------------------------------
-- มุมลาน 4 จุด + กลางกำแพงตะวันออก/ตะวันตก 2 จุด + บนแท่นสูงเหนือ/ใต้ 2 จุด
local spawnSpots = {
	Vector3.new(-84, 0.5, -84),
	Vector3.new(84, 0.5, -84),
	Vector3.new(-84, 0.5, 84),
	Vector3.new(84, 0.5, 84),
	Vector3.new(-88, 0.5, 0),
	Vector3.new(88, 0.5, 0),
	Vector3.new(0, PLATFORM_H + 0.5, -76),
	Vector3.new(0, PLATFORM_H + 0.5, 76),
}
local spawns: { CFrame } = {}
for _, pos in spawnSpots do
	table.insert(spawns, CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0)))
end
Layout.Spawns = spawns

-- ขอบเขตลาน ให้ระบบต่อสู้ใช้ตรวจว่าตำแหน่งอยู่ในแมพไหม
Layout.Bounds = {
	Min = Vector3.new(-HALF, -10, -HALF),
	Max = Vector3.new(HALF, Layout.WallHeight + Layout.BarrierHeight, HALF),
}

return Layout
