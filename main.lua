-----------------------------
-- The Capitalist Crayfish --
--   Ludum Dare 32 (2015)  --
-----------------------------
-- Programming: Marnix "Weloxux" Massar <weloxux@glowbug.nl>
-- Sprites: Brzoz <email and stuff>

local Gamestate = require "libs/HUMP/gamestate" -- Import Gamestate module

local splash = {}
local menu = {} -- Define gamestates
local cutscene1 = {}
local level1 = {}
local cutscene2 = {}
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
Frames = Proxy( function(k) return love.graphics.newImage("img/cutscenes/"..k..".png") end)
Music = Proxy(function(k) return love.audio.newSource(love.sound.newSoundData("sound/"..k..".ogg")) end)
Sound = Proxy(function(k) return love.audio.newSource(love.sound.newSoundData("sound/"..k..".wav")) end)

local function die(v1, bullet, enemy, second, type, addScore)
	if bullet.x > enemy.x and bullet.x + bullet.sprite:getWidth() <= enemy.x + enemy.sprite:getWidth() and bullet.y >= enemy.y and bullet.y + bullet.sprite:getWidth() <= enemy.y + (enemy.sprite:getHeight() / 2) then
		love.audio.play(Sound.explosion)

		newSplode = {tim = 0.3, x = bullet.x - (enemy.sprite:getWidth() / 3), y = bullet.y - (enemy.sprite:getHeight() / 3)}
		table.insert(splodes, newSplode)

		if bullet.ringed == false then
			table.remove(v1, key)
		end
		table.remove(type, second)

		score = score + addScore
	end
end

local function loselive(baddie)
	if baddie.x < manus.x + manus.sprite:getWidth() and
		manus.x < baddie.x + baddie.sprite:getWidth() and
		baddie.y < manus.y + manus.sprite:getHeight() and
		manus.y < baddie.y + baddie.sprite:getHeight() then

		love.audio.play(Sound.explosion)

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

	waveTypes = {"single", "double", "scissors", "file", "sidefiles"} -- Define wavetypes
end

function level1:enter(previous, ...)
	love.audio.stop()

	files, clippers, scissors = {}, {}, {} -- Arrays of enemies
	floatRings = {} -- Rings currently not picked up

	controlCooldown = 0.3
	waveTimer = 60
	counter = 0

	fPinky = {base = {-22, 7 - Img.PINKY1:getHeight()}, loc = {-22, 7 - Img.PINKY1:getHeight()}, sprite = pinkySprite, shootmod = 3, bullets = {}, lastShot = 999, id = "q", bxm = -0.4, bulletSprite = Img.PLASER1, useSprite = "default", fSprite = Img.PINKY2, ringed = false, spriteR = Img.RPINKY1, fSpriteR = Img.RPINKY2, bulletSpriteR = Img.RPLASER1}
	fRing = {base = {2, 5 - Img.RING1:getHeight()}, loc = {2, 5 - Img.RING1:getHeight()}, sprite = ringSprite, shootmod = 10, bullets = {}, lastShot = 999, id = "w", bxm = -0.25, bulletSprite = Img.RLASER1, useSprite = "default", fSprite = Img.RING2, ringed = false, spriteR = Img.RRING1, fSpriteR = Img.RRING2, bulletSpriteR = Img.RRLASER1}
	fMiddle = {base = {46, 2 - Img.MIDDLE1:getHeight()}, loc = {46, 2 - Img.MIDDLE1:getHeight()}, sprite = middleSprite, shootmod = 15, bullets = {}, lastShot = 999, id = "e", bxm = 0, bulletSprite = Img.MLASER1, useSprite = "default", fSprite = Img.MIDDLE2, ringed = false, spriteR = Img.RMIDDLE1, fSpriteR = Img.RMIDDLE2, bulletSpriteR = Img.RMLASER1}
	fIndex = {base = {70, 5 - Img.INDEX1:getHeight()}, loc = {70, 5 - Img.INDEX1:getHeight()}, sprite = indexSprite, shootmod = 36, bullets = {}, lastShot = 999, id = "r", bxm = 0.4, bulletSprite = Img.ILASER1, useSprite = "default", fSprite = Img.INDEX2, ringed = false, spriteR = Img.RINDEX1, fSpriteR = Img.RINDEX2, bulletSpriteR = Img.RILASER1}
	fThumb = {base = {91, 51 - Img.THUMB1:getHeight()}, loc = {91, 51 - Img.THUMB1:getHeight()}, sprite = thumbSprite, shootmod = 56, bullets = {}, lastShot = 999, id = " ", bxm = 0.9, bulletSprite = Img.TLASER1, useSprite = "default", fSprite = Img.THUMB2, ringed = false, spriteR = Img.RTHUMB1, fSpriteR = Img.RTHUMB2, bulletSpriteR = Img.RTLASER1}

	allFingers = {fPinky, fRing, fMiddle, fIndex, fThumb}

	newWave = 5

	terrain = {grass = {}, palms = {}, turrets = {}, lakes = {}}

	for i = -2,12 do
		table.insert(terrain.grass, {x = 0, y = i * 100})
	end

	for i = 1,50 do
		table.insert(terrain.palms, {x = math.random() * math.random() * 900, y = math.random() * math.random() * 900, broken = false})
	end

	for i = 1,3 do
		table.insert(terrain.lakes, {x = math.random() * math.random() * 900, y = math.random() * math.random() * 900})
	end

	splodes = {} -- Format:   splodes = { {tim = 0.5, x = 1, y = 1} }

	score, lives = 0, 3

	Music.loop:play()
	Music.loop:setLooping(true)
end

function level1:update(dt)

	-- Check if still alive:
	if lives == 0 then
		love.audio.stop()
		love.audio.play(Sound.game_over)
		if score > tonumber(highScore) then
			Gamestate.switch(cutscene2)
		else
			Gamestate.switch(gameover)
		end
	end

	-- User input:
	if love.keyboard.isDown("left") and manus.state ~= "stomp" then
		if manus.x > 0 then
			manus.x = manus.x - (speed * dt)
		end
	end
	if love.keyboard.isDown("right") and manus.state ~= "stomp" then
		if manus.x < love.graphics.getWidth() - Img.IDLE1:getWidth() then
			manus.x = manus.x + (speed * dt)
		end
	end
	if love.keyboard.isDown("up") and manus.state ~= "stomp" then
		if manus.y > 0 then
			manus.y = manus.y - (0.5 * speed * dt)
		end
	end
	if love.keyboard.isDown("down") and manus.state ~= "stomp" then
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

			for key2, enemy in pairs(clippers) do
				die(v1.bullets, bullet, enemy, key2, clippers, 100)
				if manus.invul == false then
					loselive(enemy)
				end
			end

			for key2, enemy in pairs(files) do
				die(v1.bullets, bullet, enemy, key2, files, 300)
				if manus.invul == false then
					loselive(enemy)
				end
			end

			for key2, enemy in pairs(scissors) do
				die(v1.bullets, bullet, enemy, key2, scissors, 200)
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
					if v1.ringed then
						newbullet = {x = v1.loc[1] + v1.shootmod + manus.x, y = v1.loc[2] + manus.y, xmod = v1.bxm, sprite = v1.bulletSpriteR, ringed = true} -- Create a new bullet
					else
						newbullet = {x = v1.loc[1] + v1.shootmod + manus.x, y = v1.loc[2] + manus.y, xmod = v1.bxm, sprite = v1.bulletSprite, ringed = false} -- Create a new bullet
					end
					table.insert(v1.bullets, newbullet) -- Append the bullet to the list of bullets fired from its finger

					love.audio.play(Sound.laser1)

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

		if manus.state ~= "stomp" then
			for k4,v4 in pairs(floatRings) do
				if v4.x < v1.loc[1] + v1.sprite:getWidth() + manus.x and
					v1.loc[1] + manus.x < v4.x + v4.sprite:getWidth() and
					v4.y < v1.loc[2] + v1.sprite:getHeight() + manus.y and
					v1.loc[2] + manus.y < v4.y + v4.sprite:getHeight() then

					v1.ringed = true
					table.remove(floatRings, k4)

				end
			end
		end

		v1.lastShot = v1.lastShot + dt
	end

	-- Stomping:
	if love.keyboard.isDown("y", "u", "i", "o", "h", "j", "k", "l", "b", "n", "m", ";", ",", ".") then
		manus.state = "stomp"
		manus.stompTim = 0
	end

	if manus.state == "stomp" then
		manus.stompTim = manus.stompTim + dt
		if manus.stompTim >= 3 then
			manus.state = "default"
		elseif manus.stompTim >= 2 then
			-- TODO
		end
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

	if counter >= 15 then
		newWave = newWave * 0.98
		counter = 0
	end

	-- Spawn waves:
	if waveTimer >= newWave then
		math.randomseed(os.time())
		waveType = (waveTypes[math.random(1,#waveTypes)])
		if math.random(1,20) == 1 then
			newRing = {x = math.random() * math.random() * 900, y = -1.5 * Img.RING:getHeight(), sprite = Img.RING}
			table.insert(floatRings, newRing)
		end

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
				newClipper = {x = 10 + (i * 80), y = -150, sprite = Img.CLIPPER1}
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
			newFile = {x = 450 - (Img.FILE1:getWidth() / 2), start = 450 - (Img.FILE1:getWidth() / 2), y = -1 * Img.FILE1:getHeight(), sprite = FILE1, tim = 0.5, sprite = Img.FILE1, dir = "right"}
			table.insert(files, newFile)
		elseif waveType == "sidefiles" then
			newFile = {x = 900 + Img.FILE1:getWidth(), start = 900 + Img.FILE1:getWidth() - 100, y = 150, sprite = FILE1, tim = 0.5, sprite = Img.FILE1, dir = "left"}
			table.insert(files, newFile)
			newFile = {x = -1 * Img.FILE1:getWidth() , start = -1 * Img.FILE1:getWidth() + 100, y = 150, sprite = FILE1, tim = 0.5, sprite = Img.FILE1, dir = "right"}
			table.insert(files, newFile)
		end

		waveTimer = 0
	end

	-- Mob movements:

	for k,v in pairs(clippers) do
		v.y = v.y + (260 * dt)
		if v.y > love.graphics.getHeight() + Img.CLIPPER1:getHeight() then
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

		if v.y > love.graphics.getHeight() + v.sprite:getHeight() then
			table.remove(files, k)
		end
	end

	for k,v in pairs(scissors) do
		v.y = v.y + (140 * dt)
		if v.x < manus.x + manus.sprite:getWidth() / 2 then
			v.x = v.x + (20 * dt)
		else
			v.x = v.x - (20 * dt)
		end

		if v.y > love.graphics.getHeight() + v.sprite:getHeight() then
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

	for k,v in pairs(floatRings) do
		v.y = v.y + (125 * dt)
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
		end
	end

	for k,v in pairs(terrain.lakes) do
		v.y = v.y + (120 * dt)
		if v.y > love.graphics.getHeight() then
			v.y = 2 * -1 * Img.LAKE:getHeight()
			v.x = math.random() * 900 + 200
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
	counter = counter + dt
	manus.invulAnimTim = manus.invulAnimTim + dt

	-- Give time bonus:
	if manus.invulAnimTim >= 0.2 then
		score = score + 1
	end

end

function level1:draw()
	for k,v in pairs(terrain.grass) do
		love.graphics.draw(Img.grass1, v.x, v.y)
	end

	for k,v in pairs(terrain.lakes) do
		love.graphics.draw(Img.LAKE, v.x, v.y)
	end

	for k,v in pairs(terrain.palms) do
		love.graphics.draw(Img.PALM1, v.x, v.y)
	end

	if debugmode == true then
		love.graphics.print("\n\n".."FPS:"..tostring(love.timer.getFPS()).."\n"..printing.."\n"..waveTimer.."\n"..newWave.."\n"..tostring(manus.invul).."\n"..manus.state)
	end

	love.graphics.print("Score: "..score.."\n".."Lives: "..lives)

	if manus.invul == false then
		love.graphics.draw(manus.sprite, manus.x, manus.y) -- Draw Manus

		for k,v in pairs(allFingers) do
			if v.useSprite == "default" and v.ringed then
				love.graphics.draw(v.spriteR, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
			elseif v.useSprite == "fire" and v.ringed then
				love.graphics.draw(v.fSpriteR, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
			elseif v.useSprite == "default" then
				love.graphics.draw(v.sprite, manus.x + v.loc[1], manus.y + v.loc[2]) -- Draw the fingers
			else
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

	for k,v in pairs(floatRings) do
		love.graphics.draw(v.sprite, v.x, v.y)
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
	Music.loop:setLooping(false)
	Music.loop:stop()

	if score > tonumber(highScore) then
		love.filesystem.write("highscore.fin", score)
		highScore = score
	end
end

function gameover:keyreleased(key, code)
	if key == "return" then
		Gamestate.switch(menu) -- Go to menu
	end
end

function gameover:draw()
	love.graphics.draw(Img.gameover, 0, 0)
	love.graphics.print("Score: "..score)
	love.graphics.printf("PRESS ENTER", 0, 355, 900, "center")
end

function menu:enter(previous, ...)
	love.audio.play(Music.title)
end

function menu:keyreleased(key, code)
	if key == "return" then
		if firstTime == true then
			Gamestate.switch(cutscene1)
		else
			Gamestate.switch(level1) -- Go to level 1
		end
	elseif key == "rctrl" then
		Gamestate.switch(cutscene1)
	end
end

function menu:draw()
	love.graphics.draw(Img.title, 0, 0)
	love.graphics.setFont(bigJustice)
	if firstTime == false then
		love.graphics.printf("PRESS ENTER\n\n".."HIGHSCORE: "..tostring(highScore).."\n RCTRL FOR INTRO" , 0, 450, 900, "center")
	else
		love.graphics.printf("PRESS ENTER\n\n".."HIGHSCORE: "..tostring(highScore), 0, 450, 900, "center")
	end
	love.graphics.setFont(justice)
end

function love.load()
	-- General stuff:
	debugmode = false
	justice = love.graphics.newFont("font/justice.ttf", 30)
	bigJustice = love.graphics.newFont("font/justice.ttf", 47)
	love.graphics.setFont(justice)
	manusStart = Img.IDLE1
	manus = {state = "default", x = 300, y = 600, sprite = manusStart, invul = false, invultim = 0, invulAnimTim = 0, stompTim = 0}
	speed = 220

	-- Splash screen:
	crayfish = love.graphics.newImage("img/splash/crayfish.png")
	text = love.graphics.newImage("img/splash/text.png")
	crayfishObj = { y = -234, target = 50, center = (love.graphics.getWidth() / 2 - 124) }
	textObj = { y = -500, target = 260, center = (love.graphics.getWidth() / 2 - 326) }
	frames = 0

	-- Highscore:
	if love.filesystem.isFile("highscore.fin") then
		highScore = love.filesystem.read("highscore.fin")
	else
		love.filesystem.newFile("highscore.fin")
		highScore = 12000
		love.filesystem.write("highscore.fin", highScore)
	end

	if love.filesystem.isFile("first.fin") then
		firstTime = false
	else
		firstTime = true
		love.filesystem.newFile("first.fin")
		love.filesystem.write("first.fin", ":^)")
	end

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



function cutscene1:enter(previous, ...)
	lastStep = 0

	drawFrame = Frames.F01
	allFrames = {Frames.F01, Frames.F02, Frames.F03, Frames.F04, Frames.F05, Frames.F06, Frames.F07, Frames.F08, Frames.F09, Frames.F10, Frames.F11, Frames.F12, Frames.F13, Frames.F14, Frames.F15, Frames.F16, Frames.F17, Frames.F18, Frames.F19}

	buzz = false

	firstTime = false
end

function cutscene1:update(dt)
	lastStep = lastStep + dt

	if drawFrame == Frames.F19 then
		if love.keyboard.isDown("return") and lastStep >= 3 then
			Gamestate.switch(level1)
		end

	elseif drawFrame == Frames.F04 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F05
			lastStep = 0

			love.audio.play(Sound.ralov)
		end
	elseif drawFrame == Frames.F05 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F06
			lastStep = 0
		end
	elseif drawFrame == Frames.F06 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F07
			lastStep = 0
		end
	elseif drawFrame == Frames.F07 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F08
			lastStep = 0
		end
	elseif drawFrame == Frames.F08 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F09
			lastStep = 0
		end
	elseif drawFrame == Frames.F09 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F10
			lastStep = 0
		end
	elseif drawFrame == Frames.F10 then
		if lastStep >= 0.14 then
			drawFrame = Frames.F11
			lastStep = 0
		end

	elseif love.keyboard.isDown("return") and drawFrame ~= F19 then
		copy = drawFrame
		for k,v in pairs(allFrames) do
			if v == copy and lastStep >= 1.2 then
				drawFrame = allFrames[k + 1]
				lastStep = 0
			end
		end
	end
end

function cutscene1:draw()
	love.graphics.draw(drawFrame, 0, 0)
	love.graphics.print("PRESS ENTER", 610, 860)
end



function cutscene2:enter()
	lastStep = 0

	muhFrames = {Frames.D01, Frames.D02, Frames.D03}
	muhDrawFrame = Frames.D01

end

function cutscene2:update(dt)
	lastStep = lastStep + dt

	if love.keyboard.isDown("return") then
		copy = muhDrawFrame
		for k,v in pairs(muhFrames) do
			if muhDrawFrame == Frames.D03 then
				if lastStep >= 3 then
					Gamestate.switch(menu)
				end
			elseif v == copy and lastStep >= 1.2 then
				muhDrawFrame = muhFrames[k + 1]
				lastStep = 0
			end
		end
	end
end

function cutscene2:draw()
	love.graphics.draw(muhDrawFrame, 0, 0)
end
