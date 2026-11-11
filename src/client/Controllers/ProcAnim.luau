--!strict
-- เล่นท่าทางด้วยโค้ด (Shared/Poses) ตามที่เซิร์ฟเวอร์ส่งมาทาง Fx (kind = "Skill")
-- ขยับข้อต่อ R15 (Motor6D หรือ AnimationConstraint) ของตัวละครทุกตัวที่เห็น ทุกเครื่องเล่นเองจึงตรงกัน (เป็นภาพอย่างเดียว ไม่มีผลต่อดาเมจ)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local Poses = require(Shared.Poses)

local BLEND_IN = 0.06 -- วินาทีที่ค่อยๆ เข้าท่า (กันกระตุก)
local BLEND_OUT = 0.15 -- วินาทีที่ค่อยๆ กลับท่าปกติหลังจบท่า

-- R15 รุ่นเก่าใช้ Motor6D, รุ่นใหม่ใน Studio ใช้ AnimationConstraint ต้องรองรับทั้งสองแบบ
type Joint = Motor6D | AnimationConstraint

type Playing = {
	clip: Poses.Clip,
	startedAt: number,
	joints: { [string]: Joint },
	baseC0: { [string]: CFrame },
}

local ProcAnim = {}

local playing: { [Model]: Playing } = {}

local function isJoint(instance: Instance?): boolean
	return instance ~= nil and (instance:IsA("Motor6D") or instance:IsA("AnimationConstraint"))
end

local function findJoints(model: Model, clip: Poses.Clip): { [string]: Joint }
	local joints: { [string]: Joint } = {}
	for _, frame in clip do
		for name in frame.pose do
			if not joints[name] then
				local joint = model:FindFirstChild(name, true)
				if joint and isJoint(joint) then
					joints[name] = joint :: Joint
				end
			end
		end
	end
	if not joints.Root then
		local root = model:FindFirstChild("Root", true)
		if root and isJoint(root) then
			joints.Root = root :: Joint
		end
	end
	return joints
end

-- ขยับผ่าน C0 (เสริมจากค่าเดิม) แทน Transform เพราะ Animator เขียนทับ Transform ทุกเฟรม แต่ไม่แตะ C0
local function baseOf(joints: { [string]: Joint }): { [string]: CFrame }
	local base: { [string]: CFrame } = {}
	for name, joint in joints do
		if joint:IsA("Motor6D") then
			base[name] = joint.C0
		end
	end
	return base
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
	for name, joint in entry.joints do
		if joint:IsA("AnimationConstraint") then
			joint.Transform = CFrame.new()
		else
			joint.C0 = entry.baseC0[name]
		end
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
		local fade = if t > end_ then 1 - (t - end_) / BLEND_OUT else math.min(t / BLEND_IN, 1)
		for name, joint in entry.joints do
			local rotation = pose[name] or Vector3.zero
			local cframe = angles(rotation)
			if name == "Root" then
				cframe = CFrame.new(move) * cframe
			end
			local blended = CFrame.new():Lerp(cframe, fade)
			if joint:IsA("AnimationConstraint") then
				joint.Transform = blended
			else
				joint.C0 = entry.baseC0[name] * blended
			end
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
	local joints = findJoints(model, clip)
	playing[model] = { clip = clip, startedAt = os.clock(), joints = joints, baseC0 = baseOf(joints) }
end

function ProcAnim.start()
	Net.get("Fx").OnClientEvent:Connect(onFx)
	-- PreSimulation รันหลังขั้นอนิเมชัน จึงทับท่าเดิน/ยืนของสคริปต์ Animate ได้ (RenderStepped อยู่ก่อน)
	RunService.PreSimulation:Connect(step)
end

return ProcAnim
