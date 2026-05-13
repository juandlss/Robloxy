-- src/server/init.server.luau
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

--------------------------------------------------
-- 1. PLAYER DATA (COINS)
--------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 100 
	coins.Parent = leaderstats
end)

--------------------------------------------------
-- 2. HELPER FUNCTIONS
--------------------------------------------------
local function createTree(folder, position)
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(8, 2, 8) 
	trunk.Orientation = Vector3.new(0, 0, 90) 
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Anchored = true
	trunk.BrickColor = BrickColor.new("Brown")
	trunk.Material = Enum.Material.SmoothPlastic
	trunk.Parent = folder

	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(15, 15, 15) 
	leaves.Position = trunk.Position + Vector3.new(0, 6, 0)
	leaves.Anchored = true
	leaves.BrickColor = BrickColor.new("Lime green")
	leaves.Material = Enum.Material.SmoothPlastic
	leaves.Parent = folder
end

--------------------------------------------------
-- 3. LOBBY BUILDER
--------------------------------------------------
local function buildPetSimLobby()
	local lobbyFolder = Instance.new("Folder")
	lobbyFolder.Name = "PetSimLobby"
	lobbyFolder.Parent = Workspace

	-- ==========================================
	-- TWO MASSIVE SQUARE FLOORS (240x240 each)
	-- ==========================================
	local mainFloor = Instance.new("Part")
	mainFloor.Name = "MainFloor"
	mainFloor.Size = Vector3.new(240, 1, 240)
	mainFloor.Position = Vector3.new(0, 0, 0)
	mainFloor.Anchored = true
	mainFloor.BrickColor = BrickColor.new("Bright green")
	mainFloor.Material = Enum.Material.SmoothPlastic
	mainFloor.Parent = lobbyFolder

	local startFloor = Instance.new("Part")
	startFloor.Name = "StartFloor"
	startFloor.Size = Vector3.new(240, 1, 240) 
	startFloor.Position = Vector3.new(0, 0, 240) 
	startFloor.Anchored = true
	startFloor.BrickColor = BrickColor.new("Shamrock") 
	startFloor.Material = Enum.Material.SmoothPlastic
	startFloor.Parent = lobbyFolder

	-- ==========================================
	-- GIANT OUTER WALLS (Total length is 480)
	-- ==========================================
	local wallData = {
		{Size = Vector3.new(1, 60, 480), Pos = Vector3.new(-120, 30, 120)}, 
		{Size = Vector3.new(1, 60, 480), Pos = Vector3.new(120, 30, 120)},  
		{Size = Vector3.new(240, 60, 1), Pos = Vector3.new(0, 30, -120)},   
		{Size = Vector3.new(240, 60, 1), Pos = Vector3.new(0, 30, 360)}     
	}

	for i, data in ipairs(wallData) do
		local wall = Instance.new("Part")
		wall.Name = "OuterWall_" .. i
		wall.Size = data.Size
		wall.Position = data.Pos
		wall.Anchored = true
		wall.BrickColor = BrickColor.new("Light blue")
		wall.Material = Enum.Material.SmoothPlastic
		wall.Parent = lobbyFolder
	end

	-- ==========================================
	-- THE GIANT PAY WALL & PROMPT FIX
	-- ==========================================
	local payWall = Instance.new("Part")
	payWall.Name = "UnlockableGate"
	payWall.Size = Vector3.new(240, 60, 1) 
	payWall.Position = Vector3.new(0, 30, 120) 
	payWall.Anchored = true
	payWall.BrickColor = BrickColor.new("Really red")
	payWall.Material = Enum.Material.Neon
	payWall.Transparency = 0.4
	payWall.Parent = lobbyFolder

	-- FIX: Create an attachment to lower the prompt to ground level
	local promptAttachment = Instance.new("Attachment")
	-- Lowering it 25 studs from the center puts it 5 studs off the ground
	promptAttachment.Position = Vector3.new(0, -25, 0) 
	promptAttachment.Parent = payWall

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Unlock Main Area"
	prompt.ObjectText = "Cost: 50 Coins"
	prompt.HoldDuration = 1 
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 15 -- Increased range to make it easier to reach!
	prompt.Parent = promptAttachment -- Parented to the attachment, not the wall

	local gateCost = 50
	local gateOpened = false

	prompt.Triggered:Connect(function(player)
		if gateOpened then return end

		local leaderstats = player:FindFirstChild("leaderstats")
		local coins = leaderstats and leaderstats:FindFirstChild("Coins")

		if coins and coins.Value >= gateCost then
			coins.Value = coins.Value - gateCost
			gateOpened = true
			prompt:Destroy() 

			local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goal = {
				Position = payWall.Position + Vector3.new(0, 65, 0),
				Transparency = 1 
			}
			local tween = TweenService:Create(payWall, tweenInfo, goal)
			tween:Play()
			payWall.CanCollide = false 
		end
	end)

	-- ==========================================
	-- FIXING THE SPAWN POINT
	-- ==========================================
	for _, child in pairs(Workspace:GetChildren()) do
		if child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "LobbySpawn"
	spawnLocation.Shape = Enum.PartType.Cylinder
	spawnLocation.Size = Vector3.new(1, 16, 16)
	spawnLocation.Orientation = Vector3.new(0, 0, 90)
	spawnLocation.Position = Vector3.new(0, 1, 240) 
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Cyan")
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Parent = lobbyFolder

	-- ==========================================
	-- DECORATIONS
	-- ==========================================

	local treePositions = {
		Vector3.new(-100, 0, 150), Vector3.new(100, 0, 150), 
		Vector3.new(-100, 0, 330), Vector3.new(100, 0, 330), 
		Vector3.new(-100, 0, -90), Vector3.new(100, 0, -90), 
		Vector3.new(-100, 0, 90),  Vector3.new(100, 0, 90)   
	}
	for _, pos in ipairs(treePositions) do
		createTree(lobbyFolder, pos)
	end

	print("Gate interaction fixed successfully!")
end

buildPetSimLobby()