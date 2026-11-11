--!strict
-- ตัวละครต้นแบบ: ใช้ทดสอบระบบ และเป็นแม่แบบให้ตัวละครจริง (คัดลอกไฟล์นี้แล้วแก้)
-- มีแต่ "ตัวเลขและโค้ดสกิล" ชื่อ/สกิน/เสียง/อนิเมชันอยู่ที่ Shared/CharacterInfo/<id>.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared").Types)

local kit: Types.CharacterKit = {
	id = "TrainingFighter",
	stats = { maxHealth = 100, walkSpeed = 16 },

	skills = {
		-- 1: หมัดหนัก
		{
			cooldown = 6,
			castTime = 0.5,
			run = function(ctx)
				ctx.anim("Skill1")
				ctx.fx("Skill1")
				if not ctx.wait(0.25) then
					return
				end
				ctx.hitArea(
					{ size = Vector3.new(6, 6, 7), offset = 4 },
					{ damage = 14, stun = 0.9, knockback = 50, knockbackUp = 10 }
				)
			end,
		},
		-- 2: ยิงพลัง
		{
			cooldown = 5,
			castTime = 0.4,
			run = function(ctx)
				ctx.anim("Skill2")
				if not ctx.wait(0.2) then
					return
				end
				ctx.fx("Skill2")
				ctx.projectile({
					speed = 90,
					range = 70,
					radius = 1.5,
					hit = { damage = 10, stun = 0.6, knockback = 20 },
				})
			end,
		},
		-- 3: ทุบพื้นรอบตัว (บล็อกไม่ได้)
		{
			cooldown = 10,
			castTime = 0.7,
			run = function(ctx)
				ctx.anim("Skill3")
				if not ctx.wait(0.4) then
					return
				end
				ctx.fx("Skill3")
				ctx.hitArea(
					{ size = Vector3.new(14, 6, 14), offset = 0 },
					{ damage = 12, stun = 1.0, knockback = 30, knockbackUp = 25, blockable = false }
				)
			end,
		},
		-- 4: พุ่งชน (ทำลายการ์ด)
		{
			cooldown = 9,
			castTime = 0.6,
			run = function(ctx)
				ctx.anim("Skill4")
				ctx.fx("Skill4")
				ctx.impulse(ctx.forward() * 70, 0.25)
				if not ctx.wait(0.12) then
					return
				end
				ctx.hitArea(
					{ size = Vector3.new(6, 6, 6), offset = 3 },
					{ damage = 9, stun = 0.8, knockback = 35, guardBreak = true }
				)
			end,
		},
	},

	ultimate = {
		duration = 30,
		walkSpeedMultiplier = 1.25,
		m1DamageMultiplier = 1.2,
		skills = {
			{
				cooldown = 4,
				castTime = 0.4,
				run = function(ctx)
					ctx.fx("Skill1")
					if not ctx.wait(0.2) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(8, 8, 9), offset = 5 },
						{ damage = 18, stun = 1.0, knockback = 70 }
					)
				end,
			},
			{
				cooldown = 3,
				castTime = 0.3,
				run = function(ctx)
					for _ = 1, 3 do
						ctx.projectile({
							speed = 110,
							range = 80,
							radius = 1.2,
							hit = { damage = 6, stun = 0.4, knockback = 10 },
						})
						if not ctx.wait(0.12) then
							return
						end
					end
				end,
			},
			{
				cooldown = 6,
				castTime = 0.6,
				run = function(ctx)
					if not ctx.wait(0.3) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(18, 6, 18), offset = 0 },
						{ damage = 14, stun = 1.2, knockback = 35, knockbackUp = 30, blockable = false }
					)
				end,
			},
			{
				cooldown = 7,
				castTime = 0.6,
				run = function(ctx)
					ctx.impulse(ctx.forward() * 90, 0.3)
					if not ctx.wait(0.15) then
						return
					end
					ctx.hitArea(
						{ size = Vector3.new(7, 7, 7), offset = 3 },
						{ damage = 15, stun = 1.0, knockback = 50, guardBreak = true }
					)
				end,
			},
		},
	},
}

return kit
