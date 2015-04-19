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

printing = ""

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
	files, clippers, scissors = {}, {}, {} -- Arrays of enemies

	controlCooldown = 0.3
	waveTimer = 60

	fPinky = {base = {-22, 7 - Img.PINKY1:getHeight()}, loc = {-22, 7 - Img.PINKY1:getHeight()}, sprite = pinkySprite, shootmod = 13, bullets = {}, lastShot = 999, id = "q"}
	fRing = {base = {2, 5 - Img.RING1:getHeight()}, loc = {2, 5 - Img.RING1:getHeight()}, sprite = ringSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "w"}
	fMiddle = {base = {46, 2 - Img.MIDDLE1:getHeight()}, loc = {46, 2 - Img.MIDDLE1:getHeight()}, sprite = middleSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "e"}
	fIndex = {base = {70, 5 - Img.INDEX1:getHeight()}, loc = {70, 5 - Img.INDEX1:getHeight()}, sprite = indexSprite, shootmod = 36, bullets = {}, lastShot = 999, id = "r"}
	fThumb = {base = {91, 49 - Img.THUMB1:getHeight()}, loc = {91, 49 - Img.THUMB1:getHeight()}, sprite = thumbSprite, shootmod = 46, bullets = {}, lastShot = 999, id = " "}

	allFingers = {fPinky, fRing, fMiddle, fIndex, fThumb}

	newWave = 10

	terrain = {grass = {}, palms = {}, turrets = {}}

	for i = -2,8 do
		table.insert(terrain.grass, {x = 0, y = i * 124})
	end
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
	if love.keyboard.isDown("rctrl") then
		debug.debug()
	end

	tempCooldown = controlCooldown

	for k1,v1 in pairs(allFingers) do

		v1.lastShot = v1.lastShot + dt -- Append to the shot timer

		for key,bullet in pairs(v1.bullets) do
			bullet.y = bullet.y - (speed * 5 * dt) -- Move the bullets
			if bullet.y < 0 then -- If the bullet is out of sight, remove it
				table.remove(v1, key)
			end
		end

		if v1.lastShot >= 0.3 then
			v1.loc[2] = v1.base[2]
		end

		if tempCooldown <= 0 then
			if love.keyboard.isDown(v1.id) then
				newbullet = {x = v1.loc[1] + v1.shootmod + manus.x, y = v1.loc[2] + manus.y} -- Create a new bullet
				table.insert(v1.bullets, newbullet) -- Append the bullet to the list of bullets fired from its finger

				controlCooldown = controlCooldown + 0.3
				v1.lastShot = 0
				v1.loc[2] = v1.base[2] + 2
			end
		end

		v1.lastShot = v1.lastShot + dt
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

	if waveTimer >= newWave then
		math.randomseed(os.time())
		for n = 0, 8 do
			waveType = waveTypes[math.random(1,3)]
		end

		if waveType == "simple" then
			for n = 0, 10 do
				newClipper = {sprite = Img.CLIPPER1, x = 10 + (n * 80), y = 10}
				table.insert(clippers, newClipper)
			end
		elseif waveType == "double" then
			for n = 0, 10 do
				newClipper = {sprite = Img.CLIPPER1, x = 10 + (n * 80), y = 10}
				table.insert(clippers, newClipper)
			end
			for n = 0, 10 do
				newClipper = {sprite = Img.CLIPPER1, x = 10 + (n * 80), y = -90}
				table.insert(clippers, newClipper)
			end
		elseif waveType == "triangle" then
			for n = 0, 7 do
				for n2 = 0,2 do
					newClipper = {sprite = Img.CLIPPER1, x = 10 + (20 * n) - (20 * n2), y = 10 + (80 * n)}
				end
			end
		else

		end
		waveTimer = 0
	end

	-- Mob movements:

	for k,v in pairs(clippers) do
		v.y = v.y + (88 * dt)
		if v.y + 70 >= love.graphics.getHeight() then
			table.remove(clippers, k)
		end
	end

	for k,v in pairs(files) do
		-- file.start, file.dir
		if v.dir == "right" then
			if v.x >= v.start + 30 then
				v.dir = "rs"
				v.tim = 0.5
				v.sprite = Img.FILE3R
			elseif v.x > v.start + 4 then
				v.sprite = Img.FILE2R
			elseif v.x < v.start - 4 then
				v.sprite = Img.FILE2
			else
				v.sprite = Img.FILE1
			end
		elseif v.dir == "left" then
			if v.x <= v.start - 30 then
				v.dir = "ls"
				v.tim = 0.5
				v.sprite = Img.FILE3
			elseif v.x > v.start + 4 then
				v.sprite = Img.FILE2R
			elseif v.x < v.start - 4 then
				v.sprite = Img.FILE2
			else
				v.sprite = Img.FILE1
			end
		else
			if v.tim <= 0 then
				if v.dir == "rs" then
					v.dir = "left"
				else
					v.dir = "right"
				end
			else
				v.tim = v.tim - dt
			end
		end
	end

	-- Terrain mutations:
	for k,v in pairs(terrain) do
		for k1,v1 in pairs(v) do
			v1.y = v1.y + (2 * dt)
			if v1.y > love.graphics.getHeight() then
				table.remove(v, k1)
				table.insert(v, {x = 0, y = 2 * -1 * Img.grass:getHeight()})
			end
		end
	end

	-- Edit timers etc.:
	controlCooldown = controlCooldown - dt
	waveTimer = waveTimer + dt

end

function level1:draw()
	for k,v in pairs(terrain.grass) do
		love.graphics.draw(Img.grass, 0, v.y)
	end

	love.graphics.print("FPS:"..tostring(love.timer.getFPS()))
	love.graphics.print("\n"..printing.."\n"..waveTimer.."\n"..newWave)

	love.graphics.draw(manus.sprite, manus.x, manus.y) -- Draw Manus

	for k,v in pairs(allFingers) do
		love.graphics.draw(v.sprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers

		for key, bullet in pairs(v.bullets) do
			love.graphics.circle("fill", bullet.x, bullet.y, 5, 30) -- Draw the bullet placeholders
		end
	end

	for k, v in pairs(clippers) do
		love.graphics.draw(v.sprite, v.x, v.y)
	end

	for k, v in pairs(files) do
		love.graphics.draw(v.sprite, v.x, v.y)
	end

	for k, v in pairs(scissors) do
		love.graphics.draw(v.sprite, v.x, v.y)
	end
end

function menu:keyreleased(key, code)
	if key == "return" or " " then
		Gamestate.switch(level1) -- Go to level 1
	end
end

function menu:draw()
	love.graphics.draw(Img.title, 0, 0)
end

function love.load()
	love.graphics.setFont(love.graphics.newFont(18))
	manusStart = Img.IDLE1
	manus = {status = "neutral", x = 300, y = 600, sprite = manusStart }
	speed = 220

	Gamestate.registerEvents()
	Gamestate.switch(menu)
end
