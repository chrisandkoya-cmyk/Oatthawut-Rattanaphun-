--!strict
-- เล่นท่าทางด้วยโค้ด (Shared/Poses) ตามที่เซิร์ฟเวอร์ส่งมาทาง Fx (kind = "Skill")
-- ขยับ Motor6D.Transform ของตัวละครทุกตัวที่เห็น ทุกเครื่องเล่นเองจึงตรงกัน (เป็นภาพอย่างเดียว ไม่มีผลต่อดาเมจ)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local Poses = require(Shared.Poses)

local BLEND_OUT = 0.15 -- วินาทีที่ค่อยๆ กลับท่าปกติหลังจบท่า

type Playing = {
	clip: Poses.Clip,
	startedAt: number,
	joints: { [string]: Motor6D },
}

local ProcAnim = {}

local playing: { [Model]: Playing } = {}

local function findJoints(model: Model, clip: Poses.Clip): { [string]: Motor6D }
	local joints: { [string]: Motor6D } = {}
	for _, frame in clip do
		for name in frame.pose do
			if not joints[name] then
				local joint = model:FindFirstChild(name, true)
				if joint and joint:IsA("Motor6D") then
					joints[name] = joint
				end
			end
		end
	end
	if not joints.Root then
		local root = model:FindFirstChild("Root", true)
		if root and root:IsA("Motor6D") then
			joints.Root = root
		end
	end
	return joints
end

local function ease(alpha: number): number
	return 1 - (1 - alpha) * (1 - alpha)
end

local function angles(rotation: Vector3): CFrame
	return CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
end

-- คืนมุมของแต่ละข้อต่อ ณ เวลา t (ข้อต่อที่ไม่ได้ใส่ในเฟรม = ท่านิ่ง) และการขยับลำตัว
local function sample(clip: Poses.Clip, t: number): ({ [string]: Vector3 }, Vector3)
	local last = clip[#clip]
	if t >= last.t then
		return last.pose, last.move or Vector3.zero
	end
	local a = clip[1]
	local b = clip[1]
	for i = 1, #clip - 1 do
		if t >= clip[i].t and t < clip[i + 1].t then
			a, b = clip[i], clip[i + 1]
			break
		end
	end
	local span = b.t - a.t
	local alpha = if span > 0 then ease((t - a.t) / span) else 1
	local result: { [string]: Vector3 } = {}
	for name, rotation in a.pose do
		result[name] = rotation:Lerp(b.pose[name] or Vector3.zero, alpha)
	end
	for name, rotation in b.pose do
		if not a.pose[name] then
			result[name] = Vector3.zero:Lerp(rotation, alpha)
		end
	end
	return result, (a.move or Vector3.zero):Lerp(b.move or Vector3.zero, alpha)
end

local function reset(entry: Playing)
	for _, joint in entry.joints do
		joint.Transform = CFrame.new()
	end
end

local function step()
	local now = os.clock()
	for model, entry in playing do
		if not model.Parent then
			playing[model] = nil
			continue
		end
		local clip = entry.clip
		local t = now - entry.startedAt
		local end_ = clip[#clip].t
		if t >= end_ + BLEND_OUT then
			reset(entry)
			playing[model] = nil
			continue
		end
		local pose, move = sample(clip, math.min(t, end_))
		local fade = if t > end_ then 1 - (t - end_) / BLEND_OUT else 1
		for name, joint in entry.joints do
			local rotation = pose[name] or Vector3.zero
			local cframe = angles(rotation)
			if name == "Root" then
				cframe = CFrame.new(move) * cframe
			end
			joint.Transform = CFrame.new():Lerp(cframe, fade)
		end
	end
end

local function onFx(payload: Types.FxPayload)
	if payload.kind ~= "Skill" or not (payload.key and payload.characterId and payload.source) then
		return
	end
	local model = payload.source
	local clip = Poses.get(payload.characterId, payload.key)
	if not clip or #clip == 0 then
		return
	end
	local previous = playing[model]
	if previous then
		reset(previous)
	end
	playing[model] = { clip = clip, startedAt = os.clock(), joints = findJoints(model, clip) }
end

function ProcAnim.start()
	Net.get("Fx").OnClientEvent:Connect(onFx)
	RunService.RenderStepped:Connect(step)
end

return ProcAnim
