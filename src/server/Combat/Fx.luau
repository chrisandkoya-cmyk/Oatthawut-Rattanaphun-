--!strict
-- ส่งเอฟเฟกต์/เสียง/อนิเมชัน ให้ client ทุกคน (ไม่มีผลต่อเกมเพลย์)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local State = require(script.Parent.State)

local Fx = {}

local fxRemote = Net.get("Fx")
local velocityRemote = Net.get("ApplyVelocity")
local Velocity = require(Shared.Velocity)

function Fx.emit(payload: Types.FxPayload)
	fxRemote:FireAllClients(payload)
end

-- ผลัก/พุ่งตัวละคร: ผู้เล่นให้ client เจ้าของทำ, หุ่นทำบนเซิร์ฟเวอร์
function Fx.push(model: Model, velocity: Vector3, duration: number)
	local Players = game:GetService("Players")
	local player = Players:GetPlayerFromCharacter(model)
	if player then
		velocityRemote:FireClient(player, velocity, duration)
	else
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			Velocity.apply(root, velocity, duration)
		end
	end
end

-- เล่นอนิเมชันบนเซิร์ฟเวอร์ (replicate ให้ทุกคน) id มาจาก CharacterInfo
local infoFolder = Shared:WaitForChild("CharacterInfo")

function Fx.anim(state: State.CombatState, key: string)
	local cached = state.animTracks[key]
	if cached then
		cached:Play()
		return
	end
	local infoModule = infoFolder:FindFirstChild(state.characterId)
	if not (infoModule and infoModule:IsA("ModuleScript")) then
		return
	end
	local info = (require :: any)(infoModule) :: Types.CharacterInfo
	local id = info.animations[key]
	if not id or id == "" then
		return
	end
	local animator = state.humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = id
	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if ok and track then
		state.animTracks[key] = track
		track:Play()
	end
end

return Fx
