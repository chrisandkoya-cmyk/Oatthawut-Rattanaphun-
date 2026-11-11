--!strict
-- ตัวเลขปรับสมดุลทั้งหมดของระบบต่อสู้อยู่ที่นี่ไฟล์เดียว
-- หมายเหตุ: client อ่านไฟล์นี้ได้ (ใช้แสดง UI/ทำนายผล) แต่เซิร์ฟเวอร์เป็นผู้ตัดสินจริงเสมอ

local Config = {
	-- ตัวละครเริ่มต้นเมื่อผู้เล่นเข้าเกม (ต้องตรงกับชื่อไฟล์ใน ServerScriptService/Server/Characters)
	DefaultCharacter = "TrainingFighter",

	-- ปิดการฟื้นเลือดอัตโนมัติของ Roblox (เกมต่อสู้ส่วนใหญ่ไม่ฟื้นเลือดเอง)
	DisableHealthRegen = true,

	JumpHeight = 7.2,

	M1 = {
		MaxHits = 4, -- คอมโบ 4 จังหวะ
		Interval = 0.35, -- ระยะห่างขั้นต่ำระหว่างหมัด (วินาที)
		ComboReset = 0.8, -- ไม่กดต่อเกินเวลานี้ คอมโบเริ่มใหม่
		EndLag = 1.0, -- พักหลังหมัดสุดท้าย
		Windup = 0.08, -- ดีเลย์ก่อน hitbox ออก
		ActionLock = 0.25, -- ช่วงที่กดสกิล/บล็อกไม่ได้หลังต่อย
		Damage = { 3, 3, 3, 5 },
		HitboxSize = Vector3.new(5, 5, 5),
		HitboxOffset = 3, -- ระยะ hitbox ไปข้างหน้า (studs)
		Stun = 0.45, -- hitstun ของหมัด 1-3
		FinalStun = 0.8,
		FinalKnockback = 8, -- studs/s ตัวละครปรับได้ผ่าน kit.m1.finalKnockback
		FinalKnockbackUp = 15,

		-- หมัดสุดท้ายแบบพิเศษ (เลือกจากปุ่มที่กดตอนตีหมัดที่ 4)
		-- กด Space ค้างแล้วตี = อัปเปอร์คัต ตีขึ้นฟ้า
		Uppercut = {
			Damage = 5,
			Stun = 1.0,
			Knockback = 4,
			KnockbackUp = 62, -- ลอยสูงประมาณ 10 สตัด
			MaxHeightAboveGround = 4, -- กด Space ค้างแล้วตี: ถ้าสูงจากพื้นเกินนี้ถือว่ากลางอากาศ (ตีกด)
		},
		-- ตีกลางอากาศ (กระโดดแล้วตี) = ทุบลงพื้น เป้ากระเด้งกลับขึ้นมาเล็กน้อย
		Downslam = {
			Damage = 6,
			Stun = 0.6,
			Knockback = 6,
			KnockbackUp = -70,
			BounceDelay = 0.25,
			BounceUp = 22,
		},
		-- ตีเสย/ตีกดใช้คูลดาวน์ร่วมกัน
		SpecialCooldown = 3,
	},

	Block = {
		MaxDurability = 14, -- เท่ากับ M1 ครบ 4 ครั้ง (3+3+3+5) การ์ดแตก
		MinToRaise = 4, -- ต้องฟื้นถึงเท่านี้ถึงยกการ์ดใหม่ได้
		RegenPerSecond = 10,
		ChipMultiplier = 0.2, -- บล็อกลดดาเมจ 80% (ทะลุ 20%)
		GuardBreakStun = 1.6,
		WalkSpeed = 6,
		FrontDot = 0, -- บล็อกได้เฉพาะการโจมตีจากด้านหน้า (dot > ค่านี้)
	},

	Dash = {
		Cooldown = 2,
		Speed = 66, -- x Duration = พุ่งประมาณ 12 สตัด
		Duration = 0.18,
		IFrames = 0.15, -- เฟรมอมตะช่วงแรกของแดช
	},

	Stun = {
		Default = 0.4,
		WalkSpeed = 2,
	},

	Cast = {
		DefaultTime = 0.3, -- ล็อกการกระทำอื่นตอนร่ายสกิล ถ้าสกิลไม่กำหนด castTime
		WalkSpeed = 8,
	},

	Ultimate = {
		Max = 100,
		HealOnStart = 15, -- ฟื้น HP ตอนแปลงร่าง
		GainPerDamageDealt = 1.5,
		GainPerDamageTaken = 1.0,
	},

	Knockback = {
		Duration = 0.2,
	},

	-- จำกัดจำนวนครั้งยิง remote ต่อวินาที (กันสแปม/โปร)
	RateLimit = {
		M1 = { rate = 10, burst = 10 },
		Block = { rate = 12, burst = 12 },
		Dash = { rate = 3, burst = 3 },
		Skill = { rate = 6, burst = 6 },
		Ultimate = { rate = 2, burst = 2 },
		SelectCharacter = { rate = 1, burst = 2 },
		Respawn = { rate = 1, burst = 1 },
	},

	Debug = {
		SpawnDummies = true, -- สร้างหุ่นซ้อมใน Studio เท่านั้น
		ShowHitboxes = true, -- แสดงกล่อง hitbox สีแดงใน Studio เท่านั้น
	},
}

return Config
