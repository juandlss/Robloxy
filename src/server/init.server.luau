-- src/server/init.server.luau
local Workspace = game:GetService("Workspace")

local function buildDecoratedLobby()
	-- Create a folder to keep the Workspace organized
	local lobbyFolder = Instance.new("Folder")
	lobbyFolder.Name = "DecoratedLobby"
	lobbyFolder.Parent = Workspace

	-- 1. Build the Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(100, 1, 100)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Dark stone grey")
	floor.Material = Enum.Material.Slate
	floor.Parent = lobbyFolder

	-- 2. Build a Decorative Centerpiece (e.g., a glowing statue or fountain base)
	local centerpiece = Instance.new("Part")
	centerpiece.Name = "Centerpiece"
	centerpiece.Shape = Enum.PartType.Cylinder
	centerpiece.Size = Vector3.new(15, 8, 15)
	centerpiece.Position = Vector3.new(0, 4.5, 0)
	centerpiece.Anchored = true
	centerpiece.BrickColor = BrickColor.new("Toothpaste")
	centerpiece.Material = Enum.Material.Neon
	centerpiece.Parent = lobbyFolder
    centerpiece.Orientation = Vector3.new(0, 0, 90)

	-- 3. Add Some Decorative Pillars
	local pillarPositions = {
		Vector3.new(40, 10, 40),
		Vector3.new(-40, 10, 40),
		Vector3.new(40, 10, -40),
		Vector3.new(-40, 10, -40)
	}

	for i, pos in ipairs(pillarPositions) do
		local pillar = Instance.new("Part")
		pillar.Name = "Pillar_" .. i
		pillar.Size = Vector3.new(5, 20, 5)
		pillar.Position = pos
		pillar.Anchored = true
		pillar.BrickColor = BrickColor.new("Marble")
		pillar.Material = Enum.Material.Marble
		pillar.Parent = lobbyFolder
	end

	-- 4. Create a Spawn Location
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "LobbySpawn"
	spawnLocation.Size = Vector3.new(8, 1, 8)
	spawnLocation.Position = Vector3.new(0, 1, 30)
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Bright blue")
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Parent = lobbyFolder

	print("Decorated lobby successfully generated!")
end

-- Run the function when the server starts
buildDecoratedLobby()
