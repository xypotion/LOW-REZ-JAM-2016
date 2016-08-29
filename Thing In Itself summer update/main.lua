--TODO for final version (back up before significant code changes!):
--progress animations (right/wrong), maybe sfx
--decide on final order of stages, i.e. foil and leaves should be early since they're easy, heat and animals should be later
--actually put letters in stages
--refactor levels to allow for any size & screen pos AND simultaneous execution. i bet you'll wish you'd been doing this from the start.
--sound. yikes. can you keep it really simple? one or two sounds per stage? kinda feels like a stretch goal at this point... (saturday afternoon)
--"correct!"/ending stages (Kant quote?)
--do you even need two questions?
--put lastX and lastY into overall load & make sure they work there
--clean up code & TODOs if time
--get higher-res images for text stages, also change their colors
--put it in git? lol
--make sure you can package and ship this to windows! and actually submit it to the jam!!
--stretch: animated gif for the title card. a screenshot of the ribbon will work otherwise

--TODO for 11th hour hackup
-- @ change foil color
-- @ letters, obvs
--   higher-res instructions (& credits)
--   maybe change the way conductivity works again for Heat?
--   make sure everything labeled "debug" is removed or commented out

function love.load()
	math.randomseed( os.time() )
	
	love.window.setTitle("QUESTION: WHAT CANNOT BE SENSED?")
	
	mapSize = 64
	cellSize = 10
	love.window.setMode(mapSize * cellSize, mapSize * cellSize, {resizable = false})
	
	-- lastStageName = "Final"
	-- stageNames = {"Instructions", "Question1", "Question2", "Rain", "Heat", "Animals", "Navigation", "Thread", "Electricity", "Foil", "Leaves", lastStageName}
	stageNames = {"Instructions", "Leaves", "Electricity", "Foil", "Navigation", "Heat", "Animals", "Rain", "Thread", "Credits"}
	stageSolutions = {"a", "n", "o", "u", "m", "e", "n", "o", "n", "*"}
	-- stageSolutions = {"u", "p", "h", "e", "n", "o", "m", "e", "n", "o", "n"}
	
	cells = {}
	stageNumber = 1 -- DEBUG, SHOULD BE 1
	
	_G["load"..stageNames[stageNumber].."Stage"]()
end

function love.update(dt)
	--get mouse x,y
	local mouseX, mouseY = love.mouse.getPosition()
	mx, my = math.floor(mouseX / cellSize) + 1, math.floor(mouseY / cellSize) + 1
	
	FPS = math.floor(1 / dt)
	if FPS < 50 then
		print(FPS)
	end
	
	_G["updateFor"..stageNames[stageNumber].."Stage"](my, mx, dt)
end

function love.draw()
	_G["drawFor"..stageNames[stageNumber].."Stage"]()
	
	--DEBUG
	-- love.graphics.setColor(255,255,255)
	-- love.graphics.print(mx..", "..my, 10, 5)
	-- love.graphics.print("FPS: "..FPS, 10, 20)
end

function setColorAndDrawCell(x, y, r, g, b)
	love.graphics.setColor(r,g,b)
	love.graphics.rectangle("fill", x * cellSize - cellSize, y * cellSize - cellSize, cellSize, cellSize)
end

function love.keypressed(key)
	--DEBUG
	-- if key == "escape" then
	-- 	love.event.quit()
	-- end
	
	-- if stageNames[stageNumber] == "Credits" then
	-- 	print("the end!")
	-- 	love.event.quit()
	if stageSolutions[stageNumber] == "*" then
		-- no-op
	else
		if key == stageSolutions[stageNumber] then
			print("winner")
			stageNumber = stageNumber + 1
		else
			print("nope")
			stageNumber = 1
		end
	
		print("loading "..stageNames[stageNumber])
		_G["load"..stageNames[stageNumber].."Stage"]()
	end
end

-- TODO unload previous stage? junk like animals might be bad

----------------------------------------------------------------------------------------------------- HEAT

function loadHeatStage()
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			cells[i][j] = {heat = 0, material = 1, conductivity = 0.995}--math.random()}--i+j
		end
	end

	-- -- the cold spot (letter)
	-- for i=40, 50 do
	-- 	for j=40, 50 do
	-- 		-- cells[i][j].material = 1.5
	-- 		-- cells[i][j].conductivity = 0.996
	-- 		cells[i][j].conductivity = 1 - 0.0000005 * (i * j * 10) --pretty DEBUGGY, just experimenting with conductivity gradients
	-- 	end
	-- end
	
	--letter = E
	local where = {		
		50, 50,  50, 51,  50, 52,  50, 53,  50, 54,  50, 55,
		52, 50,  52, 51,
		54, 50,  54, 51,  54, 52,  54, 53,  54, 54,
		56, 50,  56, 51,
		58, 50,  58, 51,  58, 52,  58, 53,  58, 54,  58, 55,
	}
	for i=1, 42, 2 do
		cells[where[i]][where[i+1]].conductivity = 0.99
		cells[where[i]+1][where[i+1]].conductivity = 0.99
	end
end

function updateForHeatStage(y, x, dt)
	--heat current tile & surrounding tiles
	if 0 < x and x <= mapSize and 0 < y and y <= mapSize then
		for i=1, mapSize do
			for j=1, mapSize do
				diff = math.abs(i - y) + math.abs(j - x)
				if diff < 8 then
					-- print(i..", "..j..", "..diff)
					heatCell(i, j, 128 - 16 * diff, dt)
				end
			end
		end
	end
	
	-- cool cells
	for i=1, mapSize do
		for j=1, mapSize do
			-- cells[i][j].heat = cells[i][j].heat * math.pow(0.99, cells[i][j].material) -- using pow() seems expensive...
			cells[i][j].heat = cells[i][j].heat * cells[i][j].conductivity--math.pow(0.99, cells[i][j].material)
		end
	end
end

--TODO use setColorAndDrawCell
function drawForHeatStage()
	-- draw cells
	for i=1, mapSize do
		for j=1, mapSize do
			local heat = cells[i][j].heat
			setColorAndDrawCell(j, i, heat * 4, heat * 2 + 64, heat * 2 + 64)
		end
	end
end

-- -- TODO compare to current, naive updateForHeatStage algo for efficiency (check FPS)
-- function heatCellsAroundOld(y, x, dt)
-- 	heatCell(x, y, 150, dt)
--
-- 	--cells to the north
-- 	if 1 < y then
-- 		heatCell(x, y - 1, 100, dt)
-- 	end
-- 	-- cells to the west
-- 	if 1 < x then
-- 		heatCell(x - 1, y, 100, dt)
-- 	end
-- 	-- cells to the south
-- 	if y < mapSize then
-- 		heatCell(x, y + 1, 100, dt)
-- 	end
-- 	-- cells to the east
-- 	if x < mapSize then
-- 		heatCell(x + 1, y, 100, dt)
-- 	end
-- end

function heatCell(y, x, multiplier, dt)
	-- cells[y][x].heat = cells[y][x].heat + cells[y][x].conductivity * multiplier * dt
	cells[y][x].heat = cells[y][x].heat + cells[y][x].material * multiplier * dt
end

----------------------------------------------------------------------------------------------------- RAIN


--TODO maybe just use objects for the rain. would be way cleaner.
function loadRainStage()
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			cells[i][j] = {wetness = 0, material = 0, flooded = false, special = false}--math.random()}--i+j
		end
	end
	
	seconds = 0
	wettest = 8

	-- for i=40, 50 do
	-- 	for j=40, 50 do
	-- 		-- cells[i][j].special = true
	-- 		cells[i][j].material = 1
	-- 		-- cells[i][j].wetness = 10
	-- 	end
	-- end
	-- cells[46][20].material = 1
	-- cells[51][21].material = 1
	-- cells[52][22].material = 1
	-- cells[52][23].material = 1
	-- cells[52][24].material = 1
	-- cells[51][25].material = 1
	-- cells[46][26].material = 1
	
	--letter = O
	local where = {
		30, 23,  30, 24,
		31, 22,  31, 23,  31, 24,  31, 25,
		32, 21,  32, 22,  32, 25,  32, 26,
		33, 20,  33, 21,  33, 26,  33, 27,
		34, 20,  34, 21,  34, 26,  34, 27,
		35, 20,  35, 21,  35, 26,  35, 27,
		36, 20,  36, 21,  36, 26,  36, 27,
		37, 21,  37, 22,  37, 25,  37, 26,
		38, 22,  38, 23,  38, 24,  38, 25,
		39, 23,  39, 24
	}
	for i=1, 72, 2 do
		cells[where[i]][where[i+1]].material = 1
	end
end

-- function updateForRainStageNew(y, x, dt)
-- 	seconds = seconds + dt
--
-- 	-- make a raindrop above cursor, more when y is lower, no more than 20 per second
-- 	if seconds > 0.075 and math.ceil(math.random(mapSize * 0.5)) > y then
-- 		variance = math.random(9) - 5
--
-- 		if 0 < x + variance and x + variance <= mapSize then
-- 			cells[1][x + variance].wetness = wettest
-- 		end
--
-- 		seconds = 0
-- 	end
--
-- 	-- descend rain (cells checked from bottom to top)
-- 	for j=1, mapSize do
-- 		for i=mapSize, 1, -1 do
--
-- 			if cells[i][j].special and cells[i][j].wetness >= wettest and (i < mapSize and cells[i + 1][j].flooded) then
-- 				cells[i][j].flooded = cells[i][j].special
-- 			elseif cells[i][j].wetness > 0 then
--
-- 				if i < mapSize then
-- 					cells[i + 1][j].wetness = cells[i][j].wetness
-- 				end
--
-- 				cells[i][j].wetness = cells[i][j].wetness - 1
-- 				-- end
-- 			end
-- 		end
-- 	end
-- end

function updateForRainStage(y, x, dt)
	seconds = seconds + dt
	
	-- make a raindrop above cursor, more when y is lower, no more than 20 per second
	if seconds > 0.075 and math.ceil(math.random(mapSize * 0.5)) > y then
		variance = math.random(9) - 5
		
		if 0 < x + variance and x + variance <= mapSize then
			cells[1][x + variance].wetness = 8
		end
		
		seconds = 0
	end
	
	-- descend rain (cells checked from bottom to top)
	for j=1, mapSize do
		for i=mapSize, 1, -1 do
			if cells[i][j].wetness > 0 then
				if i < mapSize then
					cells[i + 1][j].wetness = cells[i][j].wetness
				end
				
				cells[i][j].wetness = cells[i][j].wetness - 1
			end
		end
	end
end

-- function drawForRainStageNew()
-- 	-- draw cells
-- 	for i=1, mapSize do
-- 		for j=1, mapSize do
-- 			local r, g, b = 16, 16 + my * 2 + i, 32 + my * 5 + i * 2
--
-- 			-- if cells[i][j].material == 0 then
-- 				-- print(cells[i][j].flooded)
--
-- 				local wetness = cells[i][j].flooded and 1 or cells[i][j].wetness
-- 				setColorAndDrawCell(j, i, r + wetness * 10, g + wetness * 10, b + wetness * 16)
-- 			-- else
-- 				-- setColorAndDrawCell(j, i, r, g, b)
-- 			-- end
-- 		end
-- 	end
--
-- 	-- TODO thunder/lightning? :o
-- end

function drawForRainStage()
	-- draw cells
	for i=1, mapSize do
		for j=1, mapSize do
			local r, g, b = 16, 16 + my * 2 + i, 32 + my * 5 + i * 2
			
			if cells[i][j].material == 0 then
				local wetness = cells[i][j].wetness
				setColorAndDrawCell(j, i, r + wetness * 10, g + wetness * 10, b + wetness * 16)
			else
				-- setColorAndDrawCell(j, i, r, g, b)
				local wetness = cells[i][j].wetness
				setColorAndDrawCell(j, i, r + wetness * 30, g + wetness * 30, b + wetness * 48)
			end
		end
	end
	
	-- TODO lightning? crossfade between storm sounds and chirpy bird sounds depending on y? :o
end

----------------------------------------------------------------------------------------------------- ANIMALS

function loadAnimalsStage()
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			cells[i][j] = {material = 1 + math.floor(math.random() + .05)}
		end
	end
	
	seconds = 0
	
	numAnimals = 256
	animals = {}
	
	for i = 1, numAnimals do
		animals[i] = {y = math.random(mapSize - 1),
			type = "roller", introduced = false, 
			modR = math.random(32), modG = math.random(32), modB = math.random(32), modLightness = math.random(64),
			wy = 0, wx = 0,
			moving = false, distance = 0, animFrame = 0, maxFrames = math.random(12) + 12, fps = 0.04 + 0.04 * math.random(), dt = 0}
			
		if math.random(2) == 1 then
			animals[i].origin = "left"
			animals[i].x = -4
		else
			animals[i].origin = "right"
			animals[i].x = mapSize + 4
		end
	end
	
	-- make a few special ones
	for i = 1, numAnimals/8 do
		local a = animals[math.random(numAnimals)]
		a.modR = (math.random(4)-1) * 32
		a.modG = (math.random(4)-1) * 32
		a.modB = (math.random(4)-1) * 32
	end
	
	-- make the shape using destinations
	for i = 1, 64 do
		animals[i].destinationX = math.floor(i/2) + 14 + math.random(4)
		animals[i].y = math.floor(i/2) + 14 + math.random(4)
		
		animals[i+64].destinationX = 14 + math.random(4)
		animals[i+64].y = math.floor(i/2) + 14 + math.random(4)
		
		animals[i+128].destinationX = 46 + math.random(4)
		animals[i+128].y = math.floor(i/2) + 14 + math.random(4)
	end
end

function updateForAnimalsStage(y, x, dt)
	seconds = seconds + dt
	
	--introduce a new animal
	if seconds >= .25 then
		local a = animals[math.random(numAnimals)]
		a.moving = not a.introduced		
		a.introduced = true
		seconds = 0
	end
	
	-- wiggle one animal
	local w = animals[math.random(numAnimals)]
	if w.x ~= w.destinationX then--and w.wigglable then
		wiggleAnimal(w)
	end
	
	--move all animals
	for i = 1, numAnimals do
		local a = animals[i]
		a.dt = a.dt + dt
		
		if a.x ~= a.destinationX then
			if a.moving then
				--already moving
				if a.dt >= a.fps then
					a.dt = 0
					moveAnimal(a)
				end
			else
				--little nudge?
				if a.type == "roller" then
					if (a.x == x or a.x + 1 == x) and (a.y == y or a.y + 1 == y) then					
						a.dt = 0
						a.moving = true
						moveAnimal(a)
					end
				end
			end
		end
	end
end

function moveAnimal(a)
	if a.origin == "left" then
		-- if a.type == "roller" then
			a.x = a.x + 1
		-- end
	elseif a.origin == "right" then
		-- if a.type == "roller" then
			a.x = a.x - 1
		-- end
	end
	
	-- a.distance = a.distance + 1
	a.animFrame = a.animFrame + 1
	if a.animFrame >= a.maxFrames then --or a.distance >= a.maxDistance then
		a.moving = false
		-- a.distance = 0
		a.animFrame = 0
	end
end

function wiggleAnimal(a)
	local mode = math.random(4)
	if mode == 1 and a.wy > -1 then
		a.y = a.y - 1
		a.wy = a.wy - 1
	elseif mode == 2 and a.wy < 1 then
		a.y = a.y + 1
		a.wy = a.wy + 1
	elseif mode == 3 and a.wx > -1 then
		a.x = a.x - 1
		a.wx = a.wx - 1
	elseif mode == 4 and a.wx < 1 then
		a.x = a.x + 1
		a.wx = a.wx + 1
	end	
end

function drawForAnimalsStage()
	-- draw cells
	for i=1, mapSize do
		for j=1, mapSize do
			local r, g, b = 192, 224, 128
			
			if cells[i][j].material == 1 then
				setColorAndDrawCell(j, i, r, g, b)
			else
				setColorAndDrawCell(j, i, r + 8, g + 16, b)
			end
		end
	end
	
	-- draw animals
	for i = 1, numAnimals do
		if animals[i].type == "roller" then
			drawAnimal(animals[i])
		end
	end	
end

function drawAnimal(a)
	if a.type == "roller" then
		local r, g, b = 96 + a.modR + a.modLightness, 32 + a.modG + a.modLightness, 0 + a.modB + a.modLightness
		setColorAndDrawCell(a.x, a.y, r, g, b)
		setColorAndDrawCell(a.x + 1, a.y, r, g, b)
		setColorAndDrawCell(a.x, a.y + 1, r, g, b)
		setColorAndDrawCell(a.x + 1, a.y + 1, r, g, b)
		-- love.graphics.rectangle(a.x, a.y, 0, 0, 0)
	end
end

----------------------------------------------------------------------------------------------------- NAVIGATION

function loadNavigationStage()
	halfMapSize = mapSize / 2
	bigMapSize = mapSize * 32
	mapOffsetX = (bigMapSize - mapSize) / 2
	mapOffsetY = (bigMapSize - mapSize) / 2
	xVelocity = 0
	yVelocity = 0
	speed = 8
	
	mapCells = {}
	for i=1, bigMapSize do
		mapCells[i] = {}
		for j=1, bigMapSize do
			mapCells[i][j] = math.random(16) + 256 * ((1/j) + (1/i) + (1/(bigMapSize - j + 1)) + (1/(bigMapSize - i + 1)))
		end
	end	
	
	--the letter
	-- mapCells[1][1] = 0
	-- mapCells[bigMapSize][bigMapSize] = 0
	
	--letter = M
	local where = {
		20, 20,  20, 24,
		21, 20,  21, 21,  21, 23,  21, 24, 
		22, 20,  22, 22,  22, 24, 
		23, 20,  23, 24, 
		24, 20,  24, 24
	}
	for i=1, 26, 2 do
		mapCells[where[i]][where[i+1]] = 0
	end
end

function updateForNavigationStage(y, x, dt)
	mapOffsetX = mapOffsetX + (x - halfMapSize) * dt * speed
	mapOffsetY = mapOffsetY + (y - halfMapSize) * dt * speed
	
	xVelocity = math.floor(mapOffsetX)
	yVelocity = math.floor(mapOffsetY)
	
	--TODO animate ground? maybe even make the lasers pulse a little?
end

function drawForNavigationStage()
	for i=1, mapSize do
		for j=1, mapSize do
			local light = mapCells[(j + yVelocity) % bigMapSize + 1][(i + xVelocity) % bigMapSize + 1]
			setColorAndDrawCell(i, j, light * 2, 64 + light * 1, light * 2)
		end
	end
end

----------------------------------------------------------------------------------------------------- THREAD

function loadThreadStage()
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			cells[i][j] = {material = 1 + math.random()}
		end
	end	
	
	-- --the hidden letter
	-- for i=40, 50 do
	-- 	for j=40, 50 do
	-- 		cells[i][j].material = 0
	-- 	end
	-- end
	
	--letter = N
	for i=10, 17 do
		cells[i][10].material = 0
		cells[i][11].material = 0
	end
	for i=10, 17 do
		cells[i][16].material = 0
		cells[i][17].material = 0
	end
	for i=11, 14 do
		cells[i][i+1].material = 0
		cells[i+1][i+1].material = 0
		cells[i+2][i+1].material = 0
	end
	
	threadPieces = {}
	numThreads = 0
	maxThreads = 256
	
	letterPieces = {}
	numLetterPieces = 0 -- for SUMMER UPDATE. note no maximum!
	
	lastX = mapSize / 2 -- DEBUG
	lastY = mapSize / 2
	-- weight = math.random() * 2 + 0.5
	
	--for color oscillation. calculating sines here saves processing time later
	sins = {}
	numSins = 100
	for i=0, numSins do
		sins[i] = (math.sin(math.pi * 2 * i / numSins)) * 16 + 16
	end
	colorWave = 1
	rWave, gWave, bWave = 0, 0, 0
	seconds = 0
end

function updateForThreadStage(y, x, dt)
	seconds = seconds + dt
	
	--change colors
	if seconds > 0.02 then
	  seconds = seconds - 0.02
		colorWave = colorWave + 1
		rWave = sins[math.floor(colorWave/7) % numSins + 1]
		gWave = sins[math.floor(colorWave/3) % numSins + 1]
		bWave = sins[math.floor(colorWave/5) % numSins + 1]
	end
	
	--add new thread segments
	local diffX = x - lastX
	local diffY = y - lastY
	weight = math.random() + 1.5
	
	if math.abs(diffX) > 1 or math.abs(diffY) > 1 then
		local dx = 0
		local dy = 0
		local stepCount = 1

		--there'll be more vertically or horizontally, which is it? or are they equal
		if math.abs(diffX) > math.abs(diffY) then
			dx = math.abs(diffX) / diffX
			dy = diffY / diffX * math.abs(diffX) / diffX
			stepCount = math.abs(diffX)			
		elseif math.abs(diffY) > math.abs(diffX) then
			dx = diffX / diffY * math.abs(diffY) / diffY
			dy = math.abs(diffY) / diffY 
			stepCount = math.abs(diffY)		
		else
			dx = math.abs(diffX) / diffX
			dy = math.abs(diffY) / diffY
			stepCount = math.abs(diffX)
		end
		
		--remove dead threads if necessary
		for i=0, stepCount - 1 do
			addThreadPiece(lastY, lastX, dy, dx, i)
			removeOldestThreadPiece()
		end
	elseif lastX ~= x or lastY ~= y then		
		addThreadPiece(lastY, lastX, 0, 0, 1)
		removeOldestThreadPiece()
	end
	
	--let thread pieces flutter down
	for i=1,numThreads do
		local t = threadPieces[i]
		t.fall = t.fall + t.weight * dt
		if t.fall > 1 then
			t.fall = t.fall - 1
			t.ty = t.ty + 1
		end
	end
	
	lastX = x
	lastY = y
end

function addThreadPiece(lastY, lastX, dy, dx, i) -- better to NOT pass lastY/X? would be nice to simplify... TODO
	local ty = lastY + math.floor(i * dy + 0.5)
	local tx = lastX + math.floor(i * dx + 0.5) 
	
	--SUMMER UPDATE: if material == 0, insert thread pieces to a different table that gets drawn but doesn't get purged
	if cells[ty][tx].material == 0 then
		table.insert(letterPieces, 1, {ty = ty, tx = tx,
			fall = 0, weight = cells[ty][tx].material,
			tr = rWave * 8, tg = gWave * 8, tb = bWave * 8})
		
		numLetterPieces = numLetterPieces + 1	
	else
		table.insert(threadPieces, 1, {ty = ty, tx = tx,
			fall = 0, weight = cells[ty][tx].material,
			tr = rWave * 8, tg = gWave * 8, tb = bWave * 8})
		
		numThreads = numThreads + 1	
	end
end

function removeOldestThreadPiece()
	if (numThreads > maxThreads) then
		table.remove(threadPieces)
		numThreads = numThreads - 1 -- shouldn't there be a better way to do this? seems sloppy, but getn() failed me...
	end
end

function drawForThreadStage()
	love.graphics.setColor(rWave, gWave, bWave)
	love.graphics.rectangle("fill", 0, 0, mapSize * cellSize, mapSize * cellSize)
	
	--draw dat letter. SUMMER UPDATE!!
	for i = numLetterPieces, 1, -1 do
		local t = letterPieces[i]
		setColorAndDrawCell(t.tx, t.ty, t.tr, t.tg, t.tb)
	end

	--draw backwards so that newest appear on top
	for i = numThreads, 1, -1 do
		local t = threadPieces[i]
		setColorAndDrawCell(t.tx, t.ty, t.tr, t.tg, t.tb)
	end
end

----------------------------------------------------------------------------------------------------- ELECTRICITY

function loadElectricityStage()
	wallNumber = 8
		--
	-- for i=1, mapSize do
	-- 	cells[i] = {}
	-- 	for j=1, mapSize do
	-- 		if i % 2 == 1 and j % 2 == 1 then
	-- 			cells[i][j] = math.random(wallNumber - 1)
	-- 		else
	-- 			cells[i][j] = wallNumber
	-- 		end
	-- 	end
	-- end
	
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			if i % 2 == 1 and j % 2 == 1 then
				cells[i][j] = {m = math.random(wallNumber - 1), charge = 0}
			else
				cells[i][j] = {m = wallNumber, charge = 0}
			end
		end
	end

	--break walls adjacent to cells
	for i=1, mapSize, 2 do
		for j=1, mapSize, 2 do
			-- cells[i][j] = 90
			-- print(i.." "..j.." "..cells[i][j])
			--north
			if cells[i-1] and (cells[i][j].m == 1 or cells[i][j].m == 2 or cells[i][j].m == 3) then
				cells[i-1][j].m = cells[i][j].m
			end
			--south
			if cells[i+1] and (cells[i][j].m == 2 or cells[i][j].m == 4 or cells[i][j].m == 6) then
				cells[i+1][j].m = cells[i][j].m
			end
			--east
			if cells[i][j+1] and (cells[i][j].m == 1 or cells[i][j].m == 4 or cells[i][j].m == 5) then
				cells[i][j+1].m = cells[i][j].m
			end
			--west
			if cells[i][j-1] and (cells[i][j].m == 3 or cells[i][j].m == 5 or cells[i][j].m == 6) then
				cells[i][j-1].m = cells[i][j].m
			end
		end
	end

	-- for i=40, 50 do
	-- 	for j=40, 50 do
	-- 		-- cells[i][j].special = true
	-- 		cells[i][j].material = 1
	-- 		-- cells[i][j].wetness = 10
	-- 	end
	-- end
	
	seconds = 0
	animSeconds = 0
	
	numSparks = 0
	sparks = {}
	maxCharge = 100
	
	-- for i=10, 20 do
	-- 	for j=40, 50 do
	-- 		cells[i][j].charge = -100000
	-- 	end
	-- end
	
	--letter = O
	local where = {
		10, 43,  10, 44,
		11, 42,  11, 43,  11, 44,  11, 45,
		12, 41,  12, 42,  12, 45,  12, 46,
		13, 40,  13, 41,  13, 46,  13, 47,
		14, 40,  14, 41,  14, 46,  14, 47,
		15, 40,  15, 41,  15, 46,  15, 47,
		16, 40,  16, 41,  16, 46,  16, 47,
		17, 41,  17, 42,  17, 45,  17, 46,
		18, 42,  18, 43,  18, 44,  18, 45,
		19, 43,  19, 44
	}
	for i=1, 72, 2 do
		cells[where[i]][where[i+1]].charge = -100000
	end
	
	-- cells[46][20].material = 1
	-- cells[51][21].material = 1
	-- cells[52][22].material = 1
	-- cells[52][23].material = 1
	-- cells[52][24].material = 1
	-- cells[51][25].material = 1
	-- cells[46][26].material = 1
end

function updateForElectricityStage(y, x, dt)
	seconds = seconds + dt
	animSeconds = animSeconds + dt
	
	--add a spark
	if seconds > 0.125 then
	-- table.insert(sparks, {x = math.random(mapSize), y = math.random(mapSize), charge = 128})
		table.insert(sparks, {x = x, y = y, charge = 128})
		numSparks = numSparks + 1
	
		seconds = 0
	end
	
	--move the sparks
	if animSeconds > 0.01 then
		for i = 1, numSparks do
			local s = sparks[i]
			local least = maxCharge
			-- local leastDir
			local chaos = 0--math.random() - 0.5
			
			local dir = 0--math.random(4)
			
			if cells[s.y-1] 
			and cells[s.y-1][s.x].charge + cells[s.y-1][s.x].m + chaos < least then
				-- print("north is least")
				least = cells[s.y-1][s.x].charge + cells[s.y-1][s.x].m
				dir = 1
			end

			if cells[s.y][s.x+1] 
			and cells[s.y][s.x+1].charge + cells[s.y][s.x+1].m + chaos < least then
				least = cells[s.y][s.x+1].charge + cells[s.y][s.x+1].m
				dir = 2
				-- print("east is least")
			end
		
			if cells[s.y+1] 
			and cells[s.y+1][s.x].charge + cells[s.y+1][s.x].m + chaos < least then
				-- print("south is least")
				least = cells[s.y+1][s.x].charge + cells[s.y+1][s.x].m
				dir = 3
			end
	--
			if cells[s.y][s.x-1] 
			and cells[s.y][s.x-1].charge + cells[s.y][s.x-1].m + chaos < least then
				least = cells[s.y][s.x-1].charge + cells[s.y][s.x-1].m
				dir = 4
				-- print("west is least")
			end
		
			if dir == 1 then 
				cells[s.y-1][s.x].charge = cells[s.y-1][s.x].charge + s.charge
				s.y = s.y - 1
			elseif dir == 2 then 
				cells[s.y][s.x+1].charge = cells[s.y][s.x+1].charge + s.charge
				s.x = s.x + 1
			elseif dir == 3 then 
				cells[s.y+1][s.x].charge = cells[s.y+1][s.x].charge + s.charge
				s.y = s.y + 1
			elseif dir == 4 then 
				cells[s.y][s.x-1].charge = cells[s.y][s.x-1].charge + s.charge
				s.x = s.x - 1
			end
		
			s.charge = s.charge - 1
		
			animSeconds = 0
		end
	
		-- print (numSparks.." before")

		--kill old sparks
		for i = 1, numSparks - 1 do
			-- print (i.." out of "..table.getn(sparks))
			if sparks[i].charge <= 0 then
				table.remove(sparks, i)
				numSparks = numSparks - 1
			end
		end
	
		-- print (numSparks.." after")
	end

	-- fade cells
	for i=1, mapSize do
		for j=1, mapSize do
			if cells[i][j].charge > 0 then
				cells[i][j].charge = cells[i][j].charge - 3
			end
		end
	end
end

function drawForElectricityStage()
	-- draw cells
	for i=1, mapSize do
		for j=1, mapSize do
			-- local r, g, b = 16, 16 + my * 2 + i, 32 + my * 5 + i * 2
			
			-- if cells[i][j].material == 0 then
				-- local wetness = cells[i][j].material
				-- setColorAndDrawCell(j, i, r + wetness * 10, g + wetness * 10, b + wetness * 16)
			-- else
				if cells[i][j].m == wallNumber then
					setColorAndDrawCell(j, i, 0, 0, 32)
				else
					setColorAndDrawCell(j, i, cells[i][j].charge, cells[i][j].charge, 32)--32, 32, 32)--128 - cells[i][j] * 16, cells[i][j], cells[i][j])--
				end
			-- end
		end
	end
	
	for i=1, numSparks do
		local s = sparks[i]
		setColorAndDrawCell(s.x, s.y, s.charge * 2, s.charge * 2, s.charge)
	end
	
	-- TODO lightning? crossfade between storm sounds and chirpy bird sounds depending on y? :o
end

----------------------------------------------------------------------------------------------------- FOIL

function loadFoilStage()
	-- halfMapSize = mapSize / 2
	-- bigMapSize = mapSize * 32
	-- mapOffsetX = (bigMapSize - mapSize) / 2
	-- mapOffsetY = (bigMapSize - mapSize) / 2
	-- xVelocity = 0
	-- yVelocity = 0
	-- speed = 8
	
	-- initialize all foil cells
	for i=1, mapSize do
		cells[i] = {}
		for j=1, mapSize do
			cells[i][j] = {height = math.random(32) + 32, bump = 0, shine = 0} --+ 256 * ((1/j) + (1/i) + (1/(bigMapSize - j + 1)) + (1/(bigMapSize - i + 1)))
		end
	end	
	
	--make 'em shiny
	for i=1, mapSize do
		for j=1, mapSize do
			cells[i][j].shine = calculateShine(i, j)-- = {height = math.random(32) + 32, bump = 0, shine = 0} --+ 256 * ((1/j) + (1/i) + (1/(bigMapSize - j + 1)) + (1/(bigMapSize - i + 1)))
		end
	end	
	
	--make the letter
	-- for i=40, 50 do
	-- 	-- cells[math.random(mapSize)][math.random(mapSize)].bump = math.random(10) -- kinda DEBUG...but maybe i like it
	-- 	for j=40, 50 do
	-- 		cells[i][j].bump = 10
	-- 	end
	-- end
	
	
	--letter = U
	local where = {
		42, 20,  42, 21,  42, 26,  42, 27,
		43, 20,  43, 21,  43, 26,  43, 27,
		44, 20,  44, 21,  44, 26,  44, 27,
		45, 20,  45, 21,  45, 26,  45, 27,
		46, 20,  46, 21,  46, 26,  46, 27,
		47, 20,  47, 21,  47, 22,  47, 25,  47, 26,  47, 27,
		48, 21,  48, 22,  48, 23,  48, 24,  48, 25,  48, 26,
		49, 22,  49, 23,  49, 24,  49, 25
	}
	
	for i=1, 72, 2 do
		cells[where[i]][where[i+1]].bump = 20
	end
	
	lastX = 0
	lastY = 0
	thumbSize = math.ceil(mapSize / 16)
end

function updateForFoilStage(y, x, dt)
	if lastX ~= x or lastY ~= y then
		-- if 0 < x and x <= mapSize and 0 < y and y <= mapSize then
			for i=1, mapSize do
				for j=1, mapSize do
					diff = math.abs(i - y) + math.abs(j - x)
					if diff < thumbSize then
						cells[i][j].height = cells[i][j].height / 4 + math.random(4) + cells[i][j].bump + diff --TODO if this. if it's low, don't add rando. makes it look jittery
						cells[i][j].shine = calculateShine(i, j)--, 128 - 16 * diff, dt)
					end
				end
			-- end
		end

		lastX, lastY = x, y
	end
	
	--TODO animate ground? maybe even make the lasers pulse a little?
end

function calculateShine(y, x)
	local shine = 0
	if cells[y-1] then shine = shine - cells[y-1][x].height end
	if cells[y][x+1] then shine = shine - cells[y][x+1].height end
	
	if cells[y][x-1] then shine = shine + cells[y][x-1].height end
	if cells[y+1] then shine = shine + cells[y+1][x].height end
	
	return shine
end

function drawForFoilStage()
	for i=1, mapSize do
		for j=1, mapSize do
			local h = cells[i][j].shine + 128
			setColorAndDrawCell(j, i, h, h, h)
		end
	end
end

----------------------------------------------------------------------------------------------------- LEAVES

function loadLeavesStage()
	numLeaves = 3 * 128
	tau = 2 * math.pi
	mapSizeOver4 = mapSize / 4 --debug
	
	lastX = 0
	lastY = 0
	windSpeed = 0
	
	--make grass
	for i = 1, mapSize do
		cells[i] = {}
		for j = 1, mapSize do
			cells[i][j] = math.random(16)
		end
	end

	--make all leaves w/o points
	leaves = {}
	for i = 1, numLeaves do
		leaves[i] = {--x = math.random(mapSize), y = math.random(mapSize), 
			zRotation = 0, dzr = math.random() * math.pi * 2,
			r = 192 + math.random(64), g = 96 + math.random(64), b = 64,
			offsetX = math.random(mapSizeOver4) - mapSizeOver4/2, offsetY = math.random(mapSizeOver4) - mapSizeOver4/2}
			
		leaves[i].distanceFromCenter = math.random() * 2/3 + 1/3
		-- TODO; also redefine zrSpeed as a factor of distance. is weight necessary, also, or is just zrSpeed sufficient?
		-- leaves[i].zrSpeed = math.random() / 8 + 0.005
		leaves[i].zrSpeed = 0.0625 / (leaves[i].distanceFromCenter + math.random())-- / 8 + 0.005
	end
	
	--letter = N
	for i = 1, 30, 3 do
		-- for j = 1, 10 do
			-- leaves[i + j].x = i
			-- leaves[i + j].y = j
			-- leaves[i + j].zrSpeed = 0.0
			-- leaves[i + j].distanceFromCenter = 0.5
			-- leaves[i + j].offsetX = j -- mapSizeOver4
			-- leaves[i + j].offsetY = i -- mapSizeOver4
			-- leaves[i + j].dzr = 0
			leaves[i].x = i
			leaves[i].y = j
			leaves[i].zrSpeed = 0.0
			leaves[i].distanceFromCenter = 0.5
			leaves[i].offsetX = i/3 -- mapSizeOver4
			leaves[i].offsetY = i/3 -- mapSizeOver4
			leaves[i].dzr = 0

			leaves[i+1].x = i
			leaves[i+1].y = j
			leaves[i+1].zrSpeed = 0.0
			leaves[i+1].distanceFromCenter = 0.5
			leaves[i+1].offsetX = 10 -- mapSizeOver4
			leaves[i+1].offsetY = i/3 -- mapSizeOver4
			leaves[i+1].dzr = 0

			leaves[i+2].x = i
			leaves[i+2].y = j
			leaves[i+2].zrSpeed = 0.0
			leaves[i+2].distanceFromCenter = 0.5
			leaves[i+2].offsetX = 0 -- mapSizeOver4
			leaves[i+2].offsetY = i/3 -- mapSizeOver4
			leaves[i+2].dzr = 0
		-- end
	end

	--add leaves' points randomly
	for i = 1, numLeaves, 3 do
		leaves[i].points = {math.random(8)}
		leaves[i+1].points = {math.random(8), math.random(8)}
		leaves[i+2].points = {math.random(8), math.random(8), math.random(8)}
	end
end

function updateForLeavesStage(y, x, dt)
	-- get windSpeed from cursor movement
	if lastX ~= x or lastY ~= y then
		local diff = math.abs(lastX - x) + math.abs(lastY - y)
		if windSpeed < 0.1 * diff then
			windSpeed = windSpeed + 0.01 * diff
		end
	end

	-- move leaves
	for i = 1, numLeaves do
		local l = leaves[i]
		
		--set leaf's x and y. can't really be simplified that much, but try later TODO
		l.x = (math.cos(l.dzr) * l.distanceFromCenter * mapSize + mapSize) / 2 + l.offsetX
		l.x = l.x - l.x % 1
		l.y = (math.sin(l.dzr) * l.distanceFromCenter * mapSize + mapSize) / 2 + l.offsetY
		l.y = l.y - l.y % 1
		
		-- if l.x < 0 or l.y < 0 or l.x > mapSize or l.y > mapSize then
		-- 	debugCountOfDistantLeaves = debugCountOfDistantLeaves + 1
		-- end
		
		-- print(i..": "..l.x.." "..l.y)
		
		--turn leaf
		-- l.dzr = l.dzr + l.zrSpeed * windSpeed --* dt
		l.dzr = (l.dzr + l.zrSpeed * windSpeed) % tau--* dt
		l.zRotation = math.floor(-0.5 - l.dzr)
	end
	
	-- print("debugCountOfDistantLeaves "..debugCountOfDistantLeaves)
	
	lastX = x
	lastY = y
	windSpeed = windSpeed * 0.95
	-- if windSpeed < 0.01 then windSpeed = 0 end
end

function drawForLeavesStage()
	-- love.graphics.setColor(48, 32, 16)
	-- love.graphics.rectangle("fill", 0, 0, mapSize * cellSize, mapSize * cellSize)

	for i = 1, mapSize do
		for j = 1, mapSize do
			setColorAndDrawCell(j, i, cells[i][j] + 64, cells[i][j] + 48, cells[i][j] + 16)
		end
	end
	
	for i = 1, numLeaves do
		local l = leaves[i]
		setColorAndDrawCell(l.x, l.y, l.r, l.g, l.b)
		setColorAndDrawCell(l.x, l.y + 1, l.r, l.g, l.b)
		setColorAndDrawCell(l.x + 1, l.y, l.r, l.g, l.b)
		setColorAndDrawCell(l.x + 1, l.y + 1, l.r, l.g, l.b)
	
		--draw points on leaf
		for j = 1, table.getn(l.points) do
			drawLeafPoint(l, (l.points[j] + l.zRotation) % 8 + 1)
		end
	end
end

function drawLeafPoint(l, p)
	if p == 1 then setColorAndDrawCell(l.x - 1, l.y, l.r, l.g, l.b)
	elseif p == 2 then setColorAndDrawCell(l.x - 1, l.y + 1, l.r, l.g, l.b)
	elseif p == 3 then setColorAndDrawCell(l.x, l.y + 2, l.r, l.g, l.b)
	elseif p == 4 then setColorAndDrawCell(l.x + 1, l.y + 2, l.r, l.g, l.b)
	elseif p == 5 then setColorAndDrawCell(l.x + 2, l.y + 1, l.r, l.g, l.b)
	elseif p == 6 then setColorAndDrawCell(l.x + 2, l.y,  l.r, l.g, l.b)
	elseif p == 7 then setColorAndDrawCell(l.x + 1, l.y - 1, l.r, l.g, l.b)
	elseif p == 8 then setColorAndDrawCell(l.x, l.y - 1, l.r, l.g, l.b)
	end
end

----------------------------------------------------------------------------------------------------- SHADOWS (light comes from cursor, only see shadows of "buildings")

----------------------------------------------------------------------------------------------------- HIDING (won't come out unless you move the cursor off the game)

----------------------------------------------------------------------------------------------------- SOUND

----------------------------------------------------------------------------------------------------- PAIN

----------------------------------------------------------------------------------------------------- WEIGHT ?

----------------------------------------------------------------------------------------------------- INSTRUCTIONS

function loadInstructionsStage()
	-- halfMapSize = mapSize / 2
	-- bigMapSize = mapSize * 32
	-- mapOffsetX = (bigMapSize - mapSize) / 2
	-- mapOffsetY = (bigMapSize - mapSize) / 2
	-- xVelocity = 0
	-- yVelocity = 0
	-- speed = 8
	--
	-- mapCells = {}
	-- for i=1, bigMapSize do
	-- 	mapCells[i] = {}
	-- 	for j=1, bigMapSize do
	-- 		mapCells[i][j] = math.random(16) + 256 * ((1/j) + (1/i) + (1/(bigMapSize - j + 1)) + (1/(bigMapSize - i + 1)))
	-- 	end
	-- end
	--
	-- --the letter TODO
	-- mapCells[1][1] = 0
	-- mapCells[bigMapSize][bigMapSize] = 0
	
	words = love.graphics.newImage("instructions c.png")
	overlay = love.graphics.newImage("overlay c.png")
	nearnessOfU = 0 --nearness of A now... whatevs *continues hacking*
end

function updateForInstructionsStage(y, x, dt)
	-- mapOffsetX = mapOffsetX + (x - halfMapSize) * dt * speed
	-- mapOffsetY = mapOffsetY + (y - halfMapSize) * dt * speed
	--
	-- xVelocity = math.floor(mapOffsetX)
	-- yVelocity = math.floor(mapOffsetY)
	--
	--TODO animate ground? maybe even make the lasers pulse a little?
	
	nearnessOfU = 256 * (1 - math.abs(x - 5) / mapSize - math.abs(y - 56) / mapSize)
end

function drawForInstructionsStage()
	-- for i=1, mapSize do
	-- 	for j=1, mapSize do
	-- 		local light = mapCells[(j + yVelocity) % bigMapSize + 1][(i + xVelocity) % bigMapSize + 1]
	-- 		setColorAndDrawCell(i, j, light * 2, 64 + light * 1, light * 2)
	-- 	end
	-- end
	
	
	love.graphics.setColor(256, 256, 256, 256)
	love.graphics.draw(words, 0, 0, 0, 1,1)--cellSize, cellSize)
	
	love.graphics.setColor(256, 256, 256, nearnessOfU)
	-- love.graphics.setColor((nearnessOfU % 2) * 250, (nearnessOfU % 3) * 150, (nearnessOfU % 5) * 50, 256) --whew, interaction also respects 64x64 resoultion. just making sure.
	love.graphics.draw(overlay, 0, 0, 0, 1,1)--cellSize, cellSize)
end

----------------------------------------------------------------------------------------------------- CREDITS

function loadCreditsStage()
	--set title to CORRECT
	love.window.setTitle("ANSWER: A NOUMENON")
	
	words = love.graphics.newImage("credits c.png")
	nearnessOfU = 0
end

function updateForCreditsStage(y, x, dt)
	seconds = seconds + dt
	
	if seconds > 0.2 then
	  seconds = seconds - 0.02
		colorWave = colorWave + 1
		rWave = sins[math.floor(colorWave) % numSins + 1] * 8
		gWave = 256 * y / mapSize--sins[math.floor(colorWave/3) % numSins + 1]
		bWave = 256 * x / mapSize--sins[math.floor(colorWave/5) % numSins + 1]
	end
end

function drawForCreditsStage()
	--draw, use mouse color

	love.graphics.setColor(rWave, gWave, bWave)
	love.graphics.draw(words, 0, 0, 0, 1,1)--cellSize, cellSize)
	-- love.graphics.rectangle("fill", 0, 0, mapSize * cellSize, mapSize * cellSize)
end