--!strict
-- จำกัดจำนวนครั้งที่ผู้เล่นยิง remote ได้ต่อวินาที (token bucket)

local Players = game:GetService("Players")

type Bucket = { tokens: number, last: number }

local RateLimit = {}

local buckets: { [Player]: { [string]: Bucket } } = {}

function RateLimit.allow(player: Player, key: string, ratePerSec: number, burst: number): boolean
	local now = os.clock()
	local perPlayer = buckets[player]
	if not perPlayer then
		perPlayer = {}
		buckets[player] = perPlayer
	end
	local bucket = perPlayer[key]
	if not bucket then
		bucket = { tokens = burst, last = now }
		perPlayer[key] = bucket
	end
	bucket.tokens = math.min(burst, bucket.tokens + (now - bucket.last) * ratePerSec)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)

return RateLimit
