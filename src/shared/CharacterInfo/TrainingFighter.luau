--!strict
-- ข้อมูล "หน้าตา" ของตัวละครตัวอย่าง: ชื่อ สี สกิน เสียง อนิเมชัน
-- ไม่มีโค้ดสกิลในไฟล์นี้ (โค้ดอยู่ที่ ServerScriptService/Server/Characters/TrainingFighter)

local Types = require(script.Parent.Parent.Types)

local info: Types.CharacterInfo = {
	id = "TrainingFighter",
	displayName = "Training Fighter",
	description = "ตัวละครทดสอบระบบ ใช้เป็นต้นแบบให้ตัวละครจริง",
	color = Color3.fromRGB(255, 200, 60),
	skillNames = { "Heavy Punch", "Energy Shot", "Ground Slam", "Rush" },
	ultimate = {
		name = "Overdrive",
		skillNames = { "Giga Punch", "Energy Barrage", "Quake", "Final Rush" },
	},
	skin = nil,
	-- ใส่ "rbxassetid://<id>" ทีหลังเมื่อมีอนิเมชันของตัวเอง (ว่าง = ไม่เล่น)
	animations = {
		M1_1 = "",
		M1_2 = "",
		M1_3 = "",
		M1_4 = "",
		Block = "",
		Skill1 = "",
		Skill2 = "",
		Skill3 = "",
		Skill4 = "",
	},
	-- ใส่ "rbxassetid://<id>" ทีหลัง (ห้ามใช้เสียงจากอนิเมะจริง)
	sounds = {
		M1 = "",
		Hit = "",
		Skill1 = "",
		Skill2 = "",
		Skill3 = "",
		Skill4 = "",
		UltStart = "",
	},
}

return info
