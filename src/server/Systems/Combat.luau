--!strict
-- ระบบต่อสู้หลัก: M1 คอมโบ, M1 พิเศษ (อัปเปอร์คัต / ทุบกลางอากาศ), บล็อก, แดช, สกิล 4 ท่า, อันติ
-- ทุกอย่างตัดสินบนเซิร์ฟเวอร์ client แค่ส่งคำขอ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Types = require(Shared.Types)
local Net = require(Shared.Net)
local CombatRules = require(Shared.CombatRules)

local Combat = ServerScriptService:WaitForChild("Server"):WaitForChild("Combat")
local State = require(Combat.State)
local Damage = require(Combat.Damage)
local Fx = require(Combat.Fx)
local Hitbox = require(Combat.Hitbox)
local Kits = require(Combat.Kits)
local RateLimit = require(Combat.RateLimit)
local SkillContext = require(Combat.SkillContext)

local CombatSystem = {}

local selected: { [Player]: string } = {}

----------------------------------------------------------------------
-- สร้าง/ลบสถานะตัวละคร
----------------------------------------------------------------------

function CombatSystem.register(model: Model, kit: Types.CharacterKit, player: Player?): State.CombatState?
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or not (root and root:IsA("BasePart")) then
		return nil
	end
	humanoid.MaxHealth = kit.stats.maxHealth
	humanoid.Health = kit.stats.maxHealth
	local state = State.create(model, humanoid, root, kit, player)

	humanoid.Died:Connect(function()
		State.interrupt(state)
		state.blocking = false
		State.remove(model)
	end)
	model.AncestryChanged:Connect(function()
		if not model.Parent then
			State.remove(model)
		end
	end)
	return state
end

local function disableRegen(character: Model)
	if not Config.DisableHealthRegen then
		return
	end
	local health = character:FindFirstChild("Health")
	if health and health:IsA("Script") then
		health:Destroy()
	end
end

local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not (humanoid and humanoid:IsA("Humanoid") and root) then
		return
	end
	disableRegen(character)
	local id = selected[player]
	local kit = id and Kits.get(id) or Kits.get(Config.DefaultCharacter)
	if not kit then
		warn("[Combat] ไม่พบตัวละครเริ่มต้น " .. Config.DefaultCharacter)
		return
	end
	-- ล้างคูลดาวน์ที่ค้างจากตัวเก่า (ตัวใหม่เริ่มสะอาด)
	for _, key in { "S1", "S2", "S3", "S4", "U1", "U2", "U3", "U4", "Dash" } do
		player:SetAttribute("Cd" .. key, 0)
	end
	CombatSystem.register(character, kit, player)
	player:SetAttribute("CharacterId", kit.id) -- ให้เมนูอ่านว่าเซิร์ฟเวอร์ใช้ตัวไหนอยู่จริง
end

----------------------------------------------------------------------
-- ตัวช่วย
----------------------------------------------------------------------

local function stateOf(player: Player): State.CombatState?
	local character = player.Character
	if not character then
		return nil
	end
	local state = State.get(character)
	if state and State.isAlive(state) then
		return state
	end
	return nil
end

local function rateOk(player: Player, key: string): boolean
	local limit = (Config.RateLimit :: any)[key]
	return RateLimit.allow(player, key, limit.rate, limit.burst)
end

local function onGround(state: State.CombatState): boolean
	return state.humanoid.FloorMaterial ~= Enum.Material.Air
end

local function activeSkills(state: State.CombatState): { Types.Skill }
	if state.inUltimate then
		return state.kit.ultimate.skills
	end
	return state.kit.skills
end

----------------------------------------------------------------------
-- M1
----------------------------------------------------------------------

local function m1Damage(state: State.CombatState, index: number): number
	local overrides = state.kit.m1
	local list = overrides and overrides.damage or Config.M1.Damage
	return list[index] or list[#list]
end

-- สูงจากพื้นกี่สตัด (raycast ลง) ใช้แยก "กระโดดค้างแล้วตีเสย" ออกจาก "ตีกดกลางอากาศ"
local function heightAboveGround(state: State.CombatState): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { state.model }
	local result = workspace:Raycast(state.root.Position, Vector3.new(0, -60, 0), params)
	local hipHeight = state.humanoid.HipHeight + state.root.Size.Y / 2
	if not result then
		return 60
	end
	return math.max(0, state.root.Position.Y - result.Position.Y - hipHeight)
end

local function doM1(state: State.CombatState, wantsUppercut: boolean)
	local cfg = Config.M1
	local now = State.now()
	if not State.canAttack(state) or now < state.m1ReadyAt then
		return
	end

	-- เลือกท่า: เสย (ค้าง Space + ใกล้พื้น) มาก่อนตีกด (กลางอากาศ) ท่าพิเศษทั้งสองใช้คูลดาวน์ร่วม
	local special: string? = nil
	if wantsUppercut and heightAboveGround(state) <= cfg.Uppercut.MaxHeightAboveGround then
		special = "Uppercut"
	elseif not onGround(state) then
		special = "Slam"
	end
	if special and now < (state.cooldowns.Special or 0) then
		if special == "Slam" then
			return -- กลางอากาศ ท่าติดคูลดาวน์ ตีไม่ได้
		end
		special = nil -- พื้น ท่าติดคูลดาวน์ ใช้คอมโบปกติแทน
	end
	local info: Types.DamageInfo
	local animKey: string
	local lag = cfg.Interval

	if special == "Slam" then
		-- กระโดดแล้วตี: ทุบลงพื้น เป้ากระเด้งกลับ
		local d = cfg.Downslam
		info = {
			damage = d.Damage,
			stun = d.Stun,
			knockback = d.Knockback,
			knockbackUp = d.KnockbackUp,
			bounce = d.BounceUp,
		}
		animKey = "M1_Air"
		state.cooldowns.Special = now + cfg.SpecialCooldown
		state.comboIndex = 0
		lag = cfg.EndLag
	elseif special == "Uppercut" then
		-- กด Space ค้างแล้วตี: อัปเปอร์คัต ตีขึ้นฟ้า
		local u = cfg.Uppercut
		info = { damage = u.Damage, stun = u.Stun, knockback = u.Knockback, knockbackUp = u.KnockbackUp }
		animKey = "M1_Uppercut"
		state.cooldowns.Special = now + cfg.SpecialCooldown
		state.comboIndex = 0
		lag = cfg.EndLag
	else
		local index = CombatRules.nextComboIndex(state.comboIndex, state.lastM1At, now, cfg.ComboReset, cfg.MaxHits)
		state.comboIndex = index
		state.lastM1At = now
		local final = index == cfg.MaxHits
		local overrides = state.kit.m1
		info = {
			damage = m1Damage(state, index),
			stun = final and cfg.FinalStun or cfg.Stun,
			knockback = final and (overrides and overrides.finalKnockback or cfg.FinalKnockback) or nil,
			knockbackUp = final and cfg.FinalKnockbackUp or nil,
		}
		animKey = "M1_" .. index
		if final then
			lag = cfg.EndLag
		end
	end

	info.m1 = true
	state.m1ReadyAt = now + lag
	state.lastM1At = now
	state.castingUntil = now + cfg.ActionLock
	state.movementLocked = false
	state.superArmor = false
	State.refresh(state)
	Fx.anim(state, animKey)
	Fx.emit({ kind = "Skill", key = animKey, characterId = state.characterId, source = state.model })

	local token = state.actionToken
	task.delay(cfg.ActionLock, function()
		if State.isAlive(state) then
			State.refresh(state)
		end
	end)
	task.delay(cfg.Windup, function()
		-- ถูกขัดระหว่างง้างหมัด = หมัดไม่ออก
		if not State.isAlive(state) or state.actionToken ~= token or State.isStunned(state) then
			return
		end
		local size = state.kit.m1 and state.kit.m1.hitboxSize or cfg.HitboxSize
		local boxCFrame = Hitbox.inFront(state.root, cfg.HitboxOffset)
		if special == "Slam" then
			-- ตีกด: ขยายกล่องลงล่าง (ReachDown) ให้ถึงเป้าบนพื้น
			local down = cfg.Downslam.ReachDown
			size = Vector3.new(size.X, size.Y + down, size.Z)
			boxCFrame = boxCFrame * CFrame.new(0, -down / 2, 0)
		end
		local targets = Hitbox.query(state.model, boxCFrame, size)
		for _, target in targets do
			Damage.apply(state, target, info)
		end
	end)
end

----------------------------------------------------------------------
-- บล็อก
----------------------------------------------------------------------

local function setBlock(state: State.CombatState, wants: boolean)
	state.wantsBlock = wants
	if wants then
		local now = State.now()
		if state.blocking or now < state.stunnedUntil or now < state.castingUntil then
			return
		end
		if state.blockHP < Config.Block.MinToRaise then
			return
		end
		state.blocking = true
		State.interrupt(state)
	else
		state.blocking = false
	end
	State.refresh(state)
end

----------------------------------------------------------------------
-- แดช
----------------------------------------------------------------------

local function doDash(state: State.CombatState, dirX: number, dirZ: number)
	local now = State.now()
	if not State.canAttack(state) then
		return
	end
	if now < (state.cooldowns.Dash or 0) then
		return
	end
	local direction = Vector3.new(dirX, 0, dirZ)
	if direction.Magnitude < 0.1 then
		-- ไม่ได้กดทิศ = พุ่งไปข้างหน้า
		local look = state.root.CFrame.LookVector
		direction = Vector3.new(look.X, 0, look.Z)
	end
	if direction.Magnitude < 1e-3 then
		return
	end
	state.cooldowns.Dash = now + Config.Dash.Cooldown
	State.setPublic(state, "CdDash", now + Config.Dash.Cooldown)
	state.invulnUntil = now + Config.Dash.IFrames
	Fx.push(state.model, direction.Unit * Config.Dash.Speed, Config.Dash.Duration)
	Fx.emit({ kind = "Skill", key = "Dash", characterId = state.characterId, source = state.model })
end

----------------------------------------------------------------------
-- สกิล + อันติ
----------------------------------------------------------------------

local function runSkill(state: State.CombatState, skill: Types.Skill, cooldownKey: string)
	local now = State.now()
	local castTime = skill.castTime or Config.Cast.DefaultTime
	state.cooldowns[cooldownKey] = now + skill.cooldown
	State.setPublic(state, "Cd" .. cooldownKey, now + skill.cooldown) -- ให้แถบสกิลฝั่ง client แสดงคูลดาวน์
	state.castingUntil = now + castTime
	state.movementLocked = skill.movementLock == true
	state.superArmor = skill.interruptible == false
	if skill.usesPerForm then
		state.uses[cooldownKey] = (state.uses[cooldownKey] or 0) + 1
	end
	State.refresh(state)
	task.delay(castTime, function()
		if State.isAlive(state) then
			State.refresh(state)
		end
	end)
	local ctx = SkillContext.new(state)
	task.spawn(function()
		local ok, err = pcall(skill.run, ctx)
		if not ok then
			warn(`[Combat] สกิล {cooldownKey} ของ {state.characterId} error: {err}`)
		end
	end)
end

local function doSkill(state: State.CombatState, slot: number)
	if not State.canAttack(state) then
		return
	end
	local skills = activeSkills(state)
	local skill = skills[slot]
	if not skill then
		return
	end
	local key = (state.inUltimate and "U" or "S") .. slot
	if State.now() < (state.cooldowns[key] or 0) then
		return
	end
	if skill.usesPerForm and (state.uses[key] or 0) >= skill.usesPerForm then
		return
	end
	runSkill(state, skill, key)
end

local function endUltimate(state: State.CombatState)
	if not state.inUltimate then
		return
	end
	state.inUltimate = false
	state.uses = {}
	state.gauge = 0
	state.ultEndsAt = 0
	State.setPublic(state, "UltGauge", 0)
	State.setPublic(state, "UltEndsAt", 0)
	-- ล้างคูลดาวน์ชุดอันติ
	for key in state.cooldowns do
		if string.sub(key, 1, 1) == "U" then
			state.cooldowns[key] = nil
			State.setPublic(state, "Cd" .. key, 0)
		end
	end
	local onEnd = state.kit.ultimate.onEnd
	if onEnd then
		pcall(onEnd, SkillContext.new(state))
	end
	Fx.emit({ kind = "UltEnd", source = state.model, characterId = state.characterId })
	State.refresh(state)
end

local function doUltimate(state: State.CombatState)
	if state.inUltimate or not State.canAttack(state) then
		return
	end
	if state.gauge < Config.Ultimate.Max then
		return
	end
	local ult = state.kit.ultimate
	state.inUltimate = true
	state.uses = {}
	state.humanoid.Health = math.min(state.humanoid.MaxHealth, state.humanoid.Health + Config.Ultimate.HealOnStart)
	state.gauge = Config.Ultimate.Max
	state.ultEndsAt = State.now() + ult.duration
	State.setPublic(state, "UltEndsAt", state.ultEndsAt)
	State.setPublic(state, "UltGauge", Config.Ultimate.Max)
	State.refresh(state)
	Fx.emit({ kind = "UltStart", source = state.model, characterId = state.characterId })
	if ult.onStart then
		task.spawn(function()
			local ok, err = pcall(ult.onStart :: any, SkillContext.new(state))
			if not ok then
				warn(`[Combat] ultimate.onStart error: {err}`)
			end
		end)
	end

	local endsAt = state.ultEndsAt
	task.delay(ult.duration, function()
		if state.inUltimate and state.ultEndsAt == endsAt then
			endUltimate(state)
		end
	end)
end

----------------------------------------------------------------------
-- จังหวะรายเฟรม: ฟื้นการ์ด / ยกการ์ดใหม่ / เกจอันติลดลง
----------------------------------------------------------------------

local function tick(dt: number)
	local now = State.now()
	for _, state in State.all() do
		if not State.isAlive(state) then
			continue
		end
		if state.alwaysBlock and not state.blocking and state.blockHP >= Config.Block.MinToRaise then
			state.blocking = true
			State.refresh(state)
		end
		if not state.blocking and state.blockHP < Config.Block.MaxDurability then
			state.blockHP = math.min(Config.Block.MaxDurability, state.blockHP + Config.Block.RegenPerSecond * dt)
		end
		if state.wantsBlock and not state.blocking then
			setBlock(state, true)
		end
		if state.inUltimate then
			State.setPublic(
				state,
				"UltGauge",
				math.floor(
					CombatRules.ultimateGaugeLeft(
						now,
						state.ultEndsAt,
						state.kit.ultimate.duration,
						Config.Ultimate.Max
					)
				)
			)
		end
		-- ชะงักหมด/ร่ายเสร็จ ให้ความเร็วเดินกลับมา
		State.refresh(state)
	end
end

----------------------------------------------------------------------
-- เลือกตัวละคร
----------------------------------------------------------------------

local function onSelect(player: Player, id: unknown)
	if not rateOk(player, "SelectCharacter") then
		return
	end
	if typeof(id) ~= "string" or not Kits.has(id :: string) then
		return
	end
	selected[player] = id :: string
	-- ใช้ตัวละครใหม่ตอนเกิดครั้งถัดไป (ไม่ฆ่าผู้เล่นกลางต่อสู้)
end

----------------------------------------------------------------------
-- Lifecycle (bootstrap เรียก init แล้วค่อย start)
----------------------------------------------------------------------

function CombatSystem.init()
	Kits.load(ServerScriptService.Server.Characters)
	Players.CharacterAutoLoads = true

	local function setup(player: Player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
		if player.Character then
			task.spawn(onCharacterAdded, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(setup)
	for _, player in Players:GetPlayers() do
		setup(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		selected[player] = nil
	end)

	-- รับคำขอจาก client: ตรวจชนิดข้อมูลทุกตัว + จำกัดความถี่ก่อนเสมอ
	Net.get("M1").OnServerEvent:Connect(function(player, uppercut: unknown)
		if not rateOk(player, "M1") then
			return
		end
		local state = stateOf(player)
		if state then
			doM1(state, uppercut == true)
		end
	end)

	Net.get("Block").OnServerEvent:Connect(function(player, held: unknown)
		if not rateOk(player, "Block") or typeof(held) ~= "boolean" then
			return
		end
		local state = stateOf(player)
		if state then
			setBlock(state, held :: boolean)
		end
	end)

	Net.get("Dash").OnServerEvent:Connect(function(player, dx: unknown, dz: unknown)
		if not rateOk(player, "Dash") then
			return
		end
		if typeof(dx) ~= "number" or typeof(dz) ~= "number" then
			return
		end
		if not CombatRules.isFinite(dx :: number) or not CombatRules.isFinite(dz :: number) then
			return
		end
		local state = stateOf(player)
		if state then
			doDash(state, math.clamp(dx :: number, -1, 1), math.clamp(dz :: number, -1, 1))
		end
	end)

	Net.get("Skill").OnServerEvent:Connect(function(player, slot: unknown)
		if not rateOk(player, "Skill") or not CombatRules.isValidSlot(slot, 4) then
			return
		end
		local state = stateOf(player)
		if state then
			doSkill(state, slot :: number)
		end
	end)

	Net.get("Ultimate").OnServerEvent:Connect(function(player)
		if not rateOk(player, "Ultimate") then
			return
		end
		local state = stateOf(player)
		if state then
			doUltimate(state)
		end
	end)

	Net.get("SelectCharacter").OnServerEvent:Connect(onSelect)
end

function CombatSystem.start()
	game:GetService("RunService").Heartbeat:Connect(tick)
end

return CombatSystem
