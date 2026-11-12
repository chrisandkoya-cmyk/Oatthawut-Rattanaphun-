--!strict
-- ตัวละคร "โซลวาน" (ชื่อที่แสดงชั่วคราวคือโกคู ดู CharacterInfo/Solvan) สายหมัด ยิงพลังแสง
-- ไฟล์นี้มีแค่ตัวเลขและโค้ดสกิล ชื่อ/สี/เสียงอยู่ใน Shared/CharacterInfo/Solvan
-- คีย์ ctx.fx: Skill1..4 = ตอนเริ่มท่า, ...Charge/...Hit = จังหวะระหว่างท่า, Ult1..4 = ท่าร่างอันติ

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)
local Reach = require(script.Parent.Parent.Combat.Reach)

local BEAM_COLOR = Color3.fromRGB(63, 200, 224)

-- ไคโอเคน: เก็บเวลาหมดบัพของตัวละครแต่ละตัว (ฝั่งเซิร์ฟเวอร์ล้วน ตัวละครใหม่/ตายแล้วบัพหาย)
local KAIOKEN_SECONDS = 10
local KAIOKEN_DAMAGE = 1.3
local kaioken: { [Model]: number } = setmetatable({}, { __mode = "k" }) :: any

local function kaiokenOn(ctx: Types.SkillContext): boolean
	local untilTime = kaioken[ctx.character]
	return untilTime ~= nil and untilTime > os.clock()
end

local function scaled(ctx: Types.SkillContext, damage: number): number
	return if kaiokenOn(ctx) then damage * KAIOKEN_DAMAGE else damage
end

local function rotated(direction: Vector3, degrees: number): Vector3
	return (CFrame.Angles(0, math.rad(degrees), 0) * direction)
end

-- เป้าที่ใกล้ที่สุดในกล่อง (ใช้กับท่าวาร์ป)
local function nearest(ctx: Types.SkillContext, size: Vector3): Model?
	local best: Model? = nil
	local bestDistance = math.huge
	for _, model in ctx.hitbox({ size = size, offset = 0 }) do
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			local distance = (root.Position - ctx.root.Position).Magnitude
			if distance < bestDistance then
				best, bestDistance = model, distance
			end
		end
	end
	return best
end

local kit: Types.CharacterKit = {
	id = "Solvan",
	stats = { maxHealth = 100, walkSpeed = 16 },

	skills = {
		-- 1: พุ่งประชิด พุ่งเข้าหาเป้าที่อยู่ข้างหน้า (สูงสุด 24 สตัด) แล้วต่อยสวนทันที
		{
			cooldown = 7,
			castTime = 0.5,
			run = function(ctx)
				local kai = kaiokenOn(ctx)
				ctx.anim("Skill1")
				ctx.fx(kai and "Skill1Kai" or "Skill1")
				-- หยุดก่อนถึงเป้า ~3.5 สตัด ไม่พุ่งทะลุเข้าไปซ้อนกับตัวเป้า
				local reach = kai and 24 or 20
				local target = nearest(ctx, Vector3.new(10, 8, reach + 8))
				local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
				if targetRoot and targetRoot:IsA("BasePart") then
					local toTarget = (targetRoot.Position - ctx.root.Position) * Vector3.new(1, 0, 1)
					if toTarget.Magnitude > 0.1 and toTarget.Unit:Dot(ctx.forward()) > 0.5 then
						reach = math.clamp(toTarget.Magnitude - 3.5, 0, reach)
					end
				end
				ctx.impulse(ctx.forward() * (reach / 0.2), 0.2)
				if not ctx.wait(0.2) then
					return
				end
				local hits = ctx.hitArea(
					{ size = Vector3.new(7, 6, 8), offset = 4 },
					{ damage = scaled(ctx, 8), stun = 0.5, knockback = 8 }
				)
				if hits > 0 then
					ctx.fx(kai and "Skill1HitKai" or "Skill1Hit")
				end
			end,
		},
		-- 2: หมัดรัวคอมโบ ต่อย 4 ครั้งติด (3+3+3+6) ก้าวเข้าใส่ทุกหมัด หมัดสุดท้ายซัดกระเด็น
		{
			cooldown = 9,
			castTime = 1.0,
			run = function(ctx)
				local kai = kaiokenOn(ctx)
				ctx.anim("Skill2")
				for i = 1, 4 do
					local last = i == 4
					ctx.fx((kai and "Skill2PunchKai" or "Skill2Punch") .. (last and "4" or tostring(i % 2 + 1)))
					ctx.impulse(ctx.forward() * 30, 0.1)
					if not ctx.wait(0.12) then
						return
					end
					local hits = ctx.hitArea(
						{ size = Vector3.new(6, 6, 7), offset = 3.5 },
						last and { damage = scaled(ctx, 6), stun = 0.8, knockback = 34, knockbackUp = 8 }
							or { damage = scaled(ctx, 3), stun = 0.35, knockback = 2 }
					)
					if hits > 0 then
						ctx.fx(kai and "Skill2ConnectKai" or "Skill2Connect")
					end
					if not ctx.wait(last and 0.1 or 0.13) then
						return
					end
				end
			end,
		},
		-- 3: คาเมฮาเมฮา ชาร์จ 1 วินาที (โดนขัดได้) แล้วยิงลำแสงตรง ยาว 60 สตัด
		{
			cooldown = 16,
			castTime = 1.5,
			run = function(ctx)
				local kai = kaiokenOn(ctx)
				ctx.anim("Skill3")
				ctx.fx(kai and "Skill3ChargeKai" or "Skill3Charge")
				if not ctx.wait(1.0) then
					return
				end
				ctx.fx(kai and "Skill3Kai" or "Skill3")
				ctx.hitArea(
					Reach.line(ctx, kai and 7 or 5, kai and 7 or 5, kai and 72 or 60),
					{ damage = scaled(ctx, 22), stun = 1.0, knockback = 40, knockbackUp = 6 }
				)
			end,
		},
		-- 4: ไคโอเคน (ตัวแดง) บัพ 10 วินาที: สกิลอื่นดาเมจ +30% พุ่งไกลขึ้น คาเมฮาเมฮากว้างและไกลขึ้น
		{
			cooldown = 22,
			castTime = 0.6,
			run = function(ctx)
				ctx.anim("Skill4")
				ctx.fx("Skill4")
				if not ctx.wait(0.4) then
					return
				end
				kaioken[ctx.character] = os.clock() + KAIOKEN_SECONDS
				ctx.fx("Skill4Aura")
			end,
		},
	},

	ultimate = {
		duration = 30,
		m1DamageMultiplier = 1.2, -- เอกสารกำหนด M1 +20% ตอนอันติ (damageMultiplier คูณเฉพาะสกิล)
		skills = {
			-- 1: ฝนดาวตก ยิง 8 ลูกแบบกระจาย (3 x 8) ยังไม่ตามเป้า
			{
				cooldown = 6,
				castTime = 0.8,
				run = function(ctx)
					ctx.anim("Ult1")
					ctx.fx("Ult1")
					if not ctx.wait(0.2) then
						return
					end
					for i = 1, 8 do
						local angle = -21 + (i - 1) * 6
						ctx.projectile({
							speed = 90,
							range = 50,
							radius = 0.8,
							color = BEAM_COLOR,
							direction = rotated(ctx.forward(), angle),
							hit = { damage = 3, stun = 0.3, knockback = 4 },
						})
					end
				end,
			},
			-- 2: วาร์ปไปหลังศัตรูในระยะ 25 สตัด (ทิ้งเงาหลอกที่จุดเดิม) แล้วศอกทันที
			{
				cooldown = 7,
				castTime = 0.5,
				run = function(ctx)
					ctx.anim("Ult2")
					local target = nearest(ctx, Vector3.new(50, 14, 50))
					local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
					if not (target and targetRoot and targetRoot:IsA("BasePart")) then
						return
					end
					local from = ctx.root.Position
					local destination = targetRoot.Position - targetRoot.CFrame.LookVector * 3
					if not ctx.teleport(destination, 25) then
						return
					end
					ctx.root.CFrame = CFrame.lookAt(
						ctx.root.Position,
						targetRoot.Position * Vector3.new(1, 0, 1) + Vector3.new(0, ctx.root.Position.Y, 0)
					)
					ctx.fx("Ult2", from) -- เงาหลอกที่จุดเดิม
					ctx.fx("Ult2In")
					if not ctx.wait(0.1) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(6, 6, 6), offset = 3 },
						{ damage = 12, stun = 0.6, knockback = 10 }
					)
				end,
			},
			-- 3: ระเบิดแสงรอบตัวรัศมี 12 สตัด ดันทุกคนออก
			{
				cooldown = 12,
				castTime = 0.6,
				run = function(ctx)
					ctx.anim("Ult3")
					ctx.fx("Ult3Charge")
					if not ctx.wait(0.3) then
						return
					end
					ctx.fx("Ult3")
					ctx.hitArea(
						{ size = Vector3.new(24, 10, 24), offset = 0 },
						{ damage = 14, stun = 1.0, knockback = 55, knockbackUp = 10 }
					)
				end,
			},
			-- 4: ปืนใหญ่เที่ยงวัน ลำแสงกว้าง 8 สตัด ยิง 2 วินาที เดินไม่ได้ ใช้ได้ 1 ครั้งต่อร่าง (รวม 28)
			{
				cooldown = 1,
				usesPerForm = 1,
				movementLock = true,
				castTime = 3.0,
				run = function(ctx)
					ctx.anim("Ult4")
					ctx.fx("Ult4Charge")
					if not ctx.wait(0.7) then
						return
					end
					ctx.fx("Ult4")
					for _ = 1, 8 do
						ctx.hitArea(Reach.line(ctx, 8, 8, 70), { damage = 3.5, stun = 0.3, knockback = 4 })
						if not ctx.wait(0.25) then
							return
						end
					end
				end,
			},
		},
	},
}

return kit
