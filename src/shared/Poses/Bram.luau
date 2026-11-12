--!strict
-- ท่าทางของแบรม (สายยืด: ท่ากว้าง ดึงแขนไปไกลก่อนปล่อย) แขนยืดจริงวาดเป็นเอฟเฟกต์ใน client/Effects/Bram
-- มุมเป็นองศา: ไหล่ x บวก = ยกแขนไปข้างหน้า, z = กางแขนออกข้าง ค่าประมาณ ปรับได้ที่ไฟล์นี้ที่เดียว

local Util = require(script.Parent.Util)
local v, f = Util.v, Util.f

local function merge(...: { [string]: Vector3 }): { [string]: Vector3 }
	local out: { [string]: Vector3 } = {}
	for _, pose in { ... } do
		for joint, angle in pose do
			out[joint] = angle
		end
	end
	return out
end

-- หมัดรัวสลับซ้ายขวา (ใช้กับ Ult1) 12 หมัดห่างกัน 0.075 วินาที
type Frame = { t: number, pose: { [string]: Vector3 }, move: Vector3? }

local function barrage(): { Frame }
	local frames = {}
	for i = 0, 11 do
		local right = i % 2 == 0
		local punch = right and { RightShoulder = v(95, 0, 0), LeftShoulder = v(20, 0, 0), LeftElbow = v(90, 0, 0) }
			or { LeftShoulder = v(95, 0, 0), RightShoulder = v(20, 0, 0), RightElbow = v(90, 0, 0) }
		table.insert(frames, f(i * 0.075, merge(punch, { Waist = v(8, right and -25 or 25, 0) }), v(0, 0, -0.3)))
	end
	table.insert(frames, f(12 * 0.075, { Waist = v(8, 0, 0) }))
	return frames
end

return {
	M1_1 = {
		f(0, {
			RightShoulder = v(35, 0, 0),
			RightElbow = v(100, 0, 0),
			LeftShoulder = v(40, 0, 0),
			LeftElbow = v(90, 0, 0),
			Waist = v(0, 15, 0),
		}),
		f(
			0.07,
			{ RightShoulder = v(95, 0, 0), LeftShoulder = v(40, 0, 0), LeftElbow = v(90, 0, 0), Waist = v(0, -20, 0) },
			v(0, 0, -0.5)
		),
		f(
			0.22,
			{ RightShoulder = v(95, 0, 0), LeftShoulder = v(40, 0, 0), LeftElbow = v(90, 0, 0), Waist = v(0, -10, 0) },
			v(0, 0, -0.3)
		),
	},
	M1_2 = {
		f(0, {
			LeftShoulder = v(35, 0, 0),
			LeftElbow = v(100, 0, 0),
			RightShoulder = v(40, 0, 0),
			RightElbow = v(90, 0, 0),
			Waist = v(0, -15, 0),
		}),
		f(
			0.07,
			{ LeftShoulder = v(95, 0, 0), RightShoulder = v(40, 0, 0), RightElbow = v(90, 0, 0), Waist = v(0, 20, 0) },
			v(0, 0, -0.5)
		),
		f(
			0.22,
			{ LeftShoulder = v(95, 0, 0), RightShoulder = v(40, 0, 0), RightElbow = v(90, 0, 0), Waist = v(0, 10, 0) },
			v(0, 0, -0.3)
		),
	},
	M1_3 = { -- เตะหมุน
		f(
			0,
			{ Waist = v(0, 40, 0), RightShoulder = v(30, 0, 70), LeftShoulder = v(30, 0, -70), LeftKnee = v(-20, 0, 0) }
		),
		f(0.1, {
			Waist = v(0, -70, 0),
			RightShoulder = v(30, 0, 70),
			LeftShoulder = v(30, 0, -70),
			RightHip = v(95, 0, 0),
			RightKnee = v(-5, 0, 0),
		}, v(0, 0, -0.3)),
		f(
			0.28,
			{ Waist = v(0, -30, 0), RightHip = v(70, 0, 0), RightShoulder = v(30, 0, 70), LeftShoulder = v(30, 0, -70) }
		),
	},
	M1_4 = { -- แขนยืดต่อยไกล: ดึงแขนไปหลังสุดก่อนปล่อย
		f(0, {
			RightShoulder = v(-80, 0, 0),
			RightElbow = v(20, 0, 0),
			Waist = v(0, 35, 0),
			LeftShoulder = v(50, 0, 0),
			LeftElbow = v(80, 0, 0),
		}),
		f(0.13, {
			RightShoulder = v(100, 0, 0),
			RightElbow = v(0, 0, 0),
			Waist = v(20, -40, 0),
			LeftShoulder = v(-15, 0, 0),
		}, v(0, -0.2, -1.2)),
		f(0.38, { RightShoulder = v(100, 0, 0), Waist = v(10, -25, 0) }, v(0, -0.1, -0.6)),
	},
	M1_Uppercut = {
		f(0, {
			RightShoulder = v(-60, 0, 0),
			RightElbow = v(30, 0, 0),
			RightHip = v(25, 0, 0),
			RightKnee = v(-60, 0, 0),
			LeftKnee = v(-35, 0, 0),
		}, v(0, -0.7, 0)),
		f(0.12, { RightShoulder = v(178, 0, 0), RightElbow = v(0, 0, 0), Waist = v(-10, -15, 0) }, v(0, 0.3, -0.4)),
		f(0.38, { RightShoulder = v(178, 0, 0), Waist = v(-10, -10, 0) }, v(0, 0.2, -0.2)),
	},
	M1_Air = {
		f(0, {
			RightHip = v(150, 0, 0),
			RightKnee = v(-10, 0, 0),
			RightShoulder = v(0, 0, 70),
			LeftShoulder = v(0, 0, -70),
			Waist = v(-10, 0, 0),
		}),
		f(0.13, {
			RightHip = v(-20, 0, 0),
			RightKnee = v(0, 0, 0),
			RightShoulder = v(0, 0, 70),
			LeftShoulder = v(0, 0, -70),
			Waist = v(25, 0, 0),
		}, v(0, -0.3, -0.3)),
		f(
			0.35,
			{ RightHip = v(-10, 0, 0), RightShoulder = v(0, 0, 70), LeftShoulder = v(0, 0, -70), Waist = v(15, 0, 0) }
		),
	},
	Dash = {
		f(0, {
			Waist = v(30, 0, 0),
			RightShoulder = v(-80, 0, 15),
			LeftShoulder = v(-80, 0, -15),
			RightHip = v(35, 0, 0),
			LeftHip = v(-25, 0, 0),
		}, v(0, 0, -0.5)),
		f(0.2, { Waist = v(20, 0, 0), RightShoulder = v(-70, 0, 15), LeftShoulder = v(-70, 0, -15) }, v(0, 0, -0.3)),
	},

	-- สกิลปกติ
	Skill1Charge = {
		f(0, {
			RightShoulder = v(-90, 0, 0),
			RightElbow = v(10, 0, 0),
			Waist = v(-10, 40, 0),
			LeftShoulder = v(60, 0, 0),
			LeftElbow = v(60, 0, 0),
		}, v(0, -0.2, 0.3)),
		f(0.3, {
			RightShoulder = v(-90, 0, 0),
			RightElbow = v(10, 0, 0),
			Waist = v(-10, 40, 0),
			LeftShoulder = v(60, 0, 0),
			LeftElbow = v(60, 0, 0),
		}, v(0, -0.2, 0.3)),
	},
	Skill1 = {
		f(0, {
			RightShoulder = v(100, 0, 0),
			RightElbow = v(0, 0, 0),
			Waist = v(15, -35, 0),
			LeftShoulder = v(-20, 0, 0),
		}, v(0, -0.2, -1.0)),
		f(0.3, { RightShoulder = v(100, 0, 0), Waist = v(10, -25, 0) }, v(0, -0.1, -0.5)),
	},
	Skill2 = {
		f(0, {
			RightShoulder = v(95, 0, 10),
			RightWrist = v(-40, 0, 0),
			Waist = v(10, -15, 0),
			LeftShoulder = v(40, 0, 0),
			LeftElbow = v(80, 0, 0),
		}, v(0, 0, -0.5)),
		f(0.6, { RightShoulder = v(95, 0, 10), RightWrist = v(-40, 0, 0), Waist = v(10, -15, 0) }, v(0, 0, -0.5)),
	},
	Skill3 = { -- หมุนตัว 2 รอบ แขนกางออก
		f(0, { RightShoulder = v(0, 0, 90), LeftShoulder = v(0, 0, -90) }),
		f(0.4, { RightShoulder = v(0, 0, 90), LeftShoulder = v(0, 0, -90), Waist = v(0, 360, 0) }),
		f(0.8, { RightShoulder = v(0, 0, 90), LeftShoulder = v(0, 0, -90), Waist = v(0, 720, 0) }),
		f(1.2, { RightShoulder = v(0, 0, 90), LeftShoulder = v(0, 0, -90), Waist = v(0, 1080, 0) }),
		f(1.5, { RightShoulder = v(0, 0, 60), LeftShoulder = v(0, 0, -60), Waist = v(0, 1260, 0) }),
	},
	Skill4Anchor = {
		f(0, {
			RightShoulder = v(100, 0, 0),
			RightElbow = v(0, 0, 0),
			RightWrist = v(-40, 0, 0),
			Waist = v(10, -10, 0),
			LeftShoulder = v(30, 0, 0),
			LeftElbow = v(60, 0, 0),
		}, v(0, 0, -0.3)),
		f(0.3, { RightShoulder = v(100, 0, 0), RightWrist = v(-40, 0, 0), Waist = v(10, -10, 0) }, v(0, 0, -0.3)),
	},
	Skill4 = {
		f(0, {
			RightShoulder = v(-70, 0, 0),
			RightElbow = v(110, 0, 0),
			Waist = v(20, 35, 0),
			LeftShoulder = v(60, 0, 0),
			RightHip = v(30, 0, 0),
		}, v(0, 0, -0.4)),
		f(0.2, {
			RightShoulder = v(100, 0, 0),
			RightElbow = v(0, 0, 0),
			Waist = v(25, -40, 0),
			LeftShoulder = v(-20, 0, 0),
		}, v(0, -0.2, -1.0)),
		f(0.5, { RightShoulder = v(100, 0, 0), Waist = v(15, -25, 0) }, v(0, -0.1, -0.5)),
	},

	-- สกิลร่างอันติ
	Ult1 = barrage(),
	Ult2 = {
		f(0, {
			RightShoulder = v(60, 0, 0),
			LeftShoulder = v(60, 0, 0),
			RightHip = v(35, 0, 0),
			RightKnee = v(-60, 0, 0),
			LeftHip = v(35, 0, 0),
			LeftKnee = v(-60, 0, 0),
			Waist = v(30, 0, 0),
		}, v(0, -0.7, 0)),
		f(0.15, {
			RightShoulder = v(170, 0, 0),
			LeftShoulder = v(170, 0, 0),
			Waist = v(45, 0, 0),
			RightHip = v(-20, 0, 0),
			LeftHip = v(-20, 0, 0),
		}, v(0, 0, -0.8)),
		f(0.6, { RightShoulder = v(170, 0, 0), LeftShoulder = v(170, 0, 0), Waist = v(45, 0, 0) }, v(0, 0, -0.5)),
	},
	Ult3Charge = {
		f(0, {
			RightShoulder = v(60, 0, 0),
			LeftShoulder = v(60, 0, 0),
			RightHip = v(35, 0, 0),
			RightKnee = v(-60, 0, 0),
			LeftHip = v(35, 0, 0),
			LeftKnee = v(-60, 0, 0),
		}, v(0, -0.7, 0)),
		f(0.2, {
			RightShoulder = v(-10, 0, 20),
			LeftShoulder = v(-10, 0, -20),
			RightHip = v(-10, 0, 0),
			LeftHip = v(-10, 0, 0),
		}, v(0, 0.4, 0)),
		f(0.7, {
			RightHip = v(140, 0, 0),
			RightKnee = v(-5, 0, 0),
			RightShoulder = v(0, 0, 60),
			LeftShoulder = v(0, 0, -60),
			Waist = v(-15, 0, 0),
		}),
		f(
			1.0,
			{ RightHip = v(-30, 0, 0), RightShoulder = v(0, 0, 60), LeftShoulder = v(0, 0, -60), Waist = v(30, 0, 0) },
			v(0, -0.2, -0.2)
		),
		f(1.4, { RightHip = v(-20, 0, 0), Waist = v(20, 0, 0) }),
	},
	Ult4Charge = { -- อัดแรงดัน 1 วินาที (ตัวพอง แขนไปข้างหลัง) แล้วปล่อยหมัดยักษ์
		f(0, {
			RightShoulder = v(30, 0, 20),
			LeftShoulder = v(30, 0, -20),
			RightHip = v(20, 0, 0),
			RightKnee = v(-40, 0, 0),
			LeftKnee = v(-20, 0, 0),
		}, v(0, -0.5, 0)),
		f(1.0, {
			RightShoulder = v(-100, 0, 10),
			LeftShoulder = v(-100, 0, -10),
			RightElbow = v(10, 0, 0),
			LeftElbow = v(10, 0, 0),
			Waist = v(-20, 0, 0),
		}, v(0, -0.6, 0.4)),
		f(1.12, {
			RightShoulder = v(100, 0, -5),
			LeftShoulder = v(100, 0, 5),
			RightElbow = v(0, 0, 0),
			LeftElbow = v(0, 0, 0),
			Waist = v(30, 0, 0),
		}, v(0, -0.2, -1.2)),
		f(1.6, { RightShoulder = v(100, 0, -5), LeftShoulder = v(100, 0, 5), Waist = v(25, 0, 0) }, v(0, -0.2, -0.8)),
	},
}
