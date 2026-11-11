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
		ComboReset = 1.2, -- ไม่กดต่อเกินเวลานี้ คอมโบเริ่มใหม่
		EndLag = 1.0, -- พักหลังหมัดสุดท้าย
		Windup = 0.08, -- ดีเลย์ก่อน hitbox ออก
		ActionLock = 0.25, -- ช่วงที่กดสกิล/บล็อกไม่ได้หลังต่อย
		Damage = { 4, 4, 4, 6 },
		HitboxSize = Vector3.new(5, 5, 5),
		HitboxOffset = 3, -- ระยะ hitbox ไปข้างหน้า (studs)
		Stun = 0.45, -- hitstun ของหมัด 1-3
		FinalStun = 0.8,
		FinalKnockback = 45,
		FinalKnockbackUp = 15,

		-- หมัดสุดท้ายแบบพิเศษ (เลือกจากปุ่มที่กดตอนตีหมัดที่ 4)
		-- กด Space ค้างแล้วตี = อัปเปอร์คัต ตีขึ้นฟ้า
		Uppercut = {
			Damage = 6,
			Stun = 1.0,
			Knockback = 4,
			KnockbackUp = 60,
		},
		-- ตีกลางอากาศ (กระโดดแล้วตี) = ทุบลงพื้น เป้ากระเด้งกลับขึ้นมาเล็กน้อย
		Downslam = {
			Damage = 7,
			Stun = 1.1,
			Knockback = 6,
			KnockbackUp = -70,
			BounceDelay = 0.25,
			BounceUp = 22,
		},
		-- หมัด 1-3 กลางอากาศ: ผลักขึ้นเบาๆ ให้คอมโบลอยค้างได้
		AirHitKnockbackUp = 8,
	},

	Block = {
		MaxDurability = 40, -- รับดาเมจได้เท่านี้ก่อนการ์ดแตก
		MinToRaise = 8, -- ต้องฟื้นถึงเท่านี้ถึงยกการ์ดใหม่ได้
		RegenPerSecond = 10,
		ChipMultiplier = 0, -- ดาเมจที่ทะลุการ์ด (0 = ไม่ทะลุ)
		GuardBreakStun = 1.6,
		WalkSpeed = 6,
		FrontDot = 0, -- บล็อกได้เฉพาะการโจมตีจากด้านหน้า (dot > ค่านี้)
	},

	Dash = {
		Cooldown = 2,
		Speed = 75,
		Duration = 0.18,
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
		GainPerDamageDealt = 1.0,
		GainPerDamageTaken = 0.5,
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
	},

	Debug = {
		SpawnDummies = true, -- สร้างหุ่นซ้อมใน Studio เท่านั้น
		ShowHitboxes = true, -- แสดงกล่อง hitbox สีแดงใน Studio เท่านั้น
	},
}

return Config
