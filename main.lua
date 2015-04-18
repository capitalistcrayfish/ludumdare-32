-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local loader = require "libs/AdvTileLoader/Loader" -- Might not be needed
local gamestate = require "libs/HUMP/gamestate"
local HCollider = require "libs/HC/HardonCollider"

local menu = {} -- Define gamestates
local level1 = {}

local collider
local allSolidTiles

loader.path = "maps/"

-- Manage resources (inspired by vrld's Princess):
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

function love.load()
	map = loader.load("MAPNAME")

	collider = HCollider(150)

	allSolidTiles = findSolidTiles(map)
end

function level1:update(dt)
	-- code
end

function level1:draw()
	map:draw()
end
