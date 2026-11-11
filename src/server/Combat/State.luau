--!strict
-- สถานะการต่อสู้ของตัวละครแต่ละตัว (ผู้เล่นหรือหุ่น) เก็บบนเซิร์ฟเวอร์เท่านั้น
-- ค่าที่ client ต้องรู้ (เพื่อแสดง UI) ถูกส่งออกเป็น Attribute

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Types = require(Shared.Types)

export type CombatState = {
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	player: Player?,
	kit: Types.CharacterKit,
	characterId: string,

	comboIndex: number,
	lastM1At: number,
	m1ReadyAt: number,

	blocking: boolean,
	wantsBlock: boolean, -- ผู้เล่นยังกดค้างอยู่ไหม (ยกการ์ดใหม่หลังหายชะงัก)
	blockHP: number,
	alwaysBlock: boolean, -- หุ่นซ้อมที่บล็อกตลอด

	stunnedUntil: number,
	castingUntil: number,
	movementLocked: boolean, -- ท่าที่ร่ายอยู่ล็อกการเคลื่อนที่
	superArmor: boolean, -- ท่าที่ร่ายอยู่ไม่โดนขัด
	invulnUntil: number, -- เฟรมอมตะ (แดช/ลุก/เบิร์สต์)
	cancelAt: number, -- เวลาที่ยกเลิกท่าที่ร่ายอยู่ไปท่าใหม่ได้ (math.huge = ยังไม่ได้)
	comboHits: number, -- ตัวนับคอมโบ "ที่เป้านี้โดน" (ใช้ลดดาเมจ/เพดาน)
	comboDamage: number,
	comboLastHitAt: number,
	juggleCount: number, -- ถูกตีลอยมากี่ครั้งในคอมโบนี้
	uses: { [string]: number }, -- จำนวนครั้งที่ใช้ต่อร่าง
	cooldowns: { [string]: number },

	gauge: number,
	inUltimate: boolean,
	ultEndsAt: number,

	actionToken: number, -- เพิ่มทุกครั้งที่ถูกขัด สกิลที่ค้างอยู่จะหยุด
	animTracks: { [string]: AnimationTrack },
}

local State = {}

local states: { [Model]: CombatState } = {}

function State.now(): number
	return workspace:GetServerTimeNow()
end

function State.create(
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	kit: Types.CharacterKit,
	player: Player?
): CombatState
	local state: CombatState = {
		model = model,
		humanoid = humanoid,
		root = root,
		player = player,
		kit = kit,
		characterId = kit.id,

		comboIndex = 0,
		lastM1At = 0,
		m1ReadyAt = 0,

		blocking = false,
		wantsBlock = false,
		blockHP = Config.Block.MaxDurability,
		alwaysBlock = false,

		stunnedUntil = 0,
		castingUntil = 0,
		movementLocked = false,
		superArmor = false,
		invulnUntil = 0,
		cancelAt = math.huge,
		comboHits = 0,
		comboDamage = 0,
		comboLastHitAt = 0,
		juggleCount = 0,
		uses = {},
		cooldowns = {},

		gauge = 0,
		inUltimate = false,
		ultEndsAt = 0,

		actionToken = 0,
		animTracks = {},
	}
	states[model] = state
	State.setPublic(state, "CharacterId", kit.id)
	State.setPublic(state, "UltGauge", 0)
	State.setPublic(state, "UltEndsAt", 0)
	State.refresh(state)
	return state
end

function State.get(model: Model): CombatState?
	return states[model]
end

function State.remove(model: Model)
	states[model] = nil
end

function State.all(): { [Model]: CombatState }
	return states
end

function State.isAlive(state: CombatState): boolean
	return states[state.model] == state and state.humanoid.Health > 0 and state.model.Parent ~= nil
end

function State.isStunned(state: CombatState): boolean
	return State.now() < state.stunnedUntil
end

-- พร้อมทำท่าโจมตีไหม (ไม่ชะงัก ไม่ร่าย ไม่บล็อก)
function State.canAttack(state: CombatState): boolean
	local now = State.now()
	-- ท่าก่อนหน้าตีโดนแล้ว (cancelAt) ยกเลิกไปท่าใหม่ได้ก่อนท่าจบ
	local free = now >= state.castingUntil or now >= state.cancelAt
	return State.isAlive(state) and now >= state.stunnedUntil and free and not state.blocking
end

-- เริ่มท่าใหม่: ท่าเก่าที่ยังรันอยู่หยุด (ctx.wait คืน false) และเริ่มนับ cancel ใหม่
function State.beginAction(state: CombatState)
	state.actionToken += 1
	state.cancelAt = math.huge
	state.movementLocked = false
	state.superArmor = false
end

function State.resetCombat(state: CombatState)
	state.comboHits = 0
	state.comboDamage = 0
	state.juggleCount = 0
end

-- ค่าที่ client อ่านได้: ผู้เล่น -> Attribute บน Player, หุ่น -> บน Model
function State.setPublic(state: CombatState, name: string, value: any)
	local target: Instance = state.player or state.model
	if target:GetAttribute(name) ~= value then
		target:SetAttribute(name, value)
	end
end

local function setModelAttr(state: CombatState, name: string, value: any)
	if state.model:GetAttribute(name) ~= value then
		state.model:SetAttribute(name, value)
	end
end

-- ขัดสกิล/คอมโบที่ทำอยู่
function State.interrupt(state: CombatState)
	state.actionToken += 1
	state.castingUntil = 0
	state.movementLocked = false
	state.superArmor = false
end

-- คำนวณความเร็วเดิน/กระโดด และอัปเดต Attribute ให้ตรงกับสถานะปัจจุบัน
function State.refresh(state: CombatState)
	local now = State.now()
	local stunned = now < state.stunnedUntil
	local casting = now < state.castingUntil

	local speed = state.kit.stats.walkSpeed
	if state.inUltimate then
		speed *= state.kit.ultimate.walkSpeedMultiplier or 1
	end
	local jump = Config.JumpHeight
	if stunned then
		speed = Config.Stun.WalkSpeed
		jump = 0
	elseif state.blocking then
		speed = Config.Block.WalkSpeed
		jump = 0
	elseif casting then
		if state.movementLocked then
			speed = 0
			jump = 0
		else
			speed = math.min(speed, Config.Cast.WalkSpeed)
		end
	end

	local humanoid = state.humanoid
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end
	if humanoid.UseJumpPower then
		humanoid.UseJumpPower = false
	end
	if humanoid.JumpHeight ~= jump then
		humanoid.JumpHeight = jump
	end

	setModelAttr(state, "Blocking", state.blocking)
	setModelAttr(state, "Stunned", stunned)
	setModelAttr(state, "Casting", casting)
	setModelAttr(state, "InUltimate", state.inUltimate)
end

return State
