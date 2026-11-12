--!strict
-- เทสกฎต่อสู้แบบฟังก์ชันล้วน รันด้วย: luau tests/CombatRules.spec.luau
local CombatRules = require("../src/shared/CombatRules")

local failures = 0
local function check(name: string, ok: boolean)
	if ok then
		print("PASS " .. name)
	else
		failures += 1
		print("FAIL " .. name)
	end
end

-- คอมโบ
check("combo starts at 1", CombatRules.nextComboIndex(0, 0, 10, 1.2, 4) == 1)
check("combo advances", CombatRules.nextComboIndex(1, 10, 10.4, 1.2, 4) == 2)
check("combo resets after final hit", CombatRules.nextComboIndex(4, 10, 10.4, 1.2, 4) == 1)
check("combo resets on timeout", CombatRules.nextComboIndex(2, 10, 12, 1.2, 4) == 1)

-- บล็อก
local b = CombatRules.applyBlock(40, 10, 0, false)
check("block absorbs damage", b.damageTaken == 0 and b.durability == 30 and not b.broken)
check("block breaks at 0", CombatRules.applyBlock(10, 10, 0, false).broken)
check("guardBreak breaks instantly", CombatRules.applyBlock(40, 1, 0, true).broken)
check("chip damage", CombatRules.applyBlock(40, 10, 0.2, false).damageTaken == 2)

-- เกจ
check("gauge clamps to max", CombatRules.addGauge(95, 20, 100) == 100)
check("gauge ignores NaN", CombatRules.addGauge(50, 0 / 0, 100) == 50)
check("gauge never negative", CombatRules.addGauge(5, -20, 100) == 0)
check("ult gauge drains", CombatRules.ultimateGaugeLeft(10, 20, 20, 100) == 50)
check("ult gauge empty after end", CombatRules.ultimateGaugeLeft(25, 20, 20, 100) == 0)

-- ทิศบล็อก
check("front blocked", CombatRules.isFrontal(0, -1, 0, -5, 0))
check("back not blocked", not CombatRules.isFrontal(0, -1, 0, 5, 0))
check("side not blocked", not CombatRules.isFrontal(0, -1, 5, 0, 0))

-- ตรวจ input
check("slot ok", CombatRules.isValidSlot(3, 4))
check("slot 0 bad", not CombatRules.isValidSlot(0, 4))
check("slot 1.5 bad", not CombatRules.isValidSlot(1.5, 4))
check("slot NaN bad", not CombatRules.isValidSlot(0 / 0, 4))
check("slot inf bad", not CombatRules.isValidSlot(math.huge, 4))
check("slot string bad", not CombatRules.isValidSlot("1", 4))

-- คอมโบ
check("scale no hits = full", CombatRules.scaleDamage(10, 0, 0.06, 0.4) == 10)
check("scale decreases", CombatRules.scaleDamage(10, 5, 0.06, 0.4) < 10)
check("scale floors", math.abs(CombatRules.scaleDamage(10, 100, 0.06, 0.4) - 4) < 1e-9)
check("cap limits", CombatRules.capDamage(10, 45, 50) == 5)
check("cap never negative", CombatRules.capDamage(10, 60, 50) == 0)
check("cap passes small", CombatRules.capDamage(3, 0, 50) == 3)
check("juggle first launch full", CombatRules.juggleScale(0, 0.3) == 1)
check("juggle decays", CombatRules.juggleScale(2, 0.3) < 0.5)
check("juggle ends", CombatRules.juggleScale(4, 0.3) == 0)

if failures > 0 then
	error(failures .. " test(s) failed")
end
print("ALL PASS")
