--!strict
-- แมพ "ดาดฟ้าเรือโจรสลัด": ดาดฟ้า 180x60 มีหัวเรือ/ท้ายเรือยกสูง เสากระโดง 2 ต้น ห้องกัปตัน และลังสินค้า
-- จุดกึ่งกลางที่ (0, 0, 0) พื้นดาดฟ้าสูง Y = 0 หัวเรือ = -X ท้ายเรือ = +X

local Kit = require(script.Parent.Parent.ArenaKit)

local SX = 180
local SZ = 60
local RAIL_H = 5
local BARRIER_H = 120
local DECK_H = 6 -- ความสูงของหัวเรือ/ท้ายเรือ

local parts: { Kit.PartSpec } = {}
local V = Vector3.new

Kit.block(parts, "Deck", V(0, -2, 0), V(SX, 4, SZ), "Deck", "Ground")
Kit.block(parts, "Sea", V(0, -8, 0), V(700, 4, 700), "Sea", "Ground")
Kit.enclosure(parts, SX, SZ, RAIL_H, BARRIER_H, "Rail", "Hull")

-- หัวเรือ (-X) และท้ายเรือ (+X) ยกสูง พร้อมบันได
for _, side in { -1, 1 } do
	local tag = if side < 0 then "Bow" else "Stern"
	Kit.block(parts, tag .. "Deck", V(side * 70, DECK_H / 2, 0), V(40, DECK_H, 56), "Cabin", "Decks")
	Kit.ramp(parts, tag .. "Stairs", V(side * 44, DECK_H / 2, 0), 14, DECK_H, 12, V(side, 0, 0), "Cabin", "Decks")
end

-- เสากระโดง 2 ต้น พร้อมใบเรือ
for i, x in { -22, 22 } do
	Kit.cylinder(parts, "Mast" .. i, V(x, 0, 0), 50, 3.5, "Mast", "Masts", { Tags = Kit.Cover })
	Kit.block(parts, "Yard" .. i, V(x, 42, 0), V(2, 2, 34), "Mast", "Masts", { CanCollide = false })
	Kit.block(parts, "Sail" .. i, V(x + 0.8, 30, 0), V(0.6, 20, 30), "Sail", "Masts", { CanCollide = false })
end

-- ห้องกัปตันกลางเรือ (ด้านเหนือ)
Kit.block(parts, "Cabin", V(0, 5, -12), V(20, 10, 16), "Cabin", "Cabin", { Tags = Kit.Cover })
Kit.block(parts, "CabinRoof", V(0, 11, -12), V(22, 2, 18), "CabinRoof", "Cabin")

-- ลังสินค้า
local crates = {
	V(-40, 0, -18),
	V(-40, 0, 18),
	V(40, 0, -18),
	V(40, 0, 18),
	V(0, 0, 14),
}
for i, p in crates do
	Kit.block(parts, "Crate" .. i, p + V(0, 3, 0), V(6, 6, 6), "Crate", "Cover", { Yaw = i * 17, Tags = Kit.Cover })
end

-- จุดเกิด: ท้าย/หัวเรือ 4 จุด + กลางดาดฟ้า 4 จุด
local spawnSpots = {
	V(-80, DECK_H + 0.5, -14),
	V(-80, DECK_H + 0.5, 14),
	V(80, DECK_H + 0.5, -14),
	V(80, DECK_H + 0.5, 14),
	V(-40, 0.5, 0),
	V(40, 0.5, 0),
	V(0, 0.5, 24),
	V(0, 0.5, -26),
}
local spawns: { CFrame } = {}
for _, pos in spawnSpots do
	table.insert(spawns, CFrame.lookAt(pos, V(0, pos.Y, 0)))
end

return {
	Parts = parts,
	Spawns = spawns,
	Bounds = Kit.bounds(SX, SZ, RAIL_H, BARRIER_H),
}
