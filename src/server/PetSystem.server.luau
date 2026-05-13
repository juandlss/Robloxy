-- src/server/PetSystem.server.luau
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData"))
local lobbyFolder = Workspace:WaitForChild("PetSimLobby", 10) or Workspace

-- ==========================================
-- 1. SETUP REMOTE EVENTS 
-- ==========================================
local remotes = ReplicatedStorage:FindFirstChild("PetRemotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "PetRemotes"
	remotes.Parent = ReplicatedStorage

	local hatchRemote = Instance.new("RemoteEvent", remotes)
	hatchRemote.Name = "HatchEgg"

	local equipRemote = Instance.new("RemoteEvent", remotes)
	equipRemote.Name = "EquipPet"

	local unequipRemote = Instance.new("RemoteEvent", remotes)
	unequipRemote.Name = "UnequipPet"

	local updateUIRemote = Instance.new("RemoteEvent", remotes)
	updateUIRemote.Name = "UpdateInventory"
	
	-- NEW: Remote to trigger the hatching animation
	local animRemote = Instance.new("RemoteEvent", remotes)
	animRemote.Name = "PlayHatchAnimation"
end

-- ==========================================
-- 2. BUILD THE GIANT EGG STAND
-- ==========================================
local eggStandFolder = Instance.new("Folder")
eggStandFolder.Name = "EggStands"
eggStandFolder.Parent = lobbyFolder

local step1 = Instance.new("Part")
step1.Size = Vector3.new(80, 3, 20)
step1.Position = Vector3.new(0, 2, 330) 
step1.Anchored = true
step1.BrickColor = BrickColor.new("White")
step1.Parent = eggStandFolder

local step2 = Instance.new("Part")
step2.Size = Vector3.new(80, 6, 20)
step2.Position = Vector3.new(0, 3.5, 350) 
step2.Anchored = true
step2.BrickColor = BrickColor.new("White")
step2.Parent = eggStandFolder

local basicEgg = Instance.new("Part")
basicEgg.Name = "Basic Egg"
basicEgg.Shape = Enum.PartType.Ball
basicEgg.Size = Vector3.new(12, 15, 12) 
basicEgg.Position = step1.Position + Vector3.new(0, (step1.Size.Y / 2) + 7.5, 0)
basicEgg.Anchored = true
basicEgg.BrickColor = BrickColor.new("Bright blue")
basicEgg.Material = Enum.Material.SmoothPlastic
basicEgg.Parent = eggStandFolder

-- Floating Price Label
local eggCost = PetData.Eggs["Basic Egg"].Cost
local priceBillboard = Instance.new("BillboardGui")
priceBillboard.Name = "PriceLabel"
priceBillboard.Size = UDim2.new(8, 0, 4, 0)
priceBillboard.StudsOffset = Vector3.new(0, (basicEgg.Size.Y / 2) + 3, 0) 
priceBillboard.AlwaysOnTop = true
priceBillboard.Parent = basicEgg

local priceText = Instance.new("TextLabel")
priceText.Size = UDim2.new(1, 0, 1, 0)
priceText.BackgroundTransparency = 1
priceText.Font = Enum.Font.FredokaOne
priceText.Text = "Basic Egg\n🪙 " .. tostring(eggCost)
priceText.TextColor3 = Color3.fromRGB(255, 255, 255)
priceText.TextSize = 28
priceText.Parent = priceBillboard

local textStroke = Instance.new("UIStroke")
textStroke.Thickness = 3
textStroke.Color = Color3.fromRGB(0, 0, 0)
textStroke.Parent = priceText

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Hatch"
prompt.ObjectText = "Basic Egg"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 15 
prompt.Parent = basicEgg

-- ==========================================
-- 3. PLAYER DATA
-- ==========================================
Players.PlayerAdded:Connect(function(player)
	local multiplier = Instance.new("NumberValue")
	multiplier.Name = "PetMultiplier"
	multiplier.Value = 1 
	multiplier.Parent = player
	
	local ownedPets = Instance.new("Folder")
	ownedPets.Name = "OwnedPets"
	ownedPets.Parent = player
end)

-- ==========================================
-- 4. HATCHING LOGIC
-- ==========================================
prompt.Triggered:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	local eggInfo = PetData.Eggs["Basic Egg"]
	
	if coins and coins.Value >= eggInfo.Cost then
		coins.Value = coins.Value - eggInfo.Cost
		
		local rng = math.random(1, 100)
		local hatchedPet = "Dog"
		if rng > 60 and rng <= 85 then hatchedPet = "Cat"
		elseif rng > 85 and rng <= 98 then hatchedPet = "Bunny"
		elseif rng > 98 then hatchedPet = "Dragon" end
		
		local newPet = Instance.new("StringValue")
		newPet.Name = hatchedPet
		newPet.Parent = player.OwnedPets
		
		-- Tell the client to update their UI AND play the animation!
		remotes.UpdateInventory:FireClient(player) 
		remotes.PlayHatchAnimation:FireClient(player, hatchedPet) 
	end
end)

-- ==========================================
-- 5. EQUIPPING & PHYSICS
-- ==========================================
local function clearEquippedPet(player)
	player.PetMultiplier.Value = 1 
	local oldPet = Workspace:FindFirstChild("EquippedPet_" .. player.Name)
	if oldPet then oldPet:Destroy() end
end

remotes.EquipPet.OnServerEvent:Connect(function(player, petName)
	if not player.OwnedPets:FindFirstChild(petName) then return end
	
	clearEquippedPet(player)
	player.PetMultiplier.Value = PetData.Pets[petName].Multiplier
	
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local petPart = Instance.new("Part")
	petPart.Name = "EquippedPet_" .. player.Name
	petPart.Shape = Enum.PartType.Block
	petPart.Size = Vector3.new(2, 2, 2)
	petPart.BrickColor = BrickColor.new(PetData.Pets[petName].Color)
	petPart.CanCollide = false
	petPart.Parent = Workspace
	
	local att0 = Instance.new("Attachment", petPart)
	local att1 = Instance.new("Attachment", char.HumanoidRootPart)
	att1.Position = Vector3.new(3, 2, 4) 
	
	local alignPos = Instance.new("AlignPosition")
	alignPos.Attachment0 = att0
	alignPos.Attachment1 = att1
	alignPos.Responsiveness = 15
	alignPos.Parent = petPart
	
	local alignOri = Instance.new("AlignOrientation")
	alignOri.Attachment0 = att0
	alignOri.Attachment1 = att1
	alignOri.Responsiveness = 15
	alignOri.Parent = petPart
end)

remotes.UnequipPet.OnServerEvent:Connect(function(player)
	clearEquippedPet(player)
end)