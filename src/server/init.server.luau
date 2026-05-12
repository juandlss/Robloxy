-- src/server/init.server.luau
local Workspace = game:GetService("Workspace")

-- Helper function to create simple cartoony trees
local function createTree(folder, position)
	-- Tree Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(8, 2, 8) -- Height is 8, diameter is 2
	trunk.Orientation = Vector3.new(0, 0, 90) -- Stand it upright
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Anchored = true
	trunk.BrickColor = BrickColor.new("Brown")
	trunk.Material = Enum.Material.SmoothPlastic
	trunk.Parent = folder

	-- Tree Leaves (Spherical)
	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(10, 10, 10)
	leaves.Position = trunk.Position + Vector3.new(0, 5, 0)
	leaves.Anchored = true
	leaves.BrickColor = BrickColor.new("Lime green")
	leaves.Material = Enum.Material.SmoothPlastic
	leaves.Parent = folder
end

local function buildPetSimLobby()
	-- Create a folder to keep the Workspace organized
	local lobbyFolder = Instance.new("Folder")
	lobbyFolder.Name = "PetSimLobby"
	lobbyFolder.Parent = Workspace

	-- 1. Build the Main Grass Floor
	local floor = Instance.new("Part")
	floor.Name = "GrassFloor"
	floor.Size = Vector3.new(120, 1, 120)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Bright green")
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = lobbyFolder

	-- 2. Build Enclosing Walls (So players don't fall off)
	local wallOffsets = {
		Vector3.new(60, 10, 0), Vector3.new(-60, 10, 0),
		Vector3.new(0, 10, 60), Vector3.new(0, 10, -60)
	}
	local wallSizes = {
		Vector3.new(1, 20, 120), Vector3.new(1, 20, 120),
		Vector3.new(120, 20, 1), Vector3.new(120, 20, 1)
	}
	for i = 1, 4 do
		local wall = Instance.new("Part")
		wall.Name = "InvisibleWall_" .. i
		wall.Size = wallSizes[i]
		wall.Position = wallOffsets[i]
		wall.Anchored = true
		wall.Transparency = 1 -- Keep them invisible so it looks open
		wall.Parent = lobbyFolder
	end

	-- 3. Giant "Mythical Egg" Centerpiece
	local giantEgg = Instance.new("Part")
	giantEgg.Name = "GiantEgg"
	giantEgg.Shape = Enum.PartType.Ball
	giantEgg.Size = Vector3.new(15, 18, 15)
	giantEgg.Position = Vector3.new(0, 9, 0)
	giantEgg.Anchored = true
	giantEgg.BrickColor = BrickColor.new("Bright yellow")
	giantEgg.Material = Enum.Material.Neon
	giantEgg.Parent = lobbyFolder

	-- 4. Egg Hatching Area (Glowing Pods)
	local podXPositions = {-20, 0, 20}
	local podColors = {"Bright red", "Bright blue", "Magenta"}
	for i = 1, 3 do
		local pod = Instance.new("Part")
		pod.Name = "EggPod_" .. i
		pod.Shape = Enum.PartType.Cylinder
		pod.Size = Vector3.new(1, 8, 8)
		pod.Orientation = Vector3.new(0, 0, 90)
		pod.Position = Vector3.new(podXPositions[i], 0.5, -35)
		pod.Anchored = true
		pod.BrickColor = BrickColor.new(podColors[i])
		pod.Material = Enum.Material.Neon
		pod.Parent = lobbyFolder
	end

	-- 5. Leaderboard Placeholders
	local boardPositions = {Vector3.new(-30, 8, 45), Vector3.new(30, 8, 45)}
	for i, pos in ipairs(boardPositions) do
		local board = Instance.new("Part")
		board.Name = "Leaderboard_" .. i
		board.Size = Vector3.new(15, 15, 2)
		board.Position = pos
		board.Anchored = true
		board.BrickColor = BrickColor.new("Dark stone grey")
		board.Material = Enum.Material.SmoothPlastic
		board.Parent = lobbyFolder
	end

	-- 6. Add Cartoony Nature (Trees)
	local treePositions = {
		Vector3.new(-45, 0, -45), Vector3.new(45, 0, -45),
		Vector3.new(-45, 0, 45),  Vector3.new(45, 0, 45),
		Vector3.new(-40, 0, 0),   Vector3.new(40, 0, 0)
	}
	for _, pos in ipairs(treePositions) do
		createTree(lobbyFolder, pos)
	end

	-- 7. Create a Cartoony Spawn Location
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "LobbySpawn"
	spawnLocation.Shape = Enum.PartType.Cylinder
	spawnLocation.Size = Vector3.new(1, 12, 12)
	spawnLocation.Orientation = Vector3.new(0, 0, 90)
	spawnLocation.Position = Vector3.new(0, 0.5, 35)
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Cyan")
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Parent = lobbyFolder

	print("Pet Sim Lobby successfully generated!")
end

buildPetSimLobby()