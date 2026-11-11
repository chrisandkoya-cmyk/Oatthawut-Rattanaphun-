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
- `skills`: ตารางละ **4 ท่า** `{ cooldown, castTime?, usesPerForm?, movementLock?, interruptible?, run(ctx) }`
  - `usesPerForm`: ใช้ได้กี่ครั้งต่อร่าง (รีเซ็ตเมื่อแปลงร่าง/กลับร่าง) เช่น ท่าไม้ตายใส่ 1
  - `movementLock = true`: เดิน/กระโดดไม่ได้ตอนร่ายท่า
  - `interruptible = false`: โดนตีแล้วไม่ถูกขัด/ไม่มึน (ค่าเริ่มต้น true = โดนตีแล้วท่าหยุด เช่น ลำแสงชาร์จ)
  - ท่าที่บล็อกไม่ได้ ใส่ `blockable = false` ใน DamageInfo
- `ultimate`: `duration`, `walkSpeedMultiplier?`, `damageMultiplier?` (คูณดาเมจสกิล), `m1DamageMultiplier?` (คูณดาเมจ M1 ทุกแบบ ไม่ตั้ง = 1), `skills` (4 ท่าชุดใหม่), `onStart?`, `onEnd?`

M1 คอมโบ / บล็อก / แดช / M1 พิเศษ (ตีเสย, ตีกดกลางอากาศ ใช้คูลดาวน์ร่วม 3 วินาที) เป็นระบบกลาง **ตัวละครไม่ต้องเขียนเอง** ปรับตัวเลขได้ที่ `Config` (ค่าตั้งต้นตามเอกสารออกแบบตัวละคร: บล็อกลดดาเมจ 80% แตกเมื่อโดน M1 ครบ 4 ครั้ง, แดช 12 สตัด + อมตะ 0.15 วิ, เกจ ×1.5/×1, อันติ 30 วิ ฟื้น HP 15, ปุ่มอันติ G)

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
| `ctx.teleport(destination, maxDistance)` | วาร์ป: เซิร์ฟเวอร์ตรวจระยะ, clamp ขอบแมพ (`Workspace.Map` attribute `BoundsMin/BoundsMax`), raycast กันทะลุกำแพง คืน false ถ้าไม่ได้ |
| `ctx.pull(target, maxDistance)` | ดึงเป้ามาไว้หน้าผู้ใช้ (ตรวจระยะ/กำแพง/ขอบแมพ เหมือนวาร์ป) คืน false ถ้าไม่ได้ |
| `ctx.forward()` | ทิศที่หัน |

## กติกา
- ห้ามฝังชื่อท่า/ข้อความ/asset id ในไฟล์ kit — ไว้ใน CharacterInfo
- ห้ามแก้ `Humanoid.Health` ตรงๆ ให้ใช้ `ctx.damage/hitArea` (เพื่อให้บล็อก/ForceField/เกจทำงาน)
- ห้ามใช้ชื่อ หน้าตา ท่า เสียง ภาพจากอนิเมะจริง
- สกิลต้องเช็ค `ctx.wait` ทุกครั้งที่รอ
- ผู้ที่มี ForceField (เพิ่งเกิด) หรืออยู่ในเฟรมอมตะ จะไม่โดนอะไรเลย
