--!strict
-- แสดงเอฟเฟกต์/เสียงตามที่เซิร์ฟเวอร์ส่งมา + รับคำสั่งผลักตัวละครของตัวเอง
-- เป็นเอฟเฟกต์พื้นฐาน (กล่องสี/ตัวเลขดาเมจ) ไว้รอเปลี่ยนเป็นของจริงทีหลัง

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Config = require(Shared.Config)
local Types = require(Shared.Types)
local Velocity = require(Shared.Velocity)

local FxController = {}

local function floatText(position: Vector3, text: string, color: Color3)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = position + Vector3.new(0, 3, 0)
	anchor.Parent = workspace

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(120, 40)
	gui.AlwaysOnTop = true
	gui.Adornee = anchor
	gui.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	TweenService:Create(anchor, TweenInfo.new(0.7), { Position = anchor.Position + Vector3.new(0, 2.5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(0.7), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, 0.8)
end

local function playSound(characterId: string?, key: string?, position: Vector3?)
	if not (characterId and key) then
		return
	end
	local module = Shared.CharacterInfo:FindFirstChild(characterId)
	if not (module and module:IsA("ModuleScript")) then
		return
	end
	local info = (require :: any)(module) :: Types.CharacterInfo
	local id = info.sounds[key]
	if not id or id == "" then
		return
	end
	-- เสียงออกจากจุดที่เกิดเหตุ (ไกลไปก็เบาลง) ไม่ใช่เสียงทั้งแมพ
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = position or workspace.CurrentCamera.CFrame.Position
	anchor.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = anchor
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.RollOffMaxDistance = 80
	sound.Parent = attachment
	sound:Play()
	Debris:AddItem(anchor, 5)
end

-- หยุดอนิเมชันของตัวละครชั่วขณะ ให้ "รู้สึกว่าหมัดโดน" (hit-stop)
local function hitStop(model: Model?, duration: number)
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	local frozen: { AnimationTrack } = {}
	for _, track in animator:GetPlayingAnimationTracks() do
		track:AdjustSpeed(0)
		table.insert(frozen, track)
	end
	task.delay(duration, function()
		for _, track in frozen do
			track:AdjustSpeed(1)
		end
	end)
end

-- กล้องสั่นสั้นๆ เมื่อเราตีโดน/โดนตี (ใช้ CameraOffset ของ Humanoid ไม่ยุ่งกับสคริปต์กล้อง)
local shaking = false
local function cameraShake(strength: number)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or shaking then
		return
	end
	shaking = true
	local startedAt = os.clock()
	task.spawn(function()
		while os.clock() - startedAt < Config.Feel.ShakeTime and humanoid.Parent do
			humanoid.CameraOffset = Vector3.new((math.random() - 0.5) * strength, (math.random() - 0.5) * strength, 0)
			task.wait()
		end
		humanoid.CameraOffset = Vector3.zero
		shaking = false
	end)
end

local function onFx(payload: Types.FxPayload)
	local position = payload.position
	if payload.kind == "Hit" and position then
		floatText(position, tostring(payload.amount or ""), Color3.fromRGB(255, 220, 80))
		playSound(payload.characterId, "Hit", position)
		hitStop(payload.source, Config.Feel.HitStop)
		hitStop(payload.target, Config.Feel.HitStop)
		local localCharacter = Players.LocalPlayer.Character
		if localCharacter and (payload.source == localCharacter or payload.target == localCharacter) then
			cameraShake(Config.Feel.ShakeStrength * math.clamp((payload.amount or 5) / 10, 0.4, 1.5))
		end
	elseif payload.kind == "Blocked" and position then
		floatText(position, "BLOCK", Color3.fromRGB(120, 190, 255))
	elseif payload.kind == "Burst" and position then
		floatText(position, "BURST!", Color3.fromRGB(255, 255, 255))
	elseif payload.kind == "GuardBreak" and position then
		floatText(position, "GUARD BREAK!", Color3.fromRGB(255, 90, 90))
	elseif payload.kind == "Skill" then
		playSound(payload.characterId, payload.key, position)
	elseif payload.kind == "UltStart" and payload.source then
		playSound(payload.characterId, "UltStart", nil)
		local highlight = Instance.new("Highlight")
		highlight.Name = "UltAura"
		highlight.FillColor = Color3.fromRGB(255, 200, 60)
		highlight.FillTransparency = 0.7
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.Parent = payload.source
	elseif payload.kind == "UltEnd" and payload.source then
		local aura = payload.source:FindFirstChild("UltAura")
		if aura then
			aura:Destroy()
		end
	end
end

function FxController.start()
	Net.get("Fx").OnClientEvent:Connect(onFx)

	-- เซิร์ฟเวอร์สั่งผลัก/พุ่ง ตัวละครของเรา (client เป็นเจ้าของฟิสิกส์ตัวเอง)
	Net.get("ApplyVelocity").OnClientEvent:Connect(function(velocity: unknown, duration: unknown)
		if typeof(velocity) ~= "Vector3" or typeof(duration) ~= "number" then
			return
		end
		local character = Players.LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			Velocity.apply(root, velocity :: Vector3, duration :: number)
		end
	end)
end

return FxController
