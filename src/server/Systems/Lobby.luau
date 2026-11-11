--!strict
-- ระบบล็อบบี้ฝั่งเซิร์ฟเวอร์: รับคำขอ "เกิดใหม่" จากเมนู เพื่อให้ตัวละครที่เลือกใช้ได้ทันที
-- (Combat เป็นคนจำตัวละครที่เลือก แล้วใช้ตอนเกิดครั้งถัดไป)
-- กันโกง: คูลดาวน์ต่อผู้เล่น ไม่ให้เกิดใหม่รัวๆ เพื่อหนีการต่อสู้/ล้างสถานะ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local RESPAWN_COOLDOWN = 10 -- วินาที

local LobbySystem = {}

local lastRespawn: { [Player]: number } = {}

function LobbySystem.init()
	Net.get("Respawn").OnServerEvent:Connect(function(player: Player)
		local now = os.clock()
		local last = lastRespawn[player]
		if last and now - last < RESPAWN_COOLDOWN then
			return
		end
		lastRespawn[player] = now
		player:LoadCharacter()
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastRespawn[player] = nil
	end)
end

return LobbySystem
