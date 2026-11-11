--!strict
-- ท่าทางของโซลวาน (มุมเป็นองศา: ไหล่ x บวก = ยกแขนไปข้างหน้า, z = กางแขนออกข้าง)
-- ค่าประมาณจากการเขียนด้วยมือ ยังไม่ได้ดูในเกมจริง ปรับได้ที่ไฟล์นี้ที่เดียว

local Util = require(script.Parent.Util)
local v, f = Util.v, Util.f

local GUARD_L = { LeftShoulder = v(45, 0, 0), LeftElbow = v(85, 0, 0) }
local R_PUNCH = { RightShoulder = v(95, 0, 0), RightElbow = v(0, 0, 0) }
local L_PUNCH = { LeftShoulder = v(95, 0, 0), LeftElbow = v(0, 0, 0) }

local function merge(...: { [string]: Vector3 }): { [string]: Vector3 }
	local out: { [string]: Vector3 } = {}
	for _, pose in { ... } do
		for joint, angle in pose do
			out[joint] = angle
		end
	end
	return out
end

return {
	M1_1 = {
		f(0, merge(GUARD_L, { RightShoulder = v(30, 0, 0), RightElbow = v(100, 0, 0), Waist = v(0, 15, 0) })),
		f(0.07, merge(GUARD_L, R_PUNCH, { Waist = v(0, -20, 0) }), v(0, 0, -0.5)),
		f(0.34, merge(GUARD_L, R_PUNCH, { Waist = v(0, -10, 0) }), v(0, 0, -0.3)),
	},
	M1_2 = {
		f(0, {
			RightShoulder = v(45, 0, 0),
			RightElbow = v(85, 0, 0),
			LeftShoulder = v(30, 0, 0),
			LeftElbow = v(100, 0, 0),
			Waist = v(0, -15, 0),
		}),
		f(
			0.07,
			merge({ RightShoulder = v(45, 0, 0), RightElbow = v(85, 0, 0) }, L_PUNCH, { Waist = v(0, 20, 0) }),
			v(0, 0, -0.5)
		),
		f(
			0.22,
			merge({ RightShoulder = v(45, 0, 0), RightElbow = v(85, 0, 0) }, L_PUNCH, { Waist = v(0, 10, 0) }),
			v(0, 0, -0.3)
		),
	},
	M1_3 = {
		f(0, {
			RightShoulder = v(60, 0, -80),
			RightElbow = v(130, 0, 0),
			Waist = v(0, 30, 0),
			LeftShoulder = v(45, 0, 0),
			LeftElbow = v(85, 0, 0),
		}),
		f(0.08, {
			RightShoulder = v(60, 0, -20),
			RightElbow = v(130, 0, 0),
			Waist = v(0, -35, 0),
			LeftShoulder = v(45, 0, 0),
			LeftElbow = v(85, 0, 0),
		}, v(0, 0, -0.4)),
		f(0.36, { RightShoulder = v(60, 0, -20), RightElbow = v(130, 0, 0), Waist = v(0, -20, 0) }),
	},
	M1_4 = {
		f(0, {
			RightShoulder = v(-40, 0, 0),
			RightElbow = v(110, 0, 0),
			Waist = v(0, 30, 0),
			LeftShoulder = v(60, 0, 0),
			LeftElbow = v(70, 0, 0),
		}),
		f(0.12, {
			RightShoulder = v(100, 0, 0),
			RightElbow = v(0, 0, 0),
			Waist = v(25, -35, 0),
			LeftShoulder = v(-20, 0, 0),
		}, v(0, -0.2, -1.1)),
		f(0.47, { RightShoulder = v(100, 0, 0), Waist = v(15, -20, 0) }, v(0, -0.1, -0.6)),
	},
	M1_Uppercut = {
		f(0, {
			RightShoulder = v(-30, 0, 0),
			RightElbow = v(100, 0, 0),
			RightHip = v(20, 0, 0),
			RightKnee = v(-50, 0, 0),
			LeftKnee = v(-30, 0, 0),
		}, v(0, -0.6, 0)),
		f(0.1, { RightShoulder = v(175, 0, 0), RightElbow = v(0, 0, 0), Waist = v(-10, -15, 0) }, v(0, 0.3, -0.4)),
		f(0.35, { RightShoulder = v(175, 0, 0), Waist = v(-10, -10, 0) }, v(0, 0.2, -0.2)),
	},
	M1_Air = {
		f(0, { RightShoulder = v(170, 0, 15), LeftShoulder = v(170, 0, -15), Waist = v(-15, 0, 0) }),
		f(0.12, {
			RightShoulder = v(30, 0, 10),
			LeftShoulder = v(30, 0, -10),
			RightElbow = v(40, 0, 0),
			LeftElbow = v(40, 0, 0),
			Waist = v(40, 0, 0),
		}, v(0, -0.3, -0.4)),
		f(0.35, { RightShoulder = v(30, 0, 10), LeftShoulder = v(30, 0, -10), Waist = v(30, 0, 0) }),
	},
	Dash = {
		f(0, {
			Waist = v(35, 0, 0),
			RightShoulder = v(-60, 0, 0),
			LeftShoulder = v(-60, 0, 0),
			RightHip = v(40, 0, 0),
			LeftHip = v(-30, 0, 0),
		}, v(0, 0, -0.5)),
		f(0.2, { Waist = v(25, 0, 0), RightShoulder = v(-50, 0, 0), LeftShoulder = v(-50, 0, 0) }, v(0, 0, -0.3)),
	},

	-- สกิลปกติ
	Skill1 = { -- ง้างมือไปข้างหลังก่อน แล้วยื่นสองมือไปข้างหน้าตอนยิง
		f(0, {
			RightShoulder = v(-40, 0, -15),
			LeftShoulder = v(-30, 0, 15),
			RightElbow = v(115, 0, 0),
			LeftElbow = v(100, 0, 0),
			Waist = v(-6, 20, 0),
		}, v(0, -0.2, 0.2)),
		f(0.3, {
			RightShoulder = v(-40, 0, -15),
			LeftShoulder = v(-30, 0, 15),
			RightElbow = v(115, 0, 0),
			LeftElbow = v(100, 0, 0),
			Waist = v(-6, 20, 0),
		}, v(0, -0.2, 0.2)),
		f(0.38, {
			RightShoulder = v(95, 0, -5),
			LeftShoulder = v(95, 0, 5),
			RightElbow = v(0, 0, 0),
			LeftElbow = v(0, 0, 0),
			RightWrist = v(-30, 0, 0),
			Waist = v(12, -10, 0),
		}, v(0, -0.1, -0.5)),
		f(0.8, {
			RightShoulder = v(95, 0, -5),
			LeftShoulder = v(95, 0, 5),
			RightWrist = v(-30, 0, 0),
			Waist = v(12, -10, 0),
		}, v(0, -0.1, -0.4)),
	},
	Skill2 = {
		f(0, { Waist = v(15, 0, 0), RightShoulder = v(-40, 0, 0), LeftShoulder = v(-40, 0, 0) }),
		f(0.1, {
			Waist = v(55, 0, 0),
			RightShoulder = v(170, 0, 0),
			LeftShoulder = v(170, 0, 0),
			RightHip = v(-20, 0, 0),
			LeftHip = v(-20, 0, 0),
		}, v(0, -0.2, -0.8)),
		f(0.5, { Waist = v(55, 0, 0), RightShoulder = v(170, 0, 0), LeftShoulder = v(170, 0, 0) }),
	},
	Skill3 = {
		f(0, {
			RightShoulder = v(-30, 0, -20),
			RightElbow = v(70, 0, 0),
			RightHip = v(25, 0, 0),
			RightKnee = v(-55, 0, 0),
			LeftKnee = v(-35, 0, 0),
		}, v(0, -0.6, 0)),
		f(
			0.2,
			{ RightShoulder = v(178, 0, -10), RightElbow = v(0, 0, 0), RightWrist = v(-60, 0, 0), Waist = v(-10, 0, 0) },
			v(0, 0.2, -0.3)
		),
		f(0.55, { RightShoulder = v(178, 0, -10), RightWrist = v(-60, 0, 0) }),
	},
	Skill4Charge = { -- เริ่มตอนชาร์จ แล้วปล่อยลำแสงที่ ~1.05 วินาที (ตรงกับ ctx.wait(1.0) ในสกิล)
		f(0, {
			RightShoulder = v(10, 0, -25),
			LeftShoulder = v(10, 0, 25),
			RightElbow = v(95, 0, 0),
			LeftElbow = v(95, 0, 0),
			RightHip = v(15, 0, 0),
			RightKnee = v(-25, 0, 0),
		}, v(0, -0.3, 0)),
		f(1.0, {
			RightShoulder = v(-25, 0, -25),
			LeftShoulder = v(-25, 0, 25),
			RightElbow = v(110, 0, 0),
			LeftElbow = v(110, 0, 0),
			Waist = v(-10, 0, 0),
		}, v(0, -0.3, 0.2)),
		f(1.08, {
			RightShoulder = v(92, 0, -8),
			LeftShoulder = v(92, 0, 8),
			RightElbow = v(0, 0, 0),
			LeftElbow = v(0, 0, 0),
			Waist = v(15, 0, 0),
		}, v(0, -0.2, -0.6)),
		f(1.45, { RightShoulder = v(92, 0, -8), LeftShoulder = v(92, 0, 8), Waist = v(15, 0, 0) }, v(0, -0.2, -0.5)),
	},

	-- สกิลร่างอันติ
	Ult1 = {
		f(0, {
			RightShoulder = v(10, 0, 80),
			LeftShoulder = v(10, 0, -80),
			RightElbow = v(30, 0, 0),
			LeftElbow = v(30, 0, 0),
		}),
		f(0.25, {
			RightShoulder = v(85, 0, 25),
			LeftShoulder = v(85, 0, -25),
			RightElbow = v(10, 0, 0),
			LeftElbow = v(10, 0, 0),
			Waist = v(-8, 0, 0),
		}, v(0, 0, -0.2)),
		f(0.7, { RightShoulder = v(85, 0, 25), LeftShoulder = v(85, 0, -25), Waist = v(-8, 0, 0) }),
	},
	Ult2 = {
		f(0, { Waist = v(10, -50, 0), RightShoulder = v(60, 0, -60), RightElbow = v(130, 0, 0) }),
		f(0.1, { Waist = v(10, 45, 0), RightShoulder = v(60, 0, -20), RightElbow = v(130, 0, 0) }, v(0, 0, -0.3)),
		f(0.4, { Waist = v(5, 25, 0), RightShoulder = v(60, 0, -20), RightElbow = v(130, 0, 0) }),
	},
	Ult3Charge = {
		f(0, {
			RightShoulder = v(70, 0, -10),
			LeftShoulder = v(70, 0, 10),
			RightElbow = v(120, 0, 0),
			LeftElbow = v(120, 0, 0),
			RightHip = v(10, 0, 0),
			RightKnee = v(-30, 0, 0),
		}, v(0, -0.3, 0)),
		f(0.3, { RightShoulder = v(10, 0, 95), LeftShoulder = v(10, 0, -95), Waist = v(-10, 0, 0) }, v(0, 0.1, 0)),
		f(0.7, { RightShoulder = v(10, 0, 95), LeftShoulder = v(10, 0, -95) }),
	},
	Ult4Charge = {
		f(0, {
			RightShoulder = v(30, 0, -25),
			LeftShoulder = v(30, 0, 25),
			RightElbow = v(100, 0, 0),
			LeftElbow = v(100, 0, 0),
			RightHip = v(20, 0, 0),
			RightKnee = v(-40, 0, 0),
			LeftKnee = v(-20, 0, 0),
		}, v(0, -0.5, 0)),
		f(0.7, {
			RightShoulder = v(-25, 0, -25),
			LeftShoulder = v(-25, 0, 25),
			RightElbow = v(110, 0, 0),
			LeftElbow = v(110, 0, 0),
			Waist = v(-10, 0, 0),
		}, v(0, -0.5, 0.2)),
		f(0.78, {
			RightShoulder = v(92, 0, -8),
			LeftShoulder = v(92, 0, 8),
			RightElbow = v(0, 0, 0),
			LeftElbow = v(0, 0, 0),
			Waist = v(15, 0, 0),
		}, v(0, -0.4, -0.5)),
		f(2.9, { RightShoulder = v(92, 0, -8), LeftShoulder = v(92, 0, 8), Waist = v(15, 0, 0) }, v(0, -0.4, -0.5)),
	},
}
