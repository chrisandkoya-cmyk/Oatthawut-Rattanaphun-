--!strict
-- กฎการต่อสู้แบบ "ฟังก์ชันล้วน" (ไม่แตะ Roblox API) เพื่อเทสนอก Studio ได้
-- รันเทส: luau tests/CombatRules.spec.luau

local CombatRules = {}

-- ตัวเลขใช้ได้จริงไหม (กัน NaN / อินฟินิตี้ จาก client)
function CombatRules.isFinite(n: number): boolean
	return n == n and n ~= math.huge and n ~= -math.huge
end

-- หมัดถัดไปในคอมโบเป็นจังหวะที่เท่าไร (1..maxHits)
function CombatRules.nextComboIndex(
	lastIndex: number,
	lastTime: number,
	now: number,
	resetTime: number,
	maxHits: number
): number
	if lastIndex <= 0 or lastIndex >= maxHits or now - lastTime > resetTime then
		return 1
	end
	return lastIndex + 1
end

export type BlockOutcome = {
	damageTaken: number,
	durability: number,
	broken: boolean,
}

-- คำนวณผลเมื่อโดนตีขณะบล็อก
function CombatRules.applyBlock(
	durability: number,
	damage: number,
	chipMultiplier: number,
	guardBreak: boolean
): BlockOutcome
	if guardBreak then
		return { damageTaken = 0, durability = 0, broken = true }
	end
	local remaining = durability - damage
	if remaining <= 0 then
		return { damageTaken = 0, durability = 0, broken = true }
	end
	return { damageTaken = damage * chipMultiplier, durability = remaining, broken = false }
end

-- เพิ่มเกจอันติ (ไม่เกินเพดาน และไม่ติดลบ)
function CombatRules.addGauge(current: number, amount: number, max: number): number
	if not CombatRules.isFinite(amount) then
		return current
	end
	return math.clamp(current + amount, 0, max)
end

-- เกจที่เหลือระหว่างโหมดอันติ (ลดลงเป็นเส้นตรงจนหมดเวลา)
function CombatRules.ultimateGaugeLeft(now: number, endsAt: number, duration: number, max: number): number
	if duration <= 0 then
		return 0
	end
	return math.clamp((endsAt - now) / duration, 0, 1) * max
end

-- เป้าบล็อกการโจมตีจากทิศนี้ได้ไหม
-- lookX/lookZ = ทิศที่เป้าหัน, toAttackerX/Z = ทิศจากเป้าไปหาผู้โจมตี (ไม่ต้อง normalize)
function CombatRules.isFrontal(
	lookX: number,
	lookZ: number,
	toAttackerX: number,
	toAttackerZ: number,
	minDot: number
): boolean
	local len = math.sqrt(toAttackerX * toAttackerX + toAttackerZ * toAttackerZ)
	if len < 1e-3 then
		return true -- ซ้อนตัวกัน ถือว่าด้านหน้า
	end
	local lookLen = math.sqrt(lookX * lookX + lookZ * lookZ)
	if lookLen < 1e-3 then
		return true
	end
	local dot = (lookX * toAttackerX + lookZ * toAttackerZ) / (len * lookLen)
	return dot > minDot
end

-- ตรวจเลขช่องสกิลที่ client ส่งมา
function CombatRules.isValidSlot(slot: unknown, count: number): boolean
	if typeof(slot) ~= "number" then
		return false
	end
	local n = slot :: number
	return CombatRules.isFinite(n) and n == math.floor(n) and n >= 1 and n <= count
end

return CombatRules
