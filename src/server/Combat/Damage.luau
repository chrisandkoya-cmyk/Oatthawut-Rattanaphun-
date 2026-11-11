--!strict
-- คำนวณดาเมจ บล็อก การ์ดแตก ชะงัก ผลัก และเกจอันติ (เซิร์ฟเวอร์เป็นผู้ตัดสินทั้งหมด)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Types = require(Shared.Types)
local CombatRules = require(Shared.CombatRules)
local State = require(script.Parent.State)
local Fx = require(script.Parent.Fx)

local Damage = {}

function Damage.addGauge(state: State.CombatState, amount: number)
	if state.inUltimate then
		return
	end
	state.gauge = CombatRules.addGauge(state.gauge, amount, Config.Ultimate.Max)
	State.setPublic(state, "UltGauge", math.floor(state.gauge))
end

local function guardBreak(target: State.CombatState)
	target.blocking = false
	target.blockHP = 0
	target.stunnedUntil = math.max(target.stunnedUntil, State.now() + Config.Block.GuardBreakStun)
	State.interrupt(target)
	State.refresh(target)
	Fx.emit({ kind = "GuardBreak", target = target.model, position = target.root.Position })
end

local function knockback(targetModel: Model, targetRoot: BasePart, origin: Vector3, info: Types.DamageInfo)
	local horizontal = info.knockback or 0
	local up = info.knockbackUp or 0
	if horizontal == 0 and up == 0 then
		return
	end
	local away = targetRoot.Position - origin
	away = Vector3.new(away.X, 0, away.Z)
	if away.Magnitude < 1e-3 then
		away = -targetRoot.CFrame.LookVector
	end
	local velocity = away.Unit * horizontal + Vector3.new(0, up, 0)
	Fx.push(targetModel, velocity, Config.Knockback.Duration)

	local bounce = info.bounce
	if bounce and bounce > 0 then
		task.delay(Config.M1.Downslam.BounceDelay, function()
			if targetModel.Parent then
				Fx.push(targetModel, Vector3.new(0, bounce, 0), Config.Knockback.Duration)
			end
		end)
	end
end

-- ทำดาเมจใส่เป้า 1 ตัว คืนผลลัพธ์
-- attacker = nil ได้ (เช่น ดาเมจจากสิ่งแวดล้อม), origin = ตำแหน่งต้นทางการโจมตี
function Damage.apply(
	attacker: State.CombatState?,
	targetModel: Model,
	info: Types.DamageInfo,
	origin: Vector3?
): Types.HitResult
	local humanoid = targetModel:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not (targetRoot and targetRoot:IsA("BasePart")) then
		return "Miss"
	end
	if attacker and attacker.model == targetModel then
		return "Miss"
	end
	-- กันค่าเพี้ยนจากโค้ดสกิล
	if not CombatRules.isFinite(info.damage) or info.damage < 0 then
		return "Miss"
	end

	local amount = info.damage
	if attacker and attacker.inUltimate then
		if info.m1 then
			amount *= attacker.kit.ultimate.m1DamageMultiplier or 1
		else
			amount *= attacker.kit.ultimate.damageMultiplier or 1
		end
	end
	-- ForceField (เกราะตอนเกิด) = ไม่โดนอะไรทั้งนั้น ไม่ชะงัก ไม่ถูกผลัก ไม่เพิ่มเกจ
	if targetModel:FindFirstChildOfClass("ForceField") then
		return "Miss"
	end
	local from = origin or (attacker and attacker.root.Position) or targetRoot.Position
	local target = State.get(targetModel)
	-- เฟรมอมตะของแดช
	if target and State.now() < target.invulnUntil then
		return "Miss"
	end

	-- บล็อก
	if target and target.blocking and info.blockable ~= false then
		local look = target.root.CFrame.LookVector
		local toAttacker = from - target.root.Position
		if CombatRules.isFrontal(look.X, look.Z, toAttacker.X, toAttacker.Z, Config.Block.FrontDot) then
			local outcome =
				CombatRules.applyBlock(target.blockHP, amount, Config.Block.ChipMultiplier, info.guardBreak == true)
			if outcome.broken then
				guardBreak(target)
				return "GuardBreak"
			end
			target.blockHP = outcome.durability
			if outcome.damageTaken > 0 then
				humanoid:TakeDamage(outcome.damageTaken)
			end
			Fx.emit({ kind = "Blocked", target = targetModel, position = targetRoot.Position })
			return "Blocked"
		end
	end

	-- กติกาคอมโบ: ยิ่งโดนต่อเนื่อง ดาเมจยิ่งลด และรวมแล้วไม่เกินเพดาน
	if target then
		if State.now() - target.comboLastHitAt > Config.Combo.EndAfter + Config.Stun.Default then
			State.resetCombat(target) -- ห่างจากหมัดก่อนหน้านานแล้ว เริ่มคอมโบใหม่
		end
		amount = CombatRules.scaleDamage(amount, target.comboHits, Config.Combo.ScalePerHit, Config.Combo.MinScale)
		amount = CombatRules.capDamage(amount, target.comboDamage, humanoid.MaxHealth * Config.Combo.CapFraction)
		target.comboHits += 1
		target.comboDamage += amount
		target.comboLastHitAt = State.now()
	end

	-- โดนเต็มๆ (TakeDamage เคารพ ForceField ตอนเกิด)
	humanoid:TakeDamage(amount)
	if attacker and amount > 0 then
		-- ตีโดนแล้ว ยกเลิกท่าที่ร่ายอยู่ไปท่าต่อไปได้ (M1 → สกิล → M1)
		attacker.cancelAt = math.min(attacker.cancelAt, State.now() + Config.Cancel.HitConfirmDelay)
	end

	local armored = false
	if target then
		armored = target.superArmor and State.now() < target.castingUntil
		if not armored then
			target.stunnedUntil = math.max(target.stunnedUntil, State.now() + (info.stun or Config.Stun.Default))
			target.blocking = false
			target.comboIndex = 0
			State.interrupt(target)
		end
		Damage.addGauge(target, amount * Config.Ultimate.GainPerDamageTaken)
		State.refresh(target)
	end
	if attacker then
		Damage.addGauge(attacker, amount * Config.Ultimate.GainPerDamageDealt)
	end

	if not armored then
		local kb = info
		if target and (info.knockbackUp or 0) > 0 then
			-- ตีลอยซ้ำ: แรงลอยลดลงทุกครั้ง จนตกพื้น
			local scale = CombatRules.juggleScale(target.juggleCount, Config.Combo.JuggleDecay)
			target.juggleCount += 1
			kb = table.clone(info)
			kb.knockbackUp = (info.knockbackUp or 0) * scale
			if scale <= 0 then
				kb.bounce = nil
			end
		end
		knockback(targetModel, targetRoot, from, kb)
	end

	Fx.emit({
		kind = "Hit",
		target = targetModel,
		source = attacker and attacker.model or nil,
		characterId = attacker and attacker.characterId or nil,
		position = targetRoot.Position,
		amount = math.floor(amount + 0.5),
	})
	return "Hit"
end

return Damage
