--!strict
-- แมพ "หุบเขาหินแตก": ลาน 200x200 หน้าผาสูง กลางลานมีแท่นหิน เสาหินสูง และซุ้มโค้ง
-- จุดกึ่งกลางที่ (0, 0, 0) พื้นสูง Y = 0 ทิศเหนือ = -Z

local Kit = require(script.Parent.Parent.ArenaKit)

local SIZE = 200
local WALL_H = 40
local BARRIER_H = 120

local parts: { Kit.PartSpec } = {}
local V = Vector3.new

Kit.block(parts, "Floor", V(0, -2, 0), V(SIZE, 4, SIZE), "Sand", "Ground")
Kit.block(parts, "OuterSand", V(0, -2.5, 0), V(SIZE + 160, 4, SIZE + 160), "OuterSand", "Ground")
Kit.enclosure(parts, SIZE, SIZE, WALL_H, BARRIER_H, "Cliff", "CliffCap")

-- แท่นหินกลางลาน (สูง 6) มีทางลาด 4 ทิศ
Kit.cylinder(parts, "Mesa", V(0, 0, 0), 6, 40, "Mesa", "Centerpiece")
local dirs = { N = V(0, 0, -1), S = V(0, 0, 1), E = V(1, 0, 0), W = V(-1, 0, 0) }
for name, dir in dirs do
	Kit.ramp(parts, "MesaRamp" .. name, dir * 27 + V(0, 3, 0), 14, 6, 16, -dir, "Mesa", "Centerpiece")
end

-- เสาหินสูง 6 ต้น (ที่กำบัง/ที่ยืนหลบ)
local spires = {
	{ x = -55, z = -50, h = 30, d = 10 },
	{ x = 55, z = -50, h = 22, d = 8 },
	{ x = -55, z = 50, h = 22, d = 8 },
	{ x = 55, z = 50, h = 30, d = 10 },
	{ x = -72, z = 0, h = 16, d = 8 },
	{ x = 72, z = 0, h = 16, d = 8 },
}
for i, s in spires do
	Kit.cylinder(parts, "Spire" .. i, V(s.x, 0, s.z), s.h, s.d, "Rock", "Spires", { Tags = Kit.Cover })
	Kit.cylinder(parts, "SpireBase" .. i, V(s.x, 0, s.z), 3, s.d + 4, "RockDark", "Spires", { Tags = Kit.Cover })
end

-- ซุ้มโค้งหิน 2 ที่ ทิศเหนือและใต้ (ขาสองข้าง + คานด้านบน)
for _, z in { -70, 70 } do
	local tag = if z < 0 then "N" else "S"
	Kit.block(parts, "ArchLegW" .. tag, V(-14, 9, z), V(8, 18, 8), "Rock", "Arches", { Tags = Kit.Cover })
	Kit.block(parts, "ArchLegE" .. tag, V(14, 9, z), V(8, 18, 8), "Rock", "Arches", { Tags = Kit.Cover })
	Kit.block(parts, "ArchTop" .. tag, V(0, 21, z), V(36, 6, 10), "RockDark", "Arches")
end

-- ก้อนหินกำบัง 4 จุด
local boulders = { V(-40, 0, -25), V(40, 0, -25), V(-40, 0, 25), V(40, 0, 25) }
for i, p in boulders do
	Kit.block(parts, "Boulder" .. i, p + V(0, 3, 0), V(9, 6, 7), "Rock", "Cover", { Yaw = i * 35, Tags = Kit.Cover })
	Kit.block(parts, "BoulderTop" .. i, p + V(3, 7, 1), V(5, 3, 5), "RockDark", "Cover", { Yaw = i * 60 })
end

return {
	Parts = parts,
	Spawns = Kit.edgeSpawns(SIZE, SIZE, 12, 0.5),
	Bounds = Kit.bounds(SIZE, SIZE, WALL_H, BARRIER_H),
}
