--!strict
-- แมพ "โคลอสเซียมเกาะเขตร้อน": สนามกลาดิเอเตอร์วงกลมรัศมี 80 ล้อมด้วยอัฒจันทร์ 3 ชั้น บนเกาะทรายกลางทะเล
-- จุดกึ่งกลางที่ (0, 0, 0) พื้นสูง Y = 0 ประตูอยู่ทิศตะวันออก/ตะวันตก ระเบียงอยู่ทิศเหนือ/ใต้

local Kit = require(script.Parent.Parent.ArenaKit)

local R = 80 -- รัศมีลานต่อสู้
local SEGMENTS = 24
local BARRIER_H = 120
local TOP_H = 20 -- ความสูงกำแพงบนสุดของอัฒจันทร์

local parts: { Kit.PartSpec } = {}
local V = Vector3.new

-- วงแหวนของบล็อกที่หันหน้าเข้ากลาง: centerR = รัศมีกึ่งกลาง, thick = ความหนา
local function ring(name: string, centerR: number, thick: number, height: number, look: string, group: string)
	local len = 2 * centerR * math.sin(math.pi / SEGMENTS) * 1.06
	for i = 1, SEGMENTS do
		local deg = (i - 1) * 360 / SEGMENTS
		local rad = math.rad(deg)
		local pos = V(math.cos(rad) * centerR, height / 2, math.sin(rad) * centerR)
		Kit.block(parts, name .. i, pos, V(len, height, thick), look, group, { Yaw = 90 - deg })
	end
end

-- พื้น ----------------------------------------------------------------
Kit.cylinder(parts, "Floor", V(0, -4, 0), 4, R * 2, "Sand", "Ground")
Kit.cylinder(parts, "FloorRing", V(0, 0, 0), 0.2, 120, "Ring", "Ground", { CanCollide = false })

-- อัฒจันทร์ 3 ชั้น (ขั้นบันไดสูงขึ้นไปทางนอก) + กำแพงบนสุด ---------------
ring("Tier1_", 83, 6, 5, "Stone", "Stands")
ring("Tier2_", 89, 6, 10, "Marble", "Stands")
ring("Tier3_", 95, 6, 15, "Stone", "Stands")
ring("TopWall", 100, 4, TOP_H, "TopWall", "Stands")

-- กำแพงล่องหนกันกระโดดขึ้นอัฒจันทร์ + เพดานล่องหน
ring("Barrier", 81, 2, TOP_H + BARRIER_H, "Barrier", "Barriers")
Kit.cylinder(parts, "BarrierCeiling", V(0, TOP_H + BARRIER_H, 0), 4, R * 2 + 24, "Barrier", "Barriers")

-- เสาหินอ่อนบนกำแพงสุด 12 ต้น
for i = 1, 12 do
	local rad = math.rad(i * 30 + 15)
	local pos = V(math.cos(rad) * 100, TOP_H, math.sin(rad) * 100)
	Kit.cylinder(parts, "TopColumn" .. i, pos, 10, 3, "Column", "Stands")
end

-- ประตูไม้ ตะวันออก/ตะวันตก (ติดอัฒจันทร์ชั้นล่าง)
for _, sx in { -1, 1 } do
	local tag = if sx < 0 then "W" else "E"
	Kit.block(parts, "Gate" .. tag, V(sx * 78, 5, 0), V(3, 10, 12), "Gate", "Stands")
	Kit.block(parts, "GateFrame" .. tag, V(sx * 78, 11, 0), V(4, 2, 16), "StoneDark", "Stands")
end

-- แท่นกลางลาน + ทางลาด 4 ทิศ ------------------------------------------
Kit.cylinder(parts, "Dais", V(0, 0, 0), 3, 30, "Marble", "Centerpiece")
local dirs = { N = V(0, 0, -1), S = V(0, 0, 1), E = V(1, 0, 0), W = V(-1, 0, 0) }
for name, dir in dirs do
	Kit.ramp(parts, "DaisRamp" .. name, dir * 20 + V(0, 1.5, 0), 12, 3, 12, -dir, "Marble", "Centerpiece")
end

-- เสาหิน 8 ต้นรอบแท่น (ที่กำบัง) --------------------------------------
for i = 1, 8 do
	local rad = math.rad((i - 1) * 45)
	local pos = V(math.cos(rad) * 45, 0, math.sin(rad) * 45)
	Kit.cylinder(parts, "Pillar" .. i, pos, 12, 5, "Column", "Pillars", { Tags = Kit.Cover })
	Kit.cylinder(parts, "PillarBase" .. i, pos, 2, 7, "StoneDark", "Pillars")
end

-- ที่กั้นไม้เตี้ย 4 จุด -------------------------------------------------
for i = 1, 4 do
	local rad = math.rad(45 + (i - 1) * 90)
	local pos = V(math.cos(rad) * 32, 2, math.sin(rad) * 32)
	local opts = { Yaw = 90 - math.deg(rad), Tags = Kit.Cover }
	Kit.block(parts, "Barricade" .. i, pos, V(14, 4, 2), "Wood", "Cover", opts)
end

-- ระเบียงชมการต่อสู้ ทิศเหนือ/ใต้ พร้อมทางลาด ----------------------------
for _, sz in { -1, 1 } do
	local tag = if sz < 0 then "N" else "S"
	Kit.block(parts, "Balcony" .. tag, V(0, 3, sz * 68), V(30, 6, 12), "Stone", "Balconies")
	Kit.ramp(parts, "BalconyRamp" .. tag, V(0, 3, sz * 56), 12, 6, 12, V(0, 0, sz), "Stone", "Balconies")
end

-- เกาะและทะเลรอบสนาม (ตกแต่ง อยู่นอกกำแพง) ----------------------------
Kit.cylinder(parts, "IslandSand", V(0, -4.5, 0), 4, 340, "Island", "Island", { CanCollide = false })
Kit.block(parts, "Sea", V(0, -8, 0), V(900, 4, 900), "Sea", "Island")
for i = 1, 14 do
	local rad = math.rad(i * 27)
	local dist = 112 + (i % 3) * 10
	local h = 12 + (i % 4) * 2
	local base = V(math.cos(rad) * dist, -0.5, math.sin(rad) * dist)
	Kit.cylinder(parts, "PalmTrunk" .. i, base, h, 2, "Trunk", "Island", { CanCollide = false })
	for k = 1, 3 do
		local leafPos = base + V(0, h + 0.5, 0)
		local leafOpts = { Yaw = k * 60 + i * 11, CanCollide = false }
		Kit.block(parts, `PalmLeaf{i}_{k}`, leafPos, V(14, 0.6, 3), "Leaf", "Island", leafOpts)
	end
end

-- จุดเกิด 8 จุด รัศมี 62 (หันเข้ากลาง) ---------------------------------
local spawns: { CFrame } = {}
for i = 0, 7 do
	local rad = math.rad(22.5 + i * 45)
	local pos = V(math.cos(rad) * 62, 0.5, math.sin(rad) * 62)
	table.insert(spawns, CFrame.lookAt(pos, V(0, 0.5, 0)))
end

return {
	Parts = parts,
	Spawns = spawns,
	Bounds = {
		Min = V(-R, -10, -R),
		Max = V(R, TOP_H + BARRIER_H, R),
	},
	BoundsRadius = R, -- สนามเป็นวงกลม: ระบบต่อสู้ใช้ clamp ตำแหน่งให้อยู่ในวงนี้
}
