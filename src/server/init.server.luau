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
	coins.Value = 100 -- Starting coins
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
-- 3. THE MASTER ZONE LIST
--------------------------------------------------
-- You can easily add more zones here or change their prices!
local zoneData = {
	{Name = "Start Area", Color = BrickColor.new("Shamrock"), Cost = 0},
	{Name = "Main Area", Color = BrickColor.new("Bright green"), Cost = 50},
	{Name = "Desert Area", Color = BrickColor.new("Sand"), Cost = 500},
	{Name = "Snow Area", Color = BrickColor.new("White"), Cost = 2500},
	{Name = "Lava Area", Color = BrickColor.new("Neon orange"), Cost = 10000},
	{Name = "Magic Area", Color = BrickColor.new("Bright violet"), Cost = 50000},
	{Name = "Void Area", Color = BrickColor.new("Really black"), Cost = 250000}
}

--------------------------------------------------
-- 4. DYNAMIC LOBBY BUILDER
--------------------------------------------------
local function buildPetSimLobby()
	local lobbyFolder = Instance.new("Folder")
	lobbyFolder.Name = "PetSimLobby"
	lobbyFolder.Parent = Workspace

	local totalZones = #zoneData
	local zoneSize = 240

	-- Loop through our table and build the world automatically!
	for i, zone in ipairs(zoneData) do
		-- Calculate where this specific zone should be placed
		local floorZ = 240 - ((i - 1) * zoneSize)

		-- 1. Build the Floor
		local floor = Instance.new("Part")
		floor.Name = "Floor_" .. zone.Name
		floor.Size = Vector3.new(zoneSize, 1, zoneSize)
		floor.Position = Vector3.new(0, 0, floorZ)
		floor.Anchored = true
		floor.BrickColor = zone.Color
		floor.Material = Enum.Material.SmoothPlastic
		floor.Parent = lobbyFolder

		-- 2. Add Trees to the corners of this zone
		local treePositions = {
			Vector3.new(-100, 0, floorZ + 90), Vector3.new(100, 0, floorZ + 90),
			Vector3.new(-100, 0, floorZ - 90), Vector3.new(100, 0, floorZ - 90)
		}
		for _, pos in ipairs(treePositions) do
			createTree(lobbyFolder, pos)
		end

		-- 3. Build the Pay Wall (if it's not the starting area)
		if i > 1 then
			local gateZ = floorZ + (zoneSize / 2) -- Places it exactly between this zone and the previous one

			local payWall = Instance.new("Part")
			payWall.Name = "Gate_" .. i
			payWall.Size = Vector3.new(zoneSize, 60, 1) 
			payWall.Position = Vector3.new(0, 30, gateZ) 
			payWall.Anchored = true
			payWall.BrickColor = BrickColor.new("Really red")
			payWall.Material = Enum.Material.Neon
			payWall.Transparency = 0.4
			payWall.Parent = lobbyFolder

			-- NEW: Display text directly on the wall!
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Back -- Faces towards the player walking forward
			surfaceGui.CanvasSize = Vector2.new(1000, 300)
			surfaceGui.Parent = payWall

			local wallText = Instance.new("TextLabel")
			wallText.Size = UDim2.new(1, 0, 1, 0)
			wallText.BackgroundTransparency = 1
			wallText.Font = Enum.Font.FredokaOne
			wallText.Text = "Unlock " .. zone.Name .. "\nCost: " .. zone.Cost .. " 🪙"
			wallText.TextColor3 = Color3.fromRGB(255, 255, 255)
			wallText.TextSize = 80
			wallText.Parent = surfaceGui

			local textStroke = Instance.new("UIStroke")
			textStroke.Thickness = 6
			textStroke.Color = Color3.fromRGB(0, 0, 0)
			textStroke.Parent = wallText

			-- The Prompt
			local promptAttachment = Instance.new("Attachment")
			promptAttachment.Position = Vector3.new(0, -25, 0) 
			promptAttachment.Parent = payWall

			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Purchase"
			prompt.ObjectText = zone.Name
			prompt.HoldDuration = 1 
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = 15 
			prompt.Parent = promptAttachment 

			local gateOpened = false

			prompt.Triggered:Connect(function(player)
				if gateOpened then return end

				local leaderstats = player:FindFirstChild("leaderstats")
				local coins = leaderstats and leaderstats:FindFirstChild("Coins")

				if coins and coins.Value >= zone.Cost then
					coins.Value = coins.Value - zone.Cost
					gateOpened = true
					prompt:Destroy() 
					wallText:Destroy() -- Removes the text immediately so it doesn't float into the sky

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
		end
	end

	-- ==========================================
	-- GIANT OUTER WALLS (Dynamically calculates length!)
	-- ==========================================
	local totalLength = totalZones * zoneSize
	local centerZ = 360 - (totalLength / 2) -- Math to find the exact middle point of the giant compound

	local wallData = {
		{Size = Vector3.new(1, 60, totalLength), Pos = Vector3.new(-120, 30, centerZ)}, -- Left
		{Size = Vector3.new(1, 60, totalLength), Pos = Vector3.new(120, 30, centerZ)},  -- Right
		{Size = Vector3.new(240, 60, 1), Pos = Vector3.new(0, 30, 360 - totalLength)},  -- Very Front (End of Void)
		{Size = Vector3.new(240, 60, 1), Pos = Vector3.new(0, 30, 360)}                 -- Very Back (Start Area)
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

	print("Massive 7-Zone Map generated successfully!")
end

buildPetSimLobby()