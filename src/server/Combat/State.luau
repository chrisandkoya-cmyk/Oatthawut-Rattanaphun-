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
	return State.isAlive(state) and now >= state.stunnedUntil and now >= state.castingUntil and not state.blocking
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
		speed = math.min(speed, Config.Cast.WalkSpeed)
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
