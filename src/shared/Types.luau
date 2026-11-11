--!strict
-- ชนิดข้อมูลกลางของระบบต่อสู้ และ "สัญญา" (interface) ของตัวละคร
-- ดูคำอธิบายฉบับเต็มที่ docs/CHARACTER_API.md

export type HitResult = "Hit" | "Blocked" | "GuardBreak" | "Miss"

-- ข้อมูลการโจมตี 1 ครั้ง (เซิร์ฟเวอร์ใช้คำนวณ)
export type DamageInfo = {
	damage: number,
	stun: number?, -- วินาทีที่เป้าโดนชะงัก (ค่าเริ่มต้น Config.Stun.Default)
	knockback: number?, -- ความเร็วผลักออกจากผู้โจมตี (studs/วินาที)
	knockbackUp: number?, -- ความเร็วผลักขึ้นฟ้า (ติดลบ = ทุบลงพื้น)
	bounce: number?, -- ถ้าใส่ เป้าจะเด้งกลับขึ้นด้วยความเร็วนี้หลังกระแทกพื้น
	blockable: boolean?, -- false = บล็อกไม่ได้ (ค่าเริ่มต้น true)
	guardBreak: boolean?, -- true = ทำลายการ์ดทันทีถ้าเป้าบล็อก
}

export type HitboxOptions = {
	size: Vector3,
	offset: number?, -- ระยะไปข้างหน้าตัวละคร (studs), 0 = รอบตัว
	cframe: CFrame?, -- ระบุตำแหน่งเองแทน offset
}

export type ProjectileOptions = {
	speed: number,
	range: number,
	radius: number,
	hit: DamageInfo,
	color: Color3?,
	pierce: boolean?, -- true = ทะลุหลายเป้า
	direction: Vector3?, -- ค่าเริ่มต้น = ทิศที่ตัวละครหัน
}

-- ของที่สกิลได้รับตอนทำงาน (ทุกฟังก์ชันรันบนเซิร์ฟเวอร์)
export type SkillContext = {
	player: Player?, -- nil ถ้าเป็น NPC/หุ่น
	character: Model,
	humanoid: Humanoid,
	root: BasePart,
	characterId: string,
	inUltimate: boolean,

	-- รอ แล้วคืนค่า false ถ้าสกิลถูกขัด (โดนตี/ตาย) -> สกิลควร return ทันที
	wait: (seconds: number) -> boolean,
	isActive: () -> boolean,
	forward: () -> Vector3,
	hitbox: (options: HitboxOptions) -> { Model },
	damage: (target: Model, info: DamageInfo) -> HitResult,
	-- hitbox + damage ทุกเป้าในครั้งเดียว คืนจำนวนเป้าที่โดน
	hitArea: (options: HitboxOptions, info: DamageInfo) -> number,
	projectile: (options: ProjectileOptions) -> (),
	-- พุ่งตัวผู้ใช้สกิล (เช่น พุ่งหมัด)
	impulse: (velocity: Vector3, duration: number?) -> (),
	-- เล่นเอฟเฟกต์/เสียงตามคีย์ (เสียงจริงอยู่ใน CharacterInfo.sounds)
	fx: (key: string, position: Vector3?) -> (),
	-- เล่นอนิเมชันตามคีย์ (id จริงอยู่ใน CharacterInfo.animations)
	anim: (key: string) -> (),
}

export type Skill = {
	cooldown: number,
	castTime: number?, -- เวลาที่ล็อกการกระทำอื่น
	run: (ctx: SkillContext) -> (),
}

export type UltimateKit = {
	duration: number,
	walkSpeedMultiplier: number?,
	damageMultiplier: number?,
	skills: { Skill }, -- 4 สกิลชุดใหม่ระหว่างแปลงร่าง
	onStart: ((ctx: SkillContext) -> ())?,
	onEnd: ((ctx: SkillContext) -> ())?,
}

export type M1Overrides = {
	damage: { number }?,
	hitboxSize: Vector3?,
	finalKnockback: number?,
}

-- โค้ด/ตัวเลขของตัวละคร (อยู่ฝั่งเซิร์ฟเวอร์ client มองไม่เห็น)
export type CharacterKit = {
	id: string,
	stats: {
		maxHealth: number,
		walkSpeed: number,
	},
	m1: M1Overrides?,
	skills: { Skill }, -- ช่อง 1-4
	ultimate: UltimateKit,
}

-- ชื่อ/สกิน/เสียง/อนิเมชัน (แยกจากโค้ดสกิล อยู่ใน ReplicatedStorage ให้ UI อ่านได้)
export type CharacterInfo = {
	id: string,
	displayName: string,
	description: string,
	color: Color3, -- สีออร่า/ธีม
	skillNames: { string }, -- 4 ชื่อ
	ultimate: {
		name: string,
		skillNames: { string },
	},
	skin: string?, -- ชื่อ HumanoidDescription ใน ReplicatedStorage/Assets/Skins
	animations: { [string]: string }, -- คีย์ -> "rbxassetid://..."
	sounds: { [string]: string }, -- คีย์ -> "rbxassetid://..."
}

export type FxPayload = {
	kind: string, -- "Hit" | "Blocked" | "GuardBreak" | "Skill" | "UltStart" | "UltEnd"
	key: string?,
	characterId: string?,
	source: Model?,
	target: Model?,
	position: Vector3?,
	amount: number?,
}

return {}
