--!strict
-- ระบบล็อบบี้ฝั่งเซิร์ฟเวอร์: รับคำขอ "เกิดใหม่" จากเมนู เพื่อให้ตัวละครที่เลือกใช้ได้ทันที
-- (Combat จำตัวละครที่เลือก แล้วใช้ตอนเกิด และตั้ง Attribute CharacterId บน Player)
-- กันโกง (ไม่ให้ใช้เกิดใหม่หนีการต่อสู้/ฟื้นเลือด): ปฏิเสธถ้าเลือดไม่เต็ม, ชะงัก, ร่ายท่า,
-- อยู่ในโหมดอันติ หรือเพิ่งเกิดใหม่ไม่ถึงคูลดาวน์
-- ตอบกลับ client ด้วย Respawn:FireClient(player, ok, reason, waitSeconds)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Net = require(Shared.Net)
local RateLimit = require(script.Parent.Parent.Combat.RateLimit)
local State = require(script.Parent.Parent.Combat.State)

local RESPAWN_COOLDOWN = 10 -- วินาที

local LobbySystem = {}

local lastRespawn: { [Player]: number } = {}

-- คืน nil ถ้าเกิดใหม่ได้ ไม่งั้นคืนเหตุผล
local function denyReason(player: Player, now: number): string?
	local last = lastRespawn[player]
	if last and now - last < RESPAWN_COOLDOWN then
		return "Cooldown"
	end
	local character = player.Character
	if not character then
		return nil -- ยังไม่มีตัว (ตายอยู่) เกิดใหม่ได้
	end
	local state = State.get(character)
	if not state then
		return nil
	end
	local t = State.now()
	local humanoid = state.humanoid
	if
		humanoid.Health > 0
		and (
			humanoid.Health < humanoid.MaxHealth
			or state.inUltimate
			or t < state.stunnedUntil
			or t < state.castingUntil
		)
	then
		return "Combat"
	end
	return nil
end

function LobbySystem.init()
	local remote = Net.get("Respawn")
	remote.OnServerEvent:Connect(function(player: Player)
		local limit = Config.RateLimit.Respawn
		if not RateLimit.allow(player, "Respawn", limit.rate, limit.burst) then
			return
		end
		local now = os.clock()
		local reason = denyReason(player, now)
		if reason then
			local last = lastRespawn[player]
			local wait = if last then math.ceil(RESPAWN_COOLDOWN - (now - last)) else 0
			remote:FireClient(player, false, reason, math.max(wait, 0))
			return
		end
		lastRespawn[player] = now
		-- ล้างค่าเก่า เพื่อให้ระบบอื่น (Appearance) รอตัวละครใหม่จริง ไม่ใช้ id ของตัวเก่า
		player:SetAttribute("CharacterId", nil)
		remote:FireClient(player, true, "", 0)
		player:LoadCharacter()
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastRespawn[player] = nil
	end)
end

return LobbySystem
