# เกมต่อสู้อนิเมะ Roblox (Anime Battle Arena)

เกม ABA ที่ตัวละครได้แรงบันดาลใจจากอนิเมะแต่เป็นตัวละครต้นฉบับ เขียนด้วย Luau ผ่าน [Rojo](https://rojo.space)

- วิธีติดตั้งและเล่น: [docs/SETUP_ROJO.md](docs/SETUP_ROJO.md)
- วิธีเขียนตัวละคร: [docs/CHARACTER_API.md](docs/CHARACTER_API.md)

## โครงโปรเจกต์
```
src/shared  -> ReplicatedStorage/Shared   (Config, Types, Net, กฎคำนวณ, CharacterInfo)
src/server  -> ServerScriptService/Server (ระบบต่อสู้, Characters, Combat)
src/client  -> StarterPlayerScripts/Client (Input, HUD, เอฟเฟกต์)
```
กติกา: ดาเมจ/hitbox/คูลดาวน์ คำนวณฝั่งเซิร์ฟเวอร์เท่านั้น, 1 ตัวละคร = 1 ModuleScript
