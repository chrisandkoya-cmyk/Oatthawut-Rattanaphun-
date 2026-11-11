--!strict
-- ตัวละคร "แบรม" (ชื่อที่แสดงชั่วคราวคือลูฟี่ ดู CharacterInfo/Bram) สายร่างยางยืด
-- ไฟล์นี้มีแค่ตัวเลขและโค้ดสกิล ชื่อ/สี/เสียงอยู่ใน Shared/CharacterInfo/Bram

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)

local function firstTarget(ctx: Types.SkillContext, size: Vector3, offset: number): Model?
	local best: Model? = nil
	local bestDistance = math.huge
	for _, model in ctx.hitbox({ size = size, offset = offset }) do
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
	id = "Bram",
	stats = { maxHealth = 100, walkSpeed = 16 },

	-- M1 จังหวะ 4 แขนยืดต่อยไกลกว่า แต่กระเด็นน้อยกว่าโซลวาน
	m1 = { hitboxSize = Vector3.new(5, 5, 7), finalKnockback = 6 },

	skills = {
		-- 1: ดึงแขนไปข้างหลังแล้วปล่อยหมัดยืดไกล 30 สตัด
		{
			cooldown = 6,
			castTime = 0.5,
			run = function(ctx)
				ctx.anim("Skill1")
				ctx.fx("Skill1Charge")
				if not ctx.wait(0.25) then
					return
				end
				ctx.fx("Skill1")
				ctx.hitArea({ size = Vector3.new(3, 3, 30), offset = 15 }, { damage = 9, stun = 0.6, knockback = 25 })
			end,
		},
		-- 2: ยืดมือคว้าศัตรูในระยะ 25 สตัด ดึงเข้ามาหน้าตัว บล็อกไม่ได้
		{
			cooldown = 10,
			castTime = 0.6,
			run = function(ctx)
				ctx.anim("Skill2")
				ctx.fx("Skill2")
				if not ctx.wait(0.15) then
					return
				end
				local target = firstTarget(ctx, Vector3.new(4, 4, 25), 12.5)
				if not target then
					ctx.fx("Skill2Miss")
					return
				end
				ctx.fx("Skill2Hit")
				ctx.damage(target, { damage = 6, stun = 0.8, blockable = false })
				ctx.pull(target, 25)
			end,
		},
		-- 3: หมุนแขนยืดรอบตัวรัศมี 10 สตัด 1.5 วินาที (5 x 3)
		{
			cooldown = 12,
			castTime = 1.6,
			run = function(ctx)
				ctx.anim("Skill3")
				ctx.fx("Skill3")
				for _ = 1, 3 do
					if not ctx.wait(0.45) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(20, 6, 20), offset = 0 },
						{ damage = 5, stun = 0.5, knockback = 15 }
					)
				end
			end,
		},
		-- 4: ยืดแขนเกาะตัวศัตรูในระยะ 20 สตัด หดตัวเองพุ่งเข้าไปอัดหมัดเดียว
		{
			cooldown = 16,
			castTime = 1.2,
			run = function(ctx)
				ctx.anim("Skill4")
				ctx.fx("Skill4Anchor")
				if not ctx.wait(0.3) then
					return
				end
				local target = firstTarget(ctx, Vector3.new(5, 5, 20), 10)
				local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
				if not (targetRoot and targetRoot:IsA("BasePart")) then
					ctx.fx("Skill4Miss")
					return
				end
				ctx.fx("Skill4")
				local direction = (targetRoot.Position - ctx.root.Position) * Vector3.new(1, 0, 1)
				if direction.Magnitude > 0.1 then
					ctx.impulse(direction.Unit * 90, 0.2)
				end
				if not ctx.wait(0.25) then
					return
				end
				ctx.hitArea(
					{ size = Vector3.new(6, 6, 6), offset = 3 },
					{ damage = 20, stun = 1.0, knockback = 20, knockbackUp = 8 }
				)
			end,
		},
	},

	ultimate = {
		duration = 30,
		walkSpeedMultiplier = 1.25,
		damageMultiplier = 1.2,
		skills = {
			-- 1: หมัดเกลียวต่อเนื่อง 12 จังหวะ ระยะ 20 สตัด (2 x 12)
			{
				cooldown = 7,
				castTime = 1.1,
				run = function(ctx)
					ctx.anim("Ult1")
					for _ = 1, 12 do
						ctx.fx("Ult1")
						ctx.hitArea(
							{ size = Vector3.new(3, 3, 20), offset = 10 },
							{ damage = 2, stun = 0.25, knockback = 2 }
						)
						if not ctx.wait(0.075) then
							return
						end
					end
				end,
			},
			-- 2: ยืดแขนเกาะพื้นแล้วดีดตัวพุ่งไปข้างหน้า 35 สตัด ชนคนที่ขวาง
			{
				cooldown = 8,
				castTime = 0.6,
				run = function(ctx)
					ctx.anim("Ult2")
					ctx.fx("Ult2")
					if not ctx.wait(0.15) then
						return
					end
					ctx.impulse(ctx.forward() * 140, 0.25)
					if not ctx.wait(0.18) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(7, 6, 7), offset = 3 },
						{ damage = 10, stun = 0.6, knockback = 25 }
					)
				end,
			},
			-- 3: กระโดดสูงแล้วเหวี่ยงขาที่ยืดยาวลงมา พื้นที่กว้าง 14 สตัด มึน 1 วินาที
			{
				cooldown = 12,
				castTime = 1.1,
				run = function(ctx)
					ctx.anim("Ult3")
					ctx.fx("Ult3Charge")
					ctx.impulse(Vector3.new(0, 60, 0), 0.3)
					if not ctx.wait(0.7) then
						return
					end
					ctx.fx("Ult3")
					ctx.hitArea(
						{ size = Vector3.new(14, 6, 14), offset = 0 },
						{ damage = 16, stun = 1.0, knockback = 18, blockable = false }
					)
				end,
			},
			-- 4: อัดแรงดัน 1 วินาที แล้วปล่อยหมัดยักษ์กว้าง 10 ไกล 40 สตัด ใช้ได้ 1 ครั้งต่อร่าง
			{
				cooldown = 1,
				usesPerForm = 1,
				movementLock = true,
				castTime = 1.6,
				run = function(ctx)
					ctx.anim("Ult4")
					ctx.fx("Ult4Charge")
					if not ctx.wait(1.0) then
						return
					end
					ctx.fx("Ult4")
					ctx.hitArea(
						{ size = Vector3.new(10, 10, 40), offset = 20 },
						{ damage = 28, stun = 1.2, knockback = 70, knockbackUp = 12 }
					)
				end,
			},
		},
	},
}

return kit
