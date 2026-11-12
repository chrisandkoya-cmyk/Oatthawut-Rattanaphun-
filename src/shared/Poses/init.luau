--!strict
-- ท่าทางตัวละครที่เล่นด้วยโค้ด (ขยับ Motor6D ของ R15) ใช้แทนอนิเมชันที่ต้องอัปโหลดเป็นไฟล์
-- 1 ตัวละคร = 1 ไฟล์ในโฟลเดอร์นี้ (ชื่อตรงกับ id) คีย์ตรงกับ ctx.fx(...) และคีย์ M1 ของระบบต่อสู้
-- (M1_1..M1_4, M1_Uppercut, M1_Air, Dash, Skill1..4, Ult1..4 ฯลฯ) ถ้าอัปโหลดอนิเมชันจริงแล้ว
-- ให้ใส่ id ใน CharacterInfo.animations แทนได้

export type Frame = {
	t: number, -- วินาทีนับจากเริ่มท่า
	pose: { [string]: Vector3 }, -- ชื่อ Motor6D -> มุมหมุน (องศา x,y,z) ไม่ใส่ = ท่านิ่ง
	move: Vector3?, -- ขยับลำตัวส่วนล่างเล็กน้อย (studs) เช่น พุ่งตัว ย่อเข่า
}

export type Clip = { Frame }

local Poses = {}

function Poses.get(characterId: string, key: string): Clip?
	local module = script:FindFirstChild(characterId)
	if not (module and module:IsA("ModuleScript")) then
		return nil
	end
	local ok, clips = pcall(require, module)
	if not ok then
		warn(`[Poses] โหลด {characterId} ไม่ได้: {clips}`)
		return nil
	end
	return (clips :: any)[key]
end

return Poses
