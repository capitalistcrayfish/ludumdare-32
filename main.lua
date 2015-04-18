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

local function fire(key)
	if key == "q" then
		newbullet = {x = manus.x - Img.PINKY1:getWidth() / 2, y = manus.y - Img.PINKY1:getHeight()}
		table.insert(qbullets, newbullet)
	
	elseif key == "w" then
		newbullet = {x = manus.x - Img.RING1:getWidth() + 5, y = manus.y - Img.RING1:getHeight()}
		table.insert(wbullets, newbullet)
	
	elseif key == "e" then
		newbullet = {x = manus.x + 7, y = manus.y + 20}
		table.insert(ebullets, newbullet)
	
	elseif key == "r" then
		newbullet = {x = manus.x + 7, y = manus.y + 20}
		table.insert(rbullets, newbullet)
	
	elseif key == " " then
		newbullet = {x = manus.x + 7, y = manus.y + 20}
		table.insert(sbullets, newbullet)
	end	
end


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

	pinkySprite, ringSprite, middleSprite, indexSprite, thumbSprite = Img.PINKY1, Img.RING1, Img.MIDDLE1, Img.INDEX1, Img.THUMB1
	
end

function level1:enter(previous, ...)
	files = {}
	clipper = {}

	controlCooldown = 0.3

	qbullets, wbullets, ebullets, rbullets, sbullets = {}, {}, {}, {}, {}
	allOwnBullets = {qbullets, wbullets, ebullets, rbullets, sbullets}

	idle = Img.IDLE1

	fPinky = {base = {-22, 7 - Img.PINKY1:getHeight()}, loc = {-22, 7 - Img.PINKY1:getHeight()}, sprite = pinkySprite}
	fRing = {base = {2, 5 - Img.RING1:getHeight()}, loc = {2, 5 - Img.RING1:getHeight()}, sprite = ringSprite}
	fMiddle = {base = {46, 2 - Img.MIDDLE1:getHeight()}, loc = {46, 2 - Img.MIDDLE1:getHeight()}, sprite = middleSprite}
	fIndex = {base = {70, 5 - Img.INDEX1:getHeight()}, loc = {70, 5 - Img.INDEX1:getHeight()}, sprite = indexSprite}
	fThumb = {base = {91, 49 - Img.THUMB1:getHeight()}, loc = {91, 49 - Img.THUMB1:getHeight()}, sprite = thumbSprite}

	lastShots = {q = 999, w = 999, e = 999, r = 999, space = 999}

	counter = 0
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

	for k1, v1 in pairs(allOwnBullets) do
		for number,bullet in pairs(v1) do
			bullet.y = bullet.y - (speed * 5 * dt)
			if bullet.y < 0 then
				table.remove(v1, number)
			end
		end
	end

	for k,v in pairs(lastShots) do
		lastShots[k] = v + dt
	end
	controlCooldown = controlCooldown - dt

	for k1,v1 in pairs(fingers) do
		if love.keyboard.isDown(v1) then
			if controlCooldown <= 0 then
				fire(v1)
				controlCooldown = 0.5
				if v1 == " " then
					lastShots.space = 0
				else
					lastShots[v1] = 0
				end
			end
		end
	end

	for k,v in pairs(lastShots) do
		if v >= 4 then
			if k == "space" then
				fThumb.loc = fThumb.base
			elseif k == "q" then
				fPinky.loc = fPinky.base
			elseif k == "w" then
				fRing.loc = fRing.base
			elseif k == "e" then
				fMiddle.loc = fMiddle.base
			else
				fIndex.loc = fIndex.base
			end
		end
	end

	if counter >= 0.2 then
		if idle == Img.IDLE1 then
			idle = Img.IDLE2
		elseif
end

function level1:draw()
	
	love.graphics.draw(idle, manus.x, manus.y)
	love.graphics.draw(fPinky.sprite, manus.x + fPinky.loc[1], manus.y + fPinky.loc[2])
	love.graphics.draw(fRing.sprite, manus.x + fRing.loc[1], manus.y + fRing.loc[2])
	love.graphics.draw(fMiddle.sprite, manus.x + fMiddle.loc[1], manus.y + fMiddle.loc[2])
	love.graphics.draw(fIndex.sprite, manus.x + fIndex.loc[1], manus.y + fIndex.loc[2])
	love.graphics.draw(fThumb.sprite, manus.x + fThumb.loc[1], manus.y + fThumb.loc[2])

--	love.graphics.draw(Img.IDLE1, manus.x, manus.y)

	for k1, v1 in pairs(allOwnBullets) do
		for number, bullet in pairs(v1) do
			love.graphics.circle("fill", bullet.x, bullet.y, 5, 5)
		end
	end
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
	manus = {status = neutral, x = 450, y = 600 }
	speed = 220
	fingers = {"q", "w", "e", "r", " "}

	Gamestate.registerEvents()
	Gamestate.switch(menu)
end
