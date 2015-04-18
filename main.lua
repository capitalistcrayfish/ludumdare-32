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

State = Proxy( function(k) return assert(love.filesystem.load("state/"..k..".lua"))() end)
Img = Proxy( function(k) return loves.graphics.newImage("img/"..k..".png") end)
Sound = Proxy(function(k) return love.sound.newSoundData("sound/"..k..".ogg") end)
Music = Proxy(function(k) return k, "stream" end)

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
