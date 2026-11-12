--!strict
-- ความหนักแน่นของเอฟเฟกต์: กล้องสั่น แสงวาบเต็มจอ ซูมกล้องกระแทก เส้นสปีด คลื่นกระแทก
-- ใช้เป็นชั้นเสริมให้ทุกท่าอัตโนมัติจาก SkillFx (Juice.forKey) เป็นภาพอย่างเดียว ไม่มีผลต่อดาเมจ

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Lib = require(script.Parent.Lib)

local Juice = {}

local player = Players.LocalPlayer

local function camera(): Camera?
	return workspace.CurrentCamera
end

-- ความแรงตามระยะจากกล้อง: ตัวเองเต็ม ไกลจางลงจนไม่รู้สึกที่ ~90 สตัด
local function falloff(position: Vector3): number
	local cam = camera()
	if not cam then
		return 0
	end
	local dist = (cam.CFrame.Position - position).Magnitude
	return math.clamp(1 - dist / 90, 0, 1)
end

local shakeLeft = 0
local shakePower = 0
local shakeConnection: RBXScriptConnection? = nil

-- กล้องสั่น: สั่นผ่าน Humanoid.CameraOffset (ไม่ยุ่งกับสคริปต์กล้องของเกม) แรงลดลงจนหมด
function Juice.shake(power: number, seconds: number)
	if power < 0.05 then
		return
	end
	if power >= shakePower or shakeLeft <= 0 then
		shakePower = power
		shakeLeft = seconds
	end
	if shakeConnection then
		return
	end
	local total = seconds
	shakeConnection = RunService.RenderStepped:Connect(function(dt)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if shakeLeft <= 0 or not humanoid then
			if humanoid then
				humanoid.CameraOffset = Vector3.zero
			end
			if shakeConnection then
				shakeConnection:Disconnect()
				shakeConnection = nil
			end
			return
		end
		shakeLeft -= dt
		total = math.max(total, shakeLeft)
		local amount = shakePower * math.clamp(shakeLeft / math.max(total, 0.01), 0, 1)
		humanoid.CameraOffset = Vector3.new(
			(math.random() - 0.5) * amount,
			(math.random() - 0.5) * amount,
			(math.random() - 0.5) * amount * 0.4
		)
	end)
end

-- ซูมกล้องกระแทก (FOV เพิ่มแล้วคืน) จำค่าเดิมครั้งเดียวตอนเริ่ม กันค่า FOV ลอยเมื่อซ้อนกันหลายครั้ง
local baseFov: number? = nil
local fovToken = 0

function Juice.punchFov(extra: number, seconds: number)
	local cam = camera()
	if not cam then
		return
	end
	if baseFov == nil then
		baseFov = cam.FieldOfView
	end
	local base = baseFov :: number
	fovToken += 1
	local token = fovToken
	cam.FieldOfView = base + extra
	TweenService
		:Create(cam, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = base })
		:Play()
	task.delay(seconds + 0.05, function()
		if token == fovToken then
			baseFov = nil -- จบการกระแทกล่าสุดแล้ว รอบหน้าอ่านค่าใหม่
		end
	end)
end

-- แสงวาบเต็มจอ
function Juice.flash(color: Color3, alpha: number, seconds: number)
	local gui = player:FindFirstChildOfClass("PlayerGui")
	if not gui then
		return
	end
	local screen = Instance.new("ScreenGui")
	screen.Name = "FxFlash"
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 50
	screen.ResetOnSpawn = false
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 1 - alpha
	frame.BorderSizePixel = 0
	frame.Parent = screen
	screen.Parent = gui
	TweenService:Create(
		frame,
		TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	):Play()
	Debris:AddItem(screen, seconds + 0.1)
end

-- เส้นสปีดพุ่งผ่านตามทิศ forward รอบตัว (ท่าพุ่ง/ท่าหนัก)
function Juice.speedLines(root: BasePart, color: Color3, count: number?, length: number?)
	local n = count or 16
	local len = length or 14
	local forward = root.CFrame.LookVector
	local origin = root.Position
	for i = 1, n do
		local angle = (i / n) * math.pi * 2 + math.random() * 0.4
		local radius = 3 + math.random() * 5
		local side = root.CFrame.RightVector * math.cos(angle) * radius
			+ root.CFrame.UpVector * math.sin(angle) * radius
		local start = origin + side + forward * (4 + math.random() * 10)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = if i % 3 == 0 then Color3.new(1, 1, 1) else color
		part.Transparency = 0.15
		part.Size = Vector3.new(0.12, 0.12, len * (0.6 + math.random() * 0.6))
		part.CFrame = CFrame.lookAt(start, start - forward)
		part.Parent = workspace
		local life = 0.25 + math.random() * 0.15
		TweenService:Create(part, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = part.CFrame * CFrame.new(0, 0, len * 1.6),
			Transparency = 1,
			Size = Vector3.new(0.02, 0.02, part.Size.Z * 1.5),
		}):Play()
		Debris:AddItem(part, life + 0.1)
	end
end

-- คลื่นกระแทกทรงโดมครึ่งวงกลม + วงขยายบนพื้น + เศษหินกระเด็น
function Juice.shockwave(ground: Vector3, color: Color3, radius: number)
	local dome = Instance.new("Part")
	dome.Anchored = true
	dome.CanCollide = false
	dome.CanQuery = false
	dome.CanTouch = false
	dome.CastShadow = false
	dome.Shape = Enum.PartType.Ball
	dome.Material = Enum.Material.Neon
	dome.Color = color
	dome.Transparency = 0.45
	dome.Size = Vector3.one * radius * 0.3
	dome.Position = ground
	dome.Parent = workspace
	TweenService:Create(
		dome,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.one * radius * 2, Transparency = 1 }
	):Play()
	Debris:AddItem(dome, 0.45)
	Lib.ring(ground + Vector3.new(0, 0.2, 0), color, radius * 1.3, 0.45)
	Lib.ring(ground + Vector3.new(0, 0.2, 0), Color3.new(1, 1, 1), radius * 0.9, 0.3)
	-- เศษหินกระเด็นขึ้น
	for _ = 1, 10 do
		local rock = Instance.new("Part")
		rock.Anchored = true
		rock.CanCollide = false
		rock.CanQuery = false
		rock.CanTouch = false
		rock.CastShadow = false
		rock.Material = Enum.Material.Slate
		rock.Color = Color3.fromRGB(110, 100, 90)
		rock.Size = Vector3.one * (0.6 + math.random() * 1.0)
		local angle = math.random() * math.pi * 2
		local dist = radius * (0.3 + math.random() * 0.7)
		local start = ground + Vector3.new(math.cos(angle) * dist, 0.5, math.sin(angle) * dist)
		rock.CFrame = CFrame.new(start) * CFrame.Angles(math.random() * 3, math.random() * 3, 0)
		rock.Parent = workspace
		local life = 0.6 + math.random() * 0.3
		TweenService:Create(rock, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(start + Vector3.new(0, 4 + math.random() * 5, 0))
				* CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6),
			Transparency = 1,
		}):Play()
		Debris:AddItem(rock, life + 0.1)
	end
end

-- ระดับความแรงของแต่ละคีย์ท่า: 1 = เบา 2 = กลาง 3 = หนัก 4 = อันติ/แปลงร่าง
local function tierOf(key: string): number
	if key == "UltStart" then
		return 4
	end
	if key:match("^M1_[12]$") then
		return 1
	end
	if key:match("^M1_") then
		return 2
	end
	if key:match("Charge$") or key:match("Anchor$") or key:match("Miss$") or key == "Dash" then
		return 0
	end
	if key:match("^Ult") then
		return 3
	end
	if key == "Skill4" or key == "Skill2Hit" or key == "Skill3Hit" then
		return 3
	end
	if key == "Skill4Aura" or key:match("^Skill3Fire") then
		return 3
	end
	if key:match("^Skill2Punch") then
		return if key:match("4$") then 2 else 1
	end
	if key:match("^Skill2Connect") then
		return 1
	end
	return 2
end

-- เรียกก่อนตัวจัดการเอฟเฟกต์ของตัวละคร: เติมความหนักแน่นตามระดับของท่า
function Juice.forKey(key: string, root: BasePart, tint: Color3)
	local tier = tierOf(key)
	if tier <= 0 then
		return
	end
	local power = falloff(root.Position)
	local isSelf = root.Parent ~= nil and root.Parent == player.Character
	if isSelf then
		power = math.max(power, 0.8)
	end
	if power <= 0.05 then
		return
	end
	if tier == 1 then
		Juice.shake(0.12 * power, 0.12)
	elseif tier == 2 then
		Juice.shake(0.3 * power, 0.2)
		Juice.punchFov(3 * power, 0.2)
		Juice.speedLines(root, tint, 8, 10)
	elseif tier == 3 then
		Juice.shake(0.8 * power, 0.45)
		Juice.punchFov(8 * power, 0.35)
		Juice.speedLines(root, tint, 18, 16)
		if isSelf then
			Juice.flash(tint, 0.25 * power, 0.25)
		end
	else
		Juice.shake(1.4 * power, 0.9)
		Juice.punchFov(14 * power, 0.6)
		Juice.speedLines(root, tint, 26, 18)
		if isSelf then
			Juice.flash(Color3.new(1, 1, 1), 0.55 * power, 0.6)
		end
		Juice.shockwave(root.Position - Vector3.new(0, 2.5, 0), tint, 16)
	end
end

return Juice
