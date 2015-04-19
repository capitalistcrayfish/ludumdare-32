-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local Gamestate = require "libs/HUMP/gamestate" -- Import Gamestate module

local splash = {}
local menu = {} -- Define gamestates
local cutscene = {}
local level1 = {}
local gameover = {}

printing = ""

local function Proxy(f) -- Proxy function for sprites and audio
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

Img = Proxy( function(k) return love.graphics.newImage("img/"..k..".png") end) -- Proxy images and sound
Sound = Proxy(function(k) return love.audio.newSource(love.sound.newSoundData("sound/"..k..".ogg")) end)

local function die(v1, bullet, enemy, second, type, addScore)
	if bullet.x > enemy.x and bullet.x + bullet.sprite:getWidth() <= enemy.x + enemy.sprite:getWidth() and bullet.y >= enemy.y and bullet.y + bullet.sprite:getWidth() <= enemy.y + (enemy.sprite:getHeight() / 2) then
		-- TODO: sound

		newSplode = {tim = 0.3, x = bullet.x - (enemy.sprite:getWidth() / 3), y = bullet.y - (enemy.sprite:getHeight() / 3)}
		table.insert(splodes, newSplode)

		table.remove(v1, key)
		table.remove(type, second)

		score = score + addScore
	end
end

local function loselive(baddie)
	if baddie.x < manus.x + manus.sprite:getWidth() and
		manus.x < baddie.x + baddie.sprite:getWidth() and
		baddie.y < manus.y + manus.sprite:getHeight() and
		manus.y < baddie.y + baddie.sprite:getHeight() then

		newSplode = {tim = 0.3, x = baddie.x + (baddie.sprite:getWidth() / 2), y = baddie.y + (baddie.sprite:getHeight() / 2)}
		table.insert(splodes, newSplode)

		lives = lives - 1

		manus.invul = true
		manus.invultim = 2
	end
end

function level1:init()
	waveTimerMax = 200

	pinkySprite, ringSprite, middleSprite, indexSprite, thumbSprite = Img.PINKY1, Img.RING1, Img.MIDDLE1, Img.INDEX1, Img.THUMB1

	waveTypes = {"single", "double", "scissors", "file"} -- Define wavetypes
end

function level1:enter(previous, ...)
	love.audio.stop()

	files, clippers, scissors = {}, {}, {} -- Arrays of enemies

	controlCooldown = 0.3
	waveTimer = 60
	counter = 0

	fPinky = {base = {-22, 7 - Img.PINKY1:getHeight()}, loc = {-22, 7 - Img.PINKY1:getHeight()}, sprite = pinkySprite, shootmod = 3, bullets = {}, lastShot = 999, id = "q", bxm = -0.4, bulletSprite = Img.PLASER1, useSprite = "default", fSprite = Img.PINKY2}
	fRing = {base = {2, 5 - Img.RING1:getHeight()}, loc = {2, 5 - Img.RING1:getHeight()}, sprite = ringSprite, shootmod = 10, bullets = {}, lastShot = 999, id = "w", bxm = -0.25, bulletSprite = Img.RLASER1, useSprite = "default", fSprite = Img.RING2}
	fMiddle = {base = {46, 2 - Img.MIDDLE1:getHeight()}, loc = {46, 2 - Img.MIDDLE1:getHeight()}, sprite = middleSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "e", bxm = 0, bulletSprite = Img.MLASER1, useSprite = "default", fSprite = Img.MIDDLE2}
	fIndex = {base = {70, 5 - Img.INDEX1:getHeight()}, loc = {70, 5 - Img.INDEX1:getHeight()}, sprite = indexSprite, shootmod = 36, bullets = {}, lastShot = 999, id = "r", bxm = 0.4, bulletSprite = Img.ILASER1, useSprite = "default", fSprite = Img.INDEX2}
	fThumb = {base = {91, 51 - Img.THUMB1:getHeight()}, loc = {91, 51 - Img.THUMB1:getHeight()}, sprite = thumbSprite, shootmod = 56, bullets = {}, lastShot = 999, id = " ", bxm = 0.9, bulletSprite = Img.TLASER1, useSprite = "default", fSprite = Img.THUMB2}

	allFingers = {fPinky, fRing, fMiddle, fIndex, fThumb}

	newWave = 5

	terrain = {grass = {}, palms = {}, turrets = {}}

	for i = -2,12 do
		table.insert(terrain.grass, {x = 0, y = i * 100})
	end

	for i = 1,50 do
		table.insert(terrain.palms, {x = math.random() * math.random() * 900, y = math.random() * math.random() * 900, broken = false})
	end

	splodes = {} -- Format:   splodes = { {tim = 0.5, x = 1, y = 1} }

	score, lives = 0, 3

	Sound.loop:play()
	Sound.loop:setLooping(true)
end

function level1:update(dt)

	-- Check if still alive:
	if lives == 0 then
		Gamestate.switch(gameover)
	end

	-- User input:
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
		debugmode = true
	end

	tempCooldown = controlCooldown

	for k1,v1 in pairs(allFingers) do

		v1.lastShot = v1.lastShot + dt -- Append to the shot timer

		for key,bullet in pairs(v1.bullets) do
			bullet.y = bullet.y - (speed * 5 * dt) -- Move the bullets
			bullet.x = bullet.x + (bullet.xmod * speed * 5 * dt)
			if bullet.y < 0 then -- If the bullet is out of sight, remove it
				table.remove(v1, key)
			end

			for key2, enemy in pairs(clippers, files, scissors) do
				die(v1.bullets, bullet, enemy, key2, clippers, 100)
				if manus.invul == false then
					loselive(enemy)
				end
			end
		end

		for key2, enemy in pairs(clippers, files, scissors) do
			if manus.invul == false then
				loselive(enemy)
			end
		end

		if v1.lastShot >= 0.3 then
			v1.loc[2] = v1.base[2]
			v1.useSprite = "default"
		end

		if manus.state == "default" then
			if tempCooldown <= 0 then
				if love.keyboard.isDown(v1.id) then
					newbullet = {x = v1.loc[1] + v1.shootmod + manus.x, y = v1.loc[2] + manus.y, xmod = v1.bxm, sprite = v1.bulletSprite} -- Create a new bullet
					table.insert(v1.bullets, newbullet) -- Append the bullet to the list of bullets fired from its finger

					if controlCooldown <= 0 then
						controlCooldown = 0.4
					else
						controlCooldown = controlCooldown * 1.3
					end
					v1.lastShot = 0

					v1.loc[2] = v1.base[2] + 2
					v1.useSprite = "fire"
				end
			end
		end

		v1.lastShot = v1.lastShot + dt
	end

	-- Stomping:
	if love.keyboard.isDown("y", "u", "i", "o", "h", "j", "k", "l", "b", "n", "m", ";", ",", ".") then
		manus.state = "stomp"
	end

	if manus.state == "stomp" then
		-- TODO
	end

	-- Animations:
	--if counter % 2.5 <= 0.8 then
	if manus.sprite == Img.IDLE1 then
		manus.sprite = Img.IDLE2
	elseif manus.sprite == Img.IDLE2 then
		manus.sprite = Img.IDLE3
	else
		manus.sprite = Img.IDLE1
	end
	--end


	-- Spawn waves:
	if waveTimer >= newWave then
		math.randomseed(os.time())
		waveType = (waveTypes[math.random(1,#waveTypes)])

		printing = waveType

		if waveType == "single" then
			for i = 0,10 do

				newClipper = {x = 10 + (i * 80), y = -60, sprite = Img.CLIPPER1}
				table.insert(clippers, newClipper)
			end
		elseif waveType == "double" then
			for i = 0,10 do
				newClipper = {x = 10 + (i * 80), y = -60, sprite = Img.CLIPPER1}
				table.insert(clippers, newClipper)
			end
			for i = 0,10 do
				newClipper = {x = 10 + (i * 80), y = -120, sprite = Img.CLIPPER1}
				table.insert(clippers, newClipper)
			end
		elseif waveType == "scissors" then
			for n = 0,3 do
				for i = 0,2 do
					newScissor = {x = 150 + (n * 300), y = -60, sprite = Img.SCISSOR1, lastAnim = 0}
					table.insert(scissors, newScissor)
				end
			end
		elseif waveType == "file" then
			newFile = {x = 450 - (Img.FILE1:getWidth() / 2), start = 450 - (Img.FILE1:getWidth() / 2), y = 0, sprite = FILE1, tim = 0.5, sprite = Img.FILE1, dir = "right"}
			table.insert(files, newFile)
		end

		waveTimer = 0
	end

	-- Mob movements:

	for k,v in pairs(clippers) do
		v.y = v.y + (260 * dt)
		if v.y + Img.CLIPPER1:getHeight() > love.graphics.getHeight() then
			table.remove(clippers, k)
		end
	end

	for k,v in pairs(files) do
		-- file.start, file.dir
		v.y = v.y + (60 * dt)
		if v.dir == "right" then
			v.x = v.x + (300 * dt)
			if v.x >= v.start + 300 then
				v.dir = "rs"
				v.tim = 0.2
				v.sprite = Img.FILE3R
			elseif v.x > v.start + 4 then
				v.sprite = Img.FILE2R
			elseif v.x < v.start - 4 then
				v.sprite = Img.FILE2
			else
				v.sprite = Img.FILE1
			end
		elseif v.dir == "left" then
			v.x = v.x - (300 * dt)
			if v.x <= v.start - 300 then
				v.dir = "ls"
				v.tim = 0.2
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

	for k,v in pairs(scissors) do
		v.y = v.y + (140 * dt)
		if v.x < manus.x + manus.sprite:getWidth() / 2 then
			v.x = v.x + (20 * dt)
		else
			v.x = v.x - (20 * dt)
		end

		if v.y > love.graphics.getHeight() then
			table.remove(scissors, k)
		end
		v.lastAnim = v.lastAnim + dt

		if v.lastAnim >= 0.1 then
			if v.sprite == Img.SCISSOR1 then
				v.sprite = Img.SCISSOR2
			elseif v.sprite == Img.SCISSOR2 then
				v.sprite = Img.SCISSOR3
			elseif v.sprite == Img.SCISSOR3 then
				v.sprite = Img.SCISSOR4
			elseif v.sprite == Img.SCISSOR4 then
				v.sprite = Img.SCISSOR5
			elseif v.sprite == Img.SCISSOR5 then
				v.sprite = Img.SCISSOR6
			elseif v.sprite == Img.SCISSOR6 then
				v.sprite = Img.SCISSOR1
			end
			v.lastAnim = 0
		end
	end

	for k,v in pairs(splodes) do
		v.tim = v.tim - dt
		if v.tim <= 0 then
			table.remove(splodes, k)
		end
	end

	-- Terrain mutations:
	for k,v in pairs(terrain.grass) do
		v.y = v.y + (120 * dt)
		if v.y > love.graphics.getHeight() then
			v.y = 2 * -1 * Img.grass:getHeight()
		end
	end

	for k,v in pairs(terrain.palms) do
		v.y = v.y + (120 * dt)
		if v.y > love.graphics.getHeight() then
			v.y = 2 * -1 * Img.PALM1:getHeight()
			v.x = math.random() * math.random() * 900
			v.broken = false
		end
	end

	-- Edit timers etc.:
	if controlCooldown > 0 then
		controlCooldown = controlCooldown - dt
	end

	if manus.invul == true then
		manus.invultim = manus.invultim - dt
	end

	if manus.invultim <= 0 then
		manus.invul = false
	end

	waveTimer = waveTimer + dt
	counter = dt
	manus.invulAnimTim = manus.invulAnimTim + dt

end

function level1:draw()
	for k,v in pairs(terrain.grass) do
		love.graphics.draw(Img.grass1, v.x, v.y)
	end

	for k,v in pairs(terrain.palms) do
		if v.broken then
			love.graphics.draw(Img.PALM2, v.x, v.y)
		else
			love.graphics.draw(Img.PALM1, v.x, v.y)
		end
	end

	if debugmode == true then
		love.graphics.print("\n\n".."FPS:"..tostring(love.timer.getFPS()).."\n"..printing.."\n"..waveTimer.."\n"..newWave.."\n"..tostring(manus.invul).."\n"..manus.state)
	end

	love.graphics.print("Score: "..score.."\n".."Lives: "..lives)

	if manus.invul == false then
		love.graphics.draw(manus.sprite, manus.x, manus.y) -- Draw Manus

		for k,v in pairs(allFingers) do
			if v.useSprite == "default" then
				love.graphics.draw(v.sprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
			elseif v.useSprite == "fire" then
				love.graphics.draw(v.fSprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
			end

			for key, bullet in pairs(v.bullets) do
				love.graphics.draw(bullet.sprite, bullet.x, bullet.y) -- Draw the player bullets
			end
		end
		if manus.invulAnimTim >= 0.2 then
			manus.invulAnimTim = 0
		end
	elseif manus.invul == true then
		if manus.invulAnimTim >= 0.05 then
			love.graphics.draw(manus.sprite, manus.x, manus.y) -- Draw Manus

			for k,v in pairs(allFingers) do
				if v.useSprite == "default" then
					love.graphics.draw(v.sprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
				elseif v.useSprite == "fire" then
					love.graphics.draw(v.fSprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
				end

				for key, bullet in pairs(v.bullets) do
					love.graphics.draw(bullet.sprite, bullet.x, bullet.y) -- Draw the player bullets
				end
			end
			manus.invulAnimTim = 0
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

	for k,v in pairs(splodes) do
		if v.tim > 0.2 then
			love.graphics.draw(Img.EXPLOSION, v.x, v.y)
		elseif v.tim <= 0.1 then
			love.graphics.draw(Img.EXPLOSION3, v.x, v.y)
		else
			love.graphics.draw(Img.EXPLOSION2, v.x, v.y)
		end
	end
end

function gameover:enter(previous, ...)
	Sound.loop:setLooping(false)
	Sound.loop:stop()
end

function gameover:keyreleased(key, code)
	if key == "return" or " " then
		Gamestate.switch(menu) -- Go to menu
	end
end

function gameover:draw()
	love.graphics.draw(Img.gameover, 0, 0)
	love.graphics.setFont(justice)
	love.graphics.print("Score: "..score)
	love.graphics.printf("PRESS ENTER", 0, 355, 900, "center")
	love.graphics.setFont(ubuntu)
end

function menu:enter(previous, ...)
	love.audio.play(Sound.title)
end

function menu:keyreleased(key, code)
	if key == "return" or " " then
		Gamestate.switch(level1) -- Go to level 1
	end
end

function menu:draw()
	love.graphics.draw(Img.title, 0, 0)
	love.graphics.setFont(bigJustice)
	love.graphics.printf("PRESS ENTER", 0, 450, 900, "center")
	love.graphics.setFont(ubuntu)
end

function love.load()
	-- General stuff:
	debugmode = false
	ubuntu = love.graphics.newFont("font/Ubuntu-R.ttf", 30)
	justice = love.graphics.newFont("font/justice.ttf", 30)
	bigJustice = love.graphics.newFont("font/justice.ttf", 47)
	love.graphics.setFont(ubuntu)
	manusStart = Img.IDLE1
	manus = {state = "default", x = 300, y = 600, sprite = manusStart, invul = false, invultim = 0, invulAnimTim = 0}
	speed = 220

	-- Splash screen:
	crayfish = love.graphics.newImage("img/splash/crayfish.png")
	text = love.graphics.newImage("img/splash/text.png")
	crayfishObj = { y = -234, target = 50, center = (love.graphics.getWidth() / 2 - 124) }
	textObj = { y = -500, target = 260, center = (love.graphics.getWidth() / 2 - 326) }
	frames = 0

	-- Gamestate"
	Gamestate.registerEvents()
	Gamestate.switch(splash)
end

function splash:update(dt)
	frames = frames + (1 * dt)

	crayfishObj.y = crayfishObj.y + (crayfishObj.target - crayfishObj.y) * 0.1
	textObj.y = textObj.y + (textObj.target - textObj.y) * 0.1

	if frames % 2900 >= 1 then
		Gamestate.switch(menu)
	end
end

function splash:draw(dt)
	love.graphics.draw(crayfish, crayfishObj.center, crayfishObj.y)
	love.graphics.draw(text, textObj.center, textObj.y)
end
