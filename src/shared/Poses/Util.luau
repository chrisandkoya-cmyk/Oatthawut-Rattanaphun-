--!strict
-- ตัวช่วยเขียนท่าให้สั้น

local Util = {}

function Util.v(x: number, y: number, z: number): Vector3
	return Vector3.new(x, y, z)
end

function Util.f(
	t: number,
	pose: { [string]: Vector3 },
	move: Vector3?
): { t: number, pose: { [string]: Vector3 }, move: Vector3? }
	return { t = t, pose = pose, move = move }
end

return Util
