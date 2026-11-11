--!strict
-- แมพ "หมู่บ้านนินจาในป่า": ลานฝึก 200x200 รั้วไม้ บ้านไม้ 4 หลัง ต้นไม้สูง ลำธารและสะพานฝั่งตะวันออก
-- จุดกึ่งกลางที่ (0, 0, 0) พื้นสูง Y = 0 ทิศเหนือ = -Z

local Kit = require(script.Parent.Parent.ArenaKit)

local SIZE = 200
local WALL_H = 6
local BARRIER_H = 120

local parts: { Kit.PartSpec } = {}
local V = Vector3.new

Kit.block(parts, "Floor", V(0, -2, 0), V(SIZE, 4, SIZE), "Dirt", "Ground")
Kit.block(parts, "OuterGrass", V(0, -2.5, 0), V(SIZE + 160, 4, SIZE + 160), "Grass", "Ground")
Kit.enclosure(parts, SIZE, SIZE, WALL_H, BARRIER_H, "Fence", "FenceCap")

-- ลานฝึกกลางหมู่บ้าน + เสาซ้อม 6 ต้นรอบวง
Kit.cylinder(parts, "TrainingCircle", V(0, 0, 0), 0.4, 50, "Circle", "Ground", { CanCollide = false })
for i = 1, 6 do
	local angle = math.rad(i * 60)
	local pos = V(math.cos(angle) * 14, 0, math.sin(angle) * 14)
	Kit.cylinder(parts, "TrainingPost" .. i, pos, 8, 2.4, "Post", "Training", { Tags = Kit.Cover })
end

-- บ้านไม้ 4 หลัง (ตัวบ้าน + หลังคา)
local houses = { V(-60, 0, -60), V(-60, 0, 60), V(40, 0, -65), V(40, 0, 65) }
for i, p in houses do
	Kit.block(parts, "House" .. i, p + V(0, 6, 0), V(24, 12, 20), "HouseWall", "Houses", { Tags = Kit.Cover })
	Kit.block(parts, "HouseFrame" .. i, p + V(0, 0.5, 0), V(25, 1, 21), "HouseFrame", "Houses")
	Kit.block(parts, "HouseRoof" .. i, p + V(0, 13.5, 0), V(28, 3, 24), "Roof", "Houses")
end

-- ต้นไม้สูง (ลำต้น + พุ่มใบ)
local trees = {
	V(-25, 0, -85),
	V(25, 0, -85),
	V(-25, 0, 85),
	V(25, 0, 85),
	V(-86, 0, -35),
	V(-86, 0, 35),
	V(86, 0, -35),
	V(86, 0, 35),
}
for i, p in trees do
	Kit.cylinder(parts, "Trunk" .. i, p, 18, 3, "Trunk", "Trees", { Tags = Kit.Cover })
	Kit.block(parts, "Leaves" .. i, p + V(0, 21, 0), V(14, 8, 14), "Leaves", "Trees", { Yaw = i * 20 })
end

-- กำแพงหินเตี้ยกำบัง 4 จุด
local lowWalls = { V(-20, 0, -35), V(20, 0, -35), V(-20, 0, 35), V(20, 0, 35) }
for i, p in lowWalls do
	Kit.block(parts, "LowWall" .. i, p + V(0, 2, 0), V(12, 4, 2.5), "Stone", "Cover", { Tags = Kit.Cover })
end

-- ลำธารฝั่งตะวันออก + สะพานไม้
Kit.block(parts, "Stream", V(68, 0.1, 0), V(16, 0.2, SIZE - 8), "Water", "Ground", { CanCollide = false })
Kit.block(parts, "Bridge", V(68, 0.3, 0), V(24, 0.6, 10), "Bridge", "Ground")
Kit.block(parts, "BridgeRailN", V(68, 2, -4.5), V(24, 2, 1), "HouseFrame", "Ground")
Kit.block(parts, "BridgeRailS", V(68, 2, 4.5), V(24, 2, 1), "HouseFrame", "Ground")

return {
	Parts = parts,
	Spawns = Kit.edgeSpawns(SIZE, SIZE, 14, 0.5),
	Bounds = Kit.bounds(SIZE, SIZE, WALL_H, BARRIER_H),
}
