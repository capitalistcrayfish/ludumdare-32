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


local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

Img = Proxy( function(k) return love.graphics.newImage("img/"..k..".png") end)
Sound = Proxy(function(k) return love.sound.newSoundData("sound/"..k..".ogg") end)
Music = Proxy(function(k) return k, "stream" end)

function level1:init()
	waveTimer = 12
	waveTimerMax = 12
end

function level1:enter(previous, ...)
	manus = {status = neutral, x = 450, y = 600, img = nil}
	speed = 100

	files = {}
	scissors = {}

	cooldown = 0
	controlCooldown = 0.3

	pressed = {q = false, w = false, e = false, r = false, space = false}
end

function level1:update(dt)

	if love.keyboard.isDown("left") then
		if manus.x > 0 then
			manus.x = manus.x - (speed * dt)
		end
	end
	if love.keyboard.isDown("right") then
		if manus.x < love.graphics.getWidth() - Img.playerPH:getWidth() then
			manus.x = manus.x + (speed * dt)
		end
	end
	if love.keyboard.isDown("up") then
		if manus.y > 0 then
			manus.y = manus.y - (0.5 * speed * dt)
		end
	end
	if love.keyboard.isDown("down") then
		if manus.y < love.graphics.getHeight() - Img.playerPH:getHeight() then
			manus.y = manus.y + (0.5 * speed * dt)
		end
	end

	for k1,v1 in pairs(fingers) do
		if love.keyboard.isDown(v1) then
			if v1 == " " then
				pressed[space] = true
			else
				pressed[v1] = true
			end
		end
	end

	controlCooldown = controlCooldown - dt
	if controlCooldown <= 0 then
		for k,v in pairs(pressed) do
			if v == true then
				fire(k)
			end
			pressed[k] = false
		end
	end
end

function level1:draw()
	love.graphics.draw(Img.playerPH, manus.x, manus.y)
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
--	playerImage = love.graphics.newImage("img/playerPH.png")
--	manus = {status = neutral, x = 450, y = 600, img = love.graphics.newImage("img/playerPH.png") }
	manus = {status = neutral, x = 450, y = 600 }
	speed = 220
	fingers = {"q", "w", "e", "r", " "}

	Gamestate.registerEvents()
	Gamestate.switch(menu)
end
