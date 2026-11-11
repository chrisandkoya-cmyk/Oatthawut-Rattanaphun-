# สัญญาของตัวละคร (สำหรับคนเขียนตัวละคร)

**1 ตัวละคร = 1 ModuleScript** + 1 ไฟล์ข้อมูล แยกกันดังนี้

| ไฟล์ | ใส่อะไร | ใครเห็น |
|---|---|---|
| `src/server/Characters/<Id>.luau` | ตัวเลข + โค้ดสกิล | เซิร์ฟเวอร์เท่านั้น |
| `src/shared/CharacterInfo/<Id>.luau` | ชื่อ คำอธิบาย สี สกิน เสียง อนิเมชัน | ทุกคน (UI ใช้) |

ชื่อไฟล์ต้องตรงกับ `id` ระบบจะโหลดอัตโนมัติ ถ้าโครงไม่ครบจะ `warn` บอกใน Output ว่าขาดอะไร ดูตัวอย่างที่ `TrainingFighter` (คัดลอกแล้วแก้)

## Kit (ฝั่งเซิร์ฟเวอร์) — ชนิดใน `Types.CharacterKit`
- `stats = { maxHealth, walkSpeed }`
- `m1` (ไม่บังคับ): `damage = {4,4,4,6}`, `hitboxSize`, `finalKnockback`
- `skills`: ตารางละ **4 ท่า** `{ cooldown, castTime?, run(ctx) }`
- `ultimate`: `duration`, `walkSpeedMultiplier?`, `damageMultiplier?`, `skills` (4 ท่าชุดใหม่), `onStart?`, `onEnd?`

M1 คอมโบ / บล็อก / แดช / M1 พิเศษ (อัปเปอร์คัต, ทุบกลางอากาศ) เป็นระบบกลาง **ตัวละครไม่ต้องเขียนเอง** ปรับได้ที่ `Config.M1`

## ctx ที่สกิลใช้ (`Types.SkillContext`)
ทุกฟังก์ชันรันบนเซิร์ฟเวอร์ ดาเมจ/hitbox/คูลดาวน์ถูกคำนวณที่นี่หมด

| ฟังก์ชัน | หน้าที่ |
|---|---|
| `ctx.wait(sec)` | รอ คืน `false` ถ้าถูกขัด (โดนตี/ตาย) -> ให้ `return` ทันที |
| `ctx.hitArea({size, offset}, {damage, stun, knockback, knockbackUp, blockable, guardBreak})` | hitbox + ดาเมจทุกเป้า คืนจำนวนที่โดน |
| `ctx.hitbox` / `ctx.damage` | แยกขั้น ถ้าต้องการควบคุมเอง |
| `ctx.projectile({speed, range, radius, hit, pierce})` | ยิงกระสุน (ชนด้วย raycast บนเซิร์ฟเวอร์) |
| `ctx.impulse(velocity, duration)` | พุ่งตัวผู้ใช้ |
| `ctx.anim(key)` / `ctx.fx(key)` | เล่นอนิเมชัน/เอฟเฟกต์+เสียงตามคีย์ใน CharacterInfo (ว่าง = ข้าม) |
| `ctx.forward()` | ทิศที่หัน |

## กติกา
- ห้ามฝังชื่อท่า/ข้อความ/asset id ในไฟล์ kit — ไว้ใน CharacterInfo
- ห้ามแก้ `Humanoid.Health` ตรงๆ ให้ใช้ `ctx.damage/hitArea` (เพื่อให้บล็อก/ForceField/เกจทำงาน)
- ห้ามใช้ชื่อ หน้าตา ท่า เสียง ภาพจากอนิเมะจริง
- สกิลต้องเช็ค `ctx.wait` ทุกครั้งที่รอ
