-- src/server/CoinSandbox.server.luau
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Wait for the main lobby to be built by the other script
local lobbyFolder = Workspace:WaitForChild("PetSimLobby", 10) or Workspace

--------------------------------------------------
-- 1. BUILD THE GIANT SANDBOX PLATFORM
--------------------------------------------------
local sandboxPart = Instance.new("Part")
sandboxPart.Name = "CoinSandbox"
-- 170x170 covers exactly half the surface area of the 240x240 Main Floor
sandboxPart.Size = Vector3.new(170, 1.5, 170)
-- Centered exactly in the middle of the Main Area
sandboxPart.Position = Vector3.new(0, 0.5, 0) 
sandboxPart.Anchored = true
sandboxPart.BrickColor = BrickColor.new("Sand")
sandboxPart.Material = Enum.Material.Sand
sandboxPart.Parent = lobbyFolder

--------------------------------------------------
-- 2. COIN PILE SPAWNER LOGIC
--------------------------------------------------
-- Increased max piles to 40 so the giant sandbox feels full!
local MAX_PILES = 40
local currentPiles = 0

local function spawnCoinPile()
	if currentPiles >= MAX_PILES then return end
	currentPiles = currentPiles + 1

	-- Create the Coin Pile
	local pile = Instance.new("Part")
	pile.Name = "CoinPile"
	pile.Shape = Enum.PartType.Cylinder
	pile.Size = Vector3.new(2, 6, 6) 
	pile.Orientation = Vector3.new(0, 0, 90)
	
	-- Pick a random spot inside the new massive 170x170 sandbox
	-- (We use -80 to 80 to keep them slightly away from the very edges)
	local randomX = math.random(-80, 80)
	local randomZ = math.random(-80, 80)
	pile.Position = sandboxPart.Position + Vector3.new(randomX, 1.5, randomZ)
	
	pile.Anchored = true
	pile.BrickColor = BrickColor.new("Bright yellow")
	pile.Material = Enum.Material.Neon
	pile.Parent = sandboxPart

	-- Pile Stats
	local health = 5      -- Takes 5 clicks to break
	local reward = 25     -- Gives 25 Coins when destroyed

	-- Add a Click Detector so the player can break it
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
	clickDetector.CursorIcon = "rbxasset://textures/ui/mouse/pointer.png"
	clickDetector.Parent = pile

	-- Handle the breaking mechanic
	clickDetector.MouseClick:Connect(function(player)
		health = health - 1
		
		-- Visual Feedback: Shrink the pile slightly every time it is clicked
		pile.Size = pile.Size * 0.85
		
		if health <= 0 then
			clickDetector:Destroy() 
			
			-- Give the player their coins
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local coins = leaderstats:FindFirstChild("Coins")
				if coins then
					coins.Value = coins.Value + reward
				end
			end
			
			-- Destroy the pile
			pile:Destroy()
			currentPiles = currentPiles - 1
			
			-- Wait 3 seconds, then spawn a new pile to replace it!
			task.delay(3, spawnCoinPile)
		end
	end)
end

--------------------------------------------------
-- 3. START SPAWNING
--------------------------------------------------
-- Spawn the initial batch of coin piles
for i = 1, MAX_PILES do
	spawnCoinPile()
end

print("Giant Centered Coin Sandbox loaded successfully!")