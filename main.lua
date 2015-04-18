-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local Gamestate = require "libs/HUMP/gamestate"

local menu = {} -- Define gamestates
local cutscene = {}
local level1 = {}
local boss1 = {}

love.graphics.setNewFont(32)



-- Manage resources (inspired by vrld's Princess):
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

Img = Proxy( function(k) return loves.graphics.newImage("img/"..k..".png") end)
Sound = Proxy(function(k) return love.sound.newSoundData("sound/"..k..".ogg") end)
Music = Proxy(function(k) return k, "stream" end)


function level1:update(dt)
	-- code
end

function level1:draw()
	love.graphics.print(":)", 0, 34)
end

function level1:quit()
end

function menu:keyreleased(key, code)
	if key == "return" then
		Gamestate.switch(level1)
	end
end

function menu:draw()
	love.graphics.print("Menu\nWork In Progress\nPress ENTER")
end


function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(menu)
end
