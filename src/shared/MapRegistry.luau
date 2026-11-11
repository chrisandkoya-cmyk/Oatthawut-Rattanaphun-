--!strict
-- รายชื่อแมพทั้งหมดในเกม เพิ่มแมพใหม่: สร้างโฟลเดอร์ใน Maps/ แล้วเพิ่มบรรทัดเดียวที่นี่

local Maps = script.Parent.Maps

local MapRegistry = {}

MapRegistry.Order = { "TempleCourtyard", "SandstoneCanyon", "StormShip", "NinjaVillage", "IslandColosseum" }

local loaders: { [string]: () -> any } = {
	TempleCourtyard = function()
		return require(Maps.TempleCourtyard)
	end,
	SandstoneCanyon = function()
		return require(Maps.SandstoneCanyon)
	end,
	StormShip = function()
		return require(Maps.StormShip)
	end,
	NinjaVillage = function()
		return require(Maps.NinjaVillage)
	end,
	IslandColosseum = function()
		return require(Maps.IslandColosseum)
	end,
}

function MapRegistry.Get(id: string): any
	local load = loaders[id]
	assert(load, `ไม่มีแมพชื่อ {id}`)
	return load()
end

return MapRegistry
