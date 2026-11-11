--!strict
-- ตัวช่วยสร้าง Layout ของแมพ: วางบล็อก/ทรงกระบอก/ทางลาด และกำแพงล้อมลาน
-- ใช้ร่วมกันทุกแมพ (ข้อมูลล้วน ไม่แตะ Workspace)

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

export type Options = {
	Yaw: number?, -- หมุนรอบแกน Y (องศา)
	Tags: { string }?,
	CanCollide: boolean?,
}

local ArenaKit = {}

local COVER = { "ArenaCover" }
ArenaKit.Cover = COVER

-- บล็อก: pos = จุดกึ่งกลาง
function ArenaKit.block(
	parts: { PartSpec },
	name: string,
	pos: Vector3,
	size: Vector3,
	look: string,
	group: string,
	opts: Options?
)
	local o = opts or {}
	table.insert(parts, {
		Name = name,
		Shape = "Block",
		Size = size,
		CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(o.Yaw or 0), 0),
		Look = look,
		Group = group,
		CanCollide = o.CanCollide,
		Tags = o.Tags,
	})
end

-- ทรงกระบอกตั้งตรง: base = จุดกึ่งกลางฐาน
function ArenaKit.cylinder(
	parts: { PartSpec },
	name: string,
	base: Vector3,
	height: number,
	diameter: number,
	look: string,
	group: string,
	opts: Options?
)
	local o = opts or {}
	table.insert(parts, {
		Name = name,
		Shape = "Cylinder",
		Size = Vector3.new(height, diameter, diameter), -- Cylinder ของ Roblox ยาวตามแกน X
		CFrame = CFrame.new(base + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Look = look,
		Group = group,
		CanCollide = o.CanCollide,
		Tags = o.Tags,
	})
end

-- ทางลาด: center = กึ่งกลางทางลาด, highDir = ทิศแนวนอนที่ด้านสูงชี้ไป
-- (สมมติด้านสูงของ WedgePart อยู่ที่ +Z ตามค่าเริ่มต้น)
function ArenaKit.ramp(
	parts: { PartSpec },
	name: string,
	center: Vector3,
	width: number,
	height: number,
	length: number,
	highDir: Vector3,
	look: string,
	group: string
)
	table.insert(parts, {
		Name = name,
		Shape = "Wedge",
		Size = Vector3.new(width, height, length),
		CFrame = CFrame.lookAt(center, center - highDir),
		Look = look,
		Group = group,
	})
end

-- กำแพงรอบลาน + กำแพงล่องหน + เพดานล่องหน (ลานกว้าง sx x sz กึ่งกลางที่ 0,0,0)
function ArenaKit.enclosure(
	parts: { PartSpec },
	sx: number,
	sz: number,
	wallH: number,
	barrierH: number,
	wallLook: string,
	capLook: string
)
	local T = 4
	local sides = {
		{ name = "North", center = Vector3.new(0, 0, -(sz + T) / 2), span = Vector3.new(sx + T * 2, 0, T) },
		{ name = "South", center = Vector3.new(0, 0, (sz + T) / 2), span = Vector3.new(sx + T * 2, 0, T) },
		{ name = "East", center = Vector3.new((sx + T) / 2, 0, 0), span = Vector3.new(T, 0, sz) },
		{ name = "West", center = Vector3.new(-(sx + T) / 2, 0, 0), span = Vector3.new(T, 0, sz) },
	}
	for _, side in sides do
		local sideName = side.name
		local center = side.center
		local span = side.span
		ArenaKit.block(
			parts,
			"Wall" .. sideName,
			center + Vector3.new(0, wallH / 2, 0),
			Vector3.new(span.X, wallH, span.Z),
			wallLook,
			"Walls"
		)
		ArenaKit.block(
			parts,
			"WallCap" .. sideName,
			center + Vector3.new(0, wallH + 1, 0),
			Vector3.new(span.X + 2, 2, span.Z + 2),
			capLook,
			"Walls"
		)
		ArenaKit.block(
			parts,
			"Barrier" .. sideName,
			center + Vector3.new(0, wallH + 2 + barrierH / 2, 0),
			Vector3.new(span.X, barrierH, span.Z),
			"Barrier",
			"Barriers"
		)
	end
	ArenaKit.block(
		parts,
		"BarrierCeiling",
		Vector3.new(0, wallH + 2 + barrierH + 2, 0),
		Vector3.new(sx + T * 2, 4, sz + T * 2),
		"Barrier",
		"Barriers"
	)
end

-- จุดเกิดมาตรฐาน 8 จุด: มุมลาน 4 + กึ่งกลางขอบ 4 (หันเข้ากลาง)
function ArenaKit.edgeSpawns(sx: number, sz: number, inset: number, y: number): { CFrame }
	local hx = sx / 2 - inset
	local hz = sz / 2 - inset
	local spots = {
		Vector3.new(-hx, y, -hz),
		Vector3.new(hx, y, -hz),
		Vector3.new(-hx, y, hz),
		Vector3.new(hx, y, hz),
		Vector3.new(-hx, y, 0),
		Vector3.new(hx, y, 0),
		Vector3.new(0, y, -hz),
		Vector3.new(0, y, hz),
	}
	local result: { CFrame } = {}
	for _, pos in spots do
		table.insert(result, CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0)))
	end
	return result
end

function ArenaKit.bounds(sx: number, sz: number, wallH: number, barrierH: number)
	return {
		Min = Vector3.new(-sx / 2, -10, -sz / 2),
		Max = Vector3.new(sx / 2, wallH + barrierH, sz / 2),
	}
end

return ArenaKit
