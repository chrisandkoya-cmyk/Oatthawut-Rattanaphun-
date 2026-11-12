--!strict
-- ตำแหน่งปุ่มสัมผัสทั้งหมดที่เดียว (HUD + แถบสกิลใช้ร่วมกัน)
-- หลักการ: มุมขวาล่าง 130px ว่างไว้ให้ปุ่มกระโดดของ Roblox ปุ่มอื่นเรียงเป็นวงโค้งรอบมัน
-- ทุกค่าเป็นพิกเซลคูณตัวคูณตามขนาดจอ (จอเล็กไม่เล็กเกินกด จอแท็บเล็ตไม่ใหญ่เกิน)
-- ตำแหน่งวัดจากมุมขวาล่าง: rx = ระยะจากขอบขวา, by = ระยะจากขอบล่าง

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local TouchLayout = {}

export type Spot = { rx: number, by: number, size: number }

-- จอเล็กสุดที่รองรับ ~ 667x375 (แนวนอน)
TouchLayout.Spots = {
	Attack = { rx = 140, by = 22, size = 92 },
	Block = { rx = 28, by = 150, size = 72 },
	Dash = { rx = 154, by = 130, size = 64 },
	Ultimate = { rx = 250, by = 164, size = 64 },
}

-- ปุ่มสกิล 2x2 ทางซ้ายของปุ่มตี
TouchLayout.Skills = { rx = 250, by = 22, cell = 60, gap = 8 }

function TouchLayout.isTouchOnly(): boolean
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function viewportSize(): Vector2
	local camera = Workspace.CurrentCamera
	return if camera then camera.ViewportSize else Vector2.new(800, 400)
end

function TouchLayout.scale(): number
	local viewport = viewportSize()
	return math.clamp(math.min(viewport.X, viewport.Y) / 400, 0.85, 1.25)
end

-- แท็บเล็ต (ด้านสั้น > 500px): Roblox ขยายปุ่มกระโดดเป็น ~120px ที่ R50-170, B90-210
-- ดันปุ่มของเราหนีออกไปเพิ่ม (ค่าเดียวกับที่ทดสอบพิกัดแล้ว ไม่ต้องอ่านตำแหน่งปุ่มจริง)
local TABLET_SHORT_SIDE = 500
local TABLET_SHIFT_X = 40
local TABLET_SHIFT_BLOCK_Y = 70

local function isTablet(): boolean
	local viewport = viewportSize()
	return math.min(viewport.X, viewport.Y) > TABLET_SHORT_SIDE
end

local function shiftX(): number
	return if isTablet() then TABLET_SHIFT_X else 0
end

-- คืน (anchor, position, size) ของปุ่มวงกลมที่ชื่อนั้น
function TouchLayout.place(name: string): (Vector2, UDim2, UDim2)
	local spot = (TouchLayout.Spots :: any)[name] :: Spot
	local s = TouchLayout.scale()
	local rx = spot.rx
	local by = spot.by
	if name == "Block" then
		by += if isTablet() then TABLET_SHIFT_BLOCK_Y else 0
	else
		rx += shiftX()
	end
	return Vector2.new(1, 1),
		UDim2.new(1, -math.floor(rx * s), 1, -math.floor(by * s)),
		UDim2.fromOffset(math.floor(spot.size * s), math.floor(spot.size * s))
end

-- กรอบ 2x2 ของปุ่มสกิล คืน (anchor, position, size, cell, gap)
function TouchLayout.skillGrid(): (Vector2, UDim2, UDim2, UDim2, UDim2)
	local k = TouchLayout.Skills
	local s = TouchLayout.scale()
	local cell = math.floor(k.cell * s)
	local gap = math.floor(k.gap * s)
	local total = cell * 2 + gap
	return Vector2.new(1, 1),
		UDim2.new(1, -math.floor((k.rx + shiftX()) * s), 1, -math.floor(k.by * s)),
		UDim2.fromOffset(total, total),
		UDim2.fromOffset(cell, cell),
		UDim2.fromOffset(gap, gap)
end

-- จอหมุน/เปลี่ยนขนาด: เรียก callback ให้จัดเลย์เอาต์ใหม่ (คืนตัวตัดการเชื่อมต่อ)
function TouchLayout.watch(callback: () -> ()): () -> ()
	local camera = Workspace.CurrentCamera
	if not camera then
		return function() end
	end
	local conn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(callback)
	return function()
		conn:Disconnect()
	end
end

return TouchLayout
