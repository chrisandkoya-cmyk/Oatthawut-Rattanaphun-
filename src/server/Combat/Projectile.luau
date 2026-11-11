--!strict
-- กระสุนพลังที่จำลองบนเซิร์ฟเวอร์ (ตรวจชนด้วย Spherecast ทุกเฟรม)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)
local State = require(script.Parent.State)
local Damage = require(script.Parent.Damage)
local Hitbox = require(script.Parent.Hitbox)

local Projectile = {}

local folder = Instance.new("Folder")
folder.Name = "Projectiles"
folder.Parent = workspace

local MAX_LIFETIME = 10 -- วินาที กันกระสุนค้าง

function Projectile.fire(state: State.CombatState, options: Types.ProjectileOptions)
	local direction = options.direction or state.root.CFrame.LookVector
	if direction.Magnitude < 1e-3 then
		return
	end
	direction = direction.Unit
	local speed = math.clamp(options.speed, 1, 500)
	local range = math.clamp(options.range, 1, 1000)
	local radius = math.clamp(options.radius, 0.2, 20)

	local position = state.root.Position + direction * 2

	local part = Instance.new("Part")
	part.Name = "Projectile"
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = options.color or Color3.fromRGB(120, 200, 255)
	part.Size = Vector3.one * radius * 2
	part.CFrame = CFrame.new(position)
	part.Parent = folder

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { state.model, folder }

	local travelled = 0
	local started = os.clock()
	local connection: RBXScriptConnection? = nil

	local function finish()
		if connection then
			connection:Disconnect()
			connection = nil
		end
		part:Destroy()
	end

	connection = RunService.Heartbeat:Connect(function(dt)
		if os.clock() - started > MAX_LIFETIME then
			finish()
			return
		end
		local step = math.min(speed * dt, range - travelled)
		local result = workspace:Spherecast(position, radius, direction * step, params)
		if result then
			local model = Hitbox.findCharacter(result.Instance)
			if model then
				Damage.apply(state, model, options.hit, position)
				if options.pierce then
					params:AddToFilter(model)
				else
					finish()
					return
				end
			else
				finish() -- ชนกำแพง/พื้น
				return
			end
		end
		position += direction * step
		travelled += step
		part.CFrame = CFrame.new(position)
		if travelled >= range then
			finish()
		end
	end)
end

return Projectile
