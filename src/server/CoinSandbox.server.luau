-- src/server/CoinSandbox.server.luau
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local lobbyFolder = Workspace:WaitForChild("PetSimLobby", 10) or Workspace

--------------------------------------------------
-- 1. BUILD THE GIANT SANDBOX PLATFORM
--------------------------------------------------
local sandboxPart = Instance.new("Part")
sandboxPart.Name = "CoinSandbox"
sandboxPart.Size = Vector3.new(170, 1.5, 170)
sandboxPart.Position = Vector3.new(0, 0.5, 0) 
sandboxPart.Anchored = true
sandboxPart.BrickColor = BrickColor.new("Sand")
sandboxPart.Material = Enum.Material.Sand
sandboxPart.Parent = lobbyFolder

--------------------------------------------------
-- 2. LOOT SPAWNER LOGIC (Piles, Safes, & Vaults)
--------------------------------------------------
local MAX_PILES = 40
local currentPiles = 0

local function spawnLoot()
	if currentPiles >= MAX_PILES then return end
	currentPiles = currentPiles + 1

	local randomChance = math.random(1, 100)
	local isVault = randomChance <= 5 
	local isSafe = randomChance > 5 and randomChance <= 20 

	local loot = Instance.new("Part")
	
	local randomX = math.random(-80, 80)
	local randomZ = math.random(-80, 80)
	loot.Position = sandboxPart.Position + Vector3.new(randomX, 1.5, randomZ)
	loot.Anchored = true
	loot.Parent = sandboxPart

	local health = 0
	local maxHealth = 0 -- NEW: Track the starting health to calculate the bar percentage
	local reward = 0
	local hpOffset = 0  -- NEW: How high above the object the health bar should float

	-- ==========================================
	-- CONFIGURE LOOT STATS
	-- ==========================================
	if isVault then
		loot.Name = "Vault"
		loot.Shape = Enum.PartType.Block
		loot.Size = Vector3.new(12, 12, 12) 
		loot.BrickColor = BrickColor.new("Black")
		loot.Material = Enum.Material.Metal
		maxHealth = 20  
		reward = 100 
		hpOffset = 8 -- Floats high above the massive vault
		
	elseif isSafe then
		loot.Name = "Safe"
		loot.Shape = Enum.PartType.Block
		loot.Size = Vector3.new(6, 6, 6) 
		loot.BrickColor = BrickColor.new("Dark stone grey")
		loot.Material = Enum.Material.Neon
		maxHealth = 10  
		reward = 50  
		hpOffset = 5 -- Floats moderately high
		
	else
		loot.Name = "CoinPile"
		loot.Shape = Enum.PartType.Cylinder
		loot.Size = Vector3.new(2, 6, 6) 
		loot.Orientation = Vector3.new(0, 0, 90)
		loot.BrickColor = BrickColor.new("Bright yellow")
		loot.Material = Enum.Material.Neon
		maxHealth = 5   
		reward = 25  
		hpOffset = 4 -- Floats just above the coin pile
	end

	health = maxHealth -- Set current health to whatever the max is
	loot.Position = loot.Position + Vector3.new(0, loot.Size.Y / 2, 0)

	-- ==========================================
	-- CREATE THE HEALTH BAR UI
	-- ==========================================
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBarGui"
	billboard.Size = UDim2.new(4, 0, 0.8, 0) -- 4 studs wide
	billboard.StudsOffset = Vector3.new(0, hpOffset, 0) -- Places it above the object
	billboard.AlwaysOnTop = true -- Renders through other parts so you can always see it
	billboard.Enabled = false -- Keeps it completely invisible until hit!
	billboard.Parent = loot

	local bgFrame = Instance.new("Frame")
	bgFrame.Name = "Background"
	bgFrame.Size = UDim2.new(1, 0, 1, 0)
	bgFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Dark grey background
	bgFrame.BorderSizePixel = 2
	bgFrame.Parent = billboard

	local fillFrame = Instance.new("Frame")
	fillFrame.Name = "Fill"
	fillFrame.Size = UDim2.new(1, 0, 1, 0) -- Starts at 100% width
	fillFrame.BackgroundColor3 = Color3.fromRGB(85, 255, 127) -- Starts Bright Green
	fillFrame.BorderSizePixel = 0
	fillFrame.Parent = bgFrame

	-- ==========================================
	-- SOUND EFFECT & CLICK DETECTOR
	-- ==========================================
	local hitSound = Instance.new("Sound")
	hitSound.Name = "HitSound"
	hitSound.SoundId = "rbxassetid://514695994" 
	hitSound.Volume = 1 
	hitSound.RollOffMaxDistance = 150 
	hitSound.Parent = loot

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
	clickDetector.CursorIcon = "rbxasset://textures/ui/mouse/pointer.png"
	clickDetector.Parent = loot

	-- ==========================================
	-- BREAKING MECHANIC
	-- ==========================================
	clickDetector.MouseClick:Connect(function(player)
		health = health - 1
		hitSound:Play()
		
		-- 1. Show the health bar now that it has taken damage!
		billboard.Enabled = true

		-- 2. Update the health bar size and color
		local healthPercent = health / maxHealth
		fillFrame.Size = UDim2.new(healthPercent, 0, 1, 0)
		
		-- Bonus effect: The bar smoothly transitions from Green to Red as it takes damage
		local redColor = Color3.fromRGB(255, 85, 85)
		local greenColor = Color3.fromRGB(85, 255, 127)
		fillFrame.BackgroundColor3 = redColor:Lerp(greenColor, healthPercent)
		
		-- 3. Visual shrink feedback
		if isVault then
			loot.Size = loot.Size * 0.96 
		elseif isSafe then
			loot.Size = loot.Size * 0.92 
		else
			loot.Size = loot.Size * 0.85 
		end
		
		-- 4. Destroy logic
		if health <= 0 then
			clickDetector:Destroy() 
			billboard:Destroy() -- Instantly delete the health bar so it doesn't float over empty space
			
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local coins = leaderstats:FindFirstChild("Coins")
				if coins then
					coins.Value = coins.Value + reward
				end
			end
			
			currentPiles = currentPiles - 1
			task.delay(3, spawnLoot) 
			
			loot.Transparency = 1 
			loot.CanCollide = false
			Debris:AddItem(loot, 2)
		end
	end)
end

--------------------------------------------------
-- 3. START SPAWNING
--------------------------------------------------
for i = 1, MAX_PILES do
	spawnLoot()
end

print("Coin Sandbox with Dynamic Health Bars loaded!")