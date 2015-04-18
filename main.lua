-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local Gamestate = require "libs/HUMP/gamestate" -- Import Gamestate module

local menu = {} -- Define gamestates
local cutscene = {}
local level1 = {}

local function fire(finger)
	newbullet = {x = finger.base[1] + finger.shootmod,
					y = finger.base[2]} -- Create a new bullet
	table.insert(finger.bullets, newbullet) -- Append the bullet to the list of bullets fired from its finger
end

local function Proxy(f) -- Proxy function for sprites and audio
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

Img = Proxy( function(k) return love.graphics.newImage("img/"..k..".png") end) -- Proxy images and sound
Sound = Proxy(function(k) return love.sound.newSoundData("sound/"..k..".ogg") end)
Music = Proxy(function(k) return k, "stream" end)

function level1:init()
	waveTimerMax = 200

	pinkySprite, ringSprite, middleSprite, indexSprite, thumbSprite = Img.PINKY1, Img.RING1, Img.MIDDLE1, Img.INDEX1, Img.THUMB1

	waveTypes = {"single", "double", "triangle"} -- Define wavetypes

	counter = 0
end

function level1:enter(previous, ...)
	files, clippers = {}, {} -- Arrays of enemies

	controlCooldown = 0.3

	fPinky = {base = {-22, 7 - Img.PINKY1:getHeight()}, loc = {-22, 7 - Img.PINKY1:getHeight()}, sprite = pinkySprite, shootmod = 13, bullets = {}, lastShot = 999, id = "q"}
	fRing = {base = {2, 5 - Img.RING1:getHeight()}, loc = {2, 5 - Img.RING1:getHeight()}, sprite = ringSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "w"}
	fMiddle = {base = {46, 2 - Img.MIDDLE1:getHeight()}, loc = {46, 2 - Img.MIDDLE1:getHeight()}, sprite = middleSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "e"}
	fIndex = {base = {70, 5 - Img.INDEX1:getHeight()}, loc = {70, 5 - Img.INDEX1:getHeight()}, sprite = indexSprite, shootmod = 36, bullets = {}, lastShot = 999, id = "r"}
	fThumb = {base = {91, 49 - Img.THUMB1:getHeight()}, loc = {91, 49 - Img.THUMB1:getHeight()}, sprite = thumbSprite, shootmod = 46, bullets = {}, lastShot = 999, id = " "}

	allFingers = {fPinky, fRing, fMiddle, fIndex, fThumb}
end

function level1:update(dt)

	if love.keyboard.isDown("left") then
		if manus.x > 0 then
			manus.x = manus.x - (speed * dt)
		end
	end
	if love.keyboard.isDown("right") then
		if manus.x < love.graphics.getWidth() - Img.IDLE1:getWidth() then
			manus.x = manus.x + (speed * dt)
		end
	end
	if love.keyboard.isDown("up") then
		if manus.y > 0 then
			manus.y = manus.y - (0.5 * speed * dt)
		end
	end
	if love.keyboard.isDown("down") then
		if manus.y < love.graphics.getHeight() - Img.IDLE1:getHeight() then
			manus.y = manus.y + (0.5 * speed * dt)
		end
	end

	for k1,v1 in pairs(allFingers) do
		v1.lastShot = v1.lastShot + dt -- Append to the shot timer

		for key,bullet in pairs(v1.bullets) do
			bullet.y = bullet.y - (speed * 5 * dt) -- Move the bullets
			if bullet.y < 0 then -- If the bullet is out of sight, remove it (slightly amateuristically done here)
				table.remove(v1, key)
			end
		end

		if v1.lastShot >= 0.2 then
			v1.loc = v1.base
		end

		if controlCooldown <= 0 and love.keyboard.isdown(v1.id) then
			fire(v1)
			controlCooldown = 0.5
			v1.lastShot = 0
			v1.loc = v1.base + 2
		end
	end

	if counter % 2.5 <= 1 then
		if manus.sprite == Img.IDLE1 then
			manus.sprite = Img.IDLE2
		elseif manus.sprite == Img.IDLE2 then
			manus.sprite = Img.IDLE3
		else
			manus.sprite = Img.IDLE1
		end
	end
end

function level1:draw()

	love.graphics.draw(manus.sprite, manus.x, manus.y) -- Draw Manus

	for k,v in pairs(allFingers) do
		love.graphics.draw(v.sprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers

		for key, bullet in pairs(v.bullets) do
			love.graphics.circle("fill", bullet.x, bullet.y, 5, 30) -- Draw the bullet placeholders
		end
	end
end

function menu:keyreleased(key, code)
	if key == "return" or " " then
		Gamestate.switch(level1) -- Go to level 1
	end
end

function menu:draw()
	love.graphics.print("Menu\nWork In Progress\nPress ENTER")
end

function love.load()
	manusStart = Img.IDLE1
	manus = {status = "neutral", x = 300, y = 600, sprite = manusStart }
	speed = 220

	Gamestate.registerEvents()
	Gamestate.switch(menu)
end
