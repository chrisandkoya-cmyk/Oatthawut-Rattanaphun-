--!strict
-- หุ่นซ้อมสำหรับเทสใน Studio เท่านั้น (ไม่สร้างในเกมจริง)
-- หุ่น 2 ตัว: ตัวหนึ่งยืนเฉยๆ อีกตัวบล็อกตลอด

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local Combat = ServerScriptService:WaitForChild("Server"):WaitForChild("Combat")
local Kits = require(Combat.Kits)
local State = require(Combat.State)

local Dummies = {}

local function build(name: string, position: Vector3, alwaysBlock: boolean)
	local description = Instance.new("HumanoidDescription")
	local ok, model = pcall(function()
		return game:GetService("Players"):CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok then
		warn("[Dummies] สร้างหุ่นไม่ได้: " .. tostring(model))
		return
	end
	local dummy = model :: Model
	dummy.Name = name
	dummy:PivotTo(CFrame.new(position))
	dummy.Parent = workspace

	local kit = Kits.get(Config.DefaultCharacter)
	if not kit then
		return
	end
	local Systems = ServerScriptService.Server.Systems
	local CombatSystem = require(Systems.Combat)
	local state = CombatSystem.register(dummy, kit, nil)
	if state then
		state.alwaysBlock = alwaysBlock
	end

	-- หุ่นตายแล้วเกิดใหม่ที่เดิม
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			task.wait(3)
			State.remove(dummy)
			dummy:Destroy()
			build(name, position, alwaysBlock)
		end)
	end
end

function Dummies.start()
	if not (Config.Debug.SpawnDummies and RunService:IsStudio()) then
		return
	end
	local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
	local base = spawn and spawn.Position or Vector3.new(0, 5, 0)
	build("Dummy_Idle", base + Vector3.new(10, 3, 0), false)
	build("Dummy_Blocker", base + Vector3.new(-10, 3, 0), true)
end

return Dummies
