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
-- 2. HELPER FUNCTIONS: SCENERY & TREES
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

local function scatterDecorations(folder, zoneName, floorZ)
	local bushColor = BrickColor.new("Forest green")
	local rockColor = BrickColor.new("Medium stone grey")
	local rockMat = Enum.Material.Slate

	if zoneName == "Desert Area" then
		bushColor = BrickColor.new("Olive")
		rockColor = BrickColor.new("Sand")
	elseif zoneName == "Snow Area" then
		bushColor = BrickColor.new("White")
		rockColor = BrickColor.new("Pastel light blue")
		rockMat = Enum.Material.Ice
	elseif zoneName == "Lava Area" then
		bushColor = BrickColor.new("Really black")
		rockColor = BrickColor.new("Neon orange")
		rockMat = Enum.Material.Neon
	elseif zoneName == "Magic Area" then
		bushColor = BrickColor.new("Magenta")
		rockColor = BrickColor.new("Cyan")
		rockMat = Enum.Material.Neon
	elseif zoneName == "Void Area" then
		bushColor = BrickColor.new("Really black")
		rockColor = BrickColor.new("Royal purple")
		rockMat = Enum.Material.Neon
	end

	-- Scatter 20 Bushes per zone
	local bushesSpawned = 0
	while bushesSpawned < 20 do
		local rx = math.random(-110, 110)
		local rz = math.random(-110, 110)
		
		local isValid = true
		
		-- 1. Keep the center paths clear
		if math.abs(rx) <= 30 and math.abs(rz) <= 30 then
			isValid = false
		end
		
		-- 2. FIX: Keep the giant Coin Sandbox clear in the Main Area!
		-- The sandbox is 170x170, so we avoid anything between -90 and 90
		if zoneName == "Main Area" and math.abs(rx) <= 90 and math.abs(rz) <= 90 then
			isValid = false
		end
		
		if isValid then
			bushesSpawned = bushesSpawned + 1
			local bush = Instance.new("Part")
			bush.Name = "Bush"
			bush.Shape = Enum.PartType.Ball
			bush.Size = Vector3.new(math.random(6,12), math.random(5,9), math.random(6,12))
			bush.Position = Vector3.new(rx, bush.Size.Y/2, floorZ + rz)
			bush.Anchored = true
			bush.BrickColor = bushColor
			bush.Material = Enum.Material.SmoothPlastic
			bush.Parent = folder
		end
	end

	-- Scatter 15 Rocks/Crystals per zone
	local rocksSpawned = 0
	while rocksSpawned < 15 do
		local rx = math.random(-110, 110)
		local rz = math.random(-110, 110)
		
		local isValid = true
		
		if math.abs(rx) <= 30 and math.abs(rz) <= 30 then
			isValid = false
		end
		
		if zoneName == "Main Area" and math.abs(rx) <= 90 and math.abs(rz) <= 90 then
			isValid = false
		end
		
		if isValid then
			rocksSpawned = rocksSpawned + 1
			local rock = Instance.new("Part")
			rock.Name = "Rock"
			rock.Size = Vector3.new(math.random(3,8), math.random(3,8), math.random(3,8))
			rock.Position = Vector3.new(rx, rock.Size.Y/2, floorZ + rz)
			rock.Orientation = Vector3.new(math.random(0,360), math.random(0,360), math.random(0,360))
			rock.Anchored = true
			rock.BrickColor = rockColor
			rock.Material = rockMat
			rock.Parent = folder
		end
	end
end

--------------------------------------------------
-- 3. THE MASTER ZONE LIST
--------------------------------------------------
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

	for i, zone in ipairs(zoneData) do
		local floorZ = 240 - ((i - 1) * zoneSize)

		local floor = Instance.new("Part")
		floor.Name = "Floor_" .. zone.Name
		floor.Size = Vector3.new(zoneSize, 1, zoneSize)
		floor.Position = Vector3.new(0, 0, floorZ)
		floor.Anchored = true
		floor.BrickColor = zone.Color
		floor.Material = Enum.Material.SmoothPlastic
		floor.Parent = lobbyFolder
		
		local path = Instance.new("Part")
		path.Name = "Path_" .. zone.Name
		path.Size = Vector3.new(20, 1.1, zoneSize)
		path.Position = Vector3.new(0, 0, floorZ)
		path.Anchored = true
		path.BrickColor = BrickColor.new("Khaki")
		path.Material = Enum.Material.SmoothPlastic
		path.Parent = lobbyFolder

		local treePositions = {
			Vector3.new(-100, 0, floorZ + 90), Vector3.new(100, 0, floorZ + 90),
			Vector3.new(-100, 0, floorZ - 90), Vector3.new(100, 0, floorZ - 90)
		}
		for _, pos in ipairs(treePositions) do
			createTree(lobbyFolder, pos)
		end
		
		scatterDecorations(lobbyFolder, zone.Name, floorZ)

		if i > 1 then
			local gateZ = floorZ + (zoneSize / 2) 

			local payWall = Instance.new("Part")
			payWall.Name = "Gate_" .. i
			payWall.Size = Vector3.new(zoneSize, 60, 1) 
			payWall.Position = Vector3.new(0, 30, gateZ) 
			payWall.Anchored = true
			payWall.BrickColor = BrickColor.new("Really red")
			payWall.Material = Enum.Material.Neon
			payWall.Transparency = 0.4
			payWall.Parent = lobbyFolder

			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Back 
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
					wallText:Destroy() 

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
	-- GIANT OUTER WALLS WITH 3D TRIMS
	-- ==========================================
	local totalLength = totalZones * zoneSize
	local centerZ = 360 - (totalLength / 2) 

	local wallData = {
		{Size = Vector3.new(1, 60, totalLength), Pos = Vector3.new(-120, 30, centerZ)}, 
		{Size = Vector3.new(1, 60, totalLength), Pos = Vector3.new(120, 30, centerZ)},  
		{Size = Vector3.new(240, 60, 1), Pos = Vector3.new(0, 30, 360 - totalLength)},  
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
		
		local bottomTrim = Instance.new("Part")
		bottomTrim.Name = "BottomTrim"
		bottomTrim.Size = Vector3.new(data.Size.X == 1 and 4 or data.Size.X, 6, data.Size.Z == 1 and 4 or data.Size.Z)
		bottomTrim.Position = data.Pos - Vector3.new(0, 27, 0)
		bottomTrim.Anchored = true
		bottomTrim.BrickColor = BrickColor.new("Deep blue")
		bottomTrim.Material = Enum.Material.SmoothPlastic
		bottomTrim.Parent = lobbyFolder
		
		local topTrim = bottomTrim:Clone()
		topTrim.Name = "TopTrim"
		topTrim.Position = data.Pos + Vector3.new(0, 30, 0)
		topTrim.Parent = lobbyFolder
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
	spawnLocation.Position = Vector3.new(0, 1.15, 240) 
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Cyan")
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Parent = lobbyFolder

	print("Bug Fixed: Sandbox area kept perfectly clear!")
end

buildPetSimLobby()