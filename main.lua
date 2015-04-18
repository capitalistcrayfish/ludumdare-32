-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local loader = require "libs/AdvTileLoader/Loader" -- Might not be needed
local gamestate = require "libs/HUMP/gamestate"

local menu = {} -- Define gamestates
local level1 = {}

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
	-- code
end

function love.update(dt)
	-- code
end

function love.draw()
	map:draw()
end
