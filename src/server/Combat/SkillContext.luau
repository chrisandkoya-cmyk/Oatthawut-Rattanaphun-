--!strict
-- สร้าง ctx ที่ส่งให้ฟังก์ชันสกิลของตัวละคร
-- สกิลใช้แค่ฟังก์ชันใน ctx ก็พอ ไม่ต้องรู้รายละเอียดระบบ

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)
local State = require(script.Parent.State)
local Hitbox = require(script.Parent.Hitbox)
local Damage = require(script.Parent.Damage)
local Projectile = require(script.Parent.Projectile)
local Fx = require(script.Parent.Fx)
local Movement = require(script.Parent.Movement)

local SkillContext = {}

local function boxCFrame(state: State.CombatState, options: Types.HitboxOptions): CFrame
	return options.cframe or Hitbox.inFront(state.root, options.offset or 0)
end

function SkillContext.new(state: State.CombatState): Types.SkillContext
	local token = state.actionToken

	local function isActive(): boolean
		return State.isAlive(state) and state.actionToken == token and not State.isStunned(state)
	end

	local ctx: Types.SkillContext = {
		player = state.player,
		character = state.model,
		humanoid = state.humanoid,
		root = state.root,
		characterId = state.characterId,
		inUltimate = state.inUltimate,

		wait = function(seconds: number): boolean
			task.wait(math.clamp(seconds, 0, 10))
			return isActive()
		end,

		isActive = isActive,

		forward = function(): Vector3
			return state.root.CFrame.LookVector
		end,

		hitbox = function(options: Types.HitboxOptions): { Model }
			return Hitbox.query(state.model, boxCFrame(state, options), options.size)
		end,

		damage = function(target: Model, info: Types.DamageInfo): Types.HitResult
			if not isActive() then
				return "Miss"
			end
			return Damage.apply(state, target, info)
		end,

		hitArea = function(options: Types.HitboxOptions, info: Types.DamageInfo): number
			if not isActive() then
				return 0
			end
			local count = 0
			for _, target in Hitbox.query(state.model, boxCFrame(state, options), options.size) do
				local result = Damage.apply(state, target, info)
				if result ~= "Miss" then
					count += 1
				end
			end
			return count
		end,

		projectile = function(options: Types.ProjectileOptions)
			if isActive() then
				Projectile.fire(state, options)
			end
		end,

		impulse = function(velocity: Vector3, duration: number?)
			if isActive() then
				Fx.push(state.model, velocity, math.clamp(duration or 0.2, 0, 2))
			end
		end,

		fx = function(key: string, position: Vector3?)
			Fx.emit({
				kind = "Skill",
				key = key,
				characterId = state.characterId,
				source = state.model,
				position = position or state.root.Position,
			})
		end,

		anim = function(key: string)
			Fx.anim(state, key)
		end,

		teleport = function(destination: Vector3, maxDistance: number): boolean
			if not isActive() or typeof(destination) ~= "Vector3" then
				return false
			end
			local safe = Movement.safeDestination(state.model, state.root.Position, destination, maxDistance)
			if not safe then
				return false
			end
			Movement.moveTo(state.model, safe)
			return true
		end,

		pull = function(target: Model, maxDistance: number): boolean
			if not isActive() or target == state.model then
				return false
			end
			local targetRoot = target:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
			if not (targetRoot and targetRoot:IsA("BasePart")) or not targetHumanoid or targetHumanoid.Health <= 0 then
				return false
			end
			if target:FindFirstChildOfClass("ForceField") then
				return false
			end
			local from = targetRoot.Position
			if (from - state.root.Position).Magnitude > math.clamp(maxDistance, 0, 100) + 0.5 then
				return false
			end
			local front = state.root.Position + state.root.CFrame.LookVector * 4
			local safe = Movement.safeDestination(target, from, front, 100)
			if not safe then
				return false
			end
			Movement.moveTo(target, safe, -state.root.CFrame.LookVector)
			return true
		end,
	}
	return ctx
end

return SkillContext
