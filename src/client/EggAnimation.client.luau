-- src/client/EggAnimation.client.luau
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetData"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Helper function to add cartoony strokes
local function applyCartoonyStyle(uiElement)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Parent = uiElement
end

-- Wait for the remotes to be created by the server
local remotes = ReplicatedStorage:WaitForChild("PetRemotes", 10)
if not remotes then return end
local animRemote = remotes:WaitForChild("PlayHatchAnimation")

-- ==========================================
-- ANIMATION LOGIC
-- ==========================================
animRemote.OnClientEvent:Connect(function(hatchedPetName)
	local petInfo = PetData.Pets[hatchedPetName]
	if not petInfo then return end

	-- 1. Create a full-screen cinematic background
	local animGui = Instance.new("ScreenGui")
	animGui.Name = "HatchAnimationGui"
	animGui.DisplayOrder = 100 -- Forces this to show ON TOP of all other UI
	animGui.Parent = playerGui

	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 1 -- Starts invisible
	background.Parent = animGui

	-- Fade background in
	TweenService:Create(background, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()

	-- 2. Create the Egg Icon
	local displayIcon = Instance.new("TextLabel")
	displayIcon.Size = UDim2.new(0, 300, 0, 300)
	displayIcon.Position = UDim2.new(0.5, -150, 0.5, -150)
	displayIcon.BackgroundTransparency = 1
	displayIcon.Font = Enum.Font.SourceSans
	displayIcon.Text = "🥚" -- Starts as an egg
	displayIcon.TextSize = 0 -- Starts tiny so we can scale it up
	displayIcon.Parent = background

	-- Scale egg up to the screen
	local popInTween = TweenService:Create(displayIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 200})
	popInTween:Play()
	popInTween.Completed:Wait()

	-- 3. Shake the Egg (The suspense!)
	local shakeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true)
	for i = 1, 4 do
		-- Rotate left
		local shakeLeft = TweenService:Create(displayIcon, shakeInfo, {Rotation = -20})
		shakeLeft:Play()
		shakeLeft.Completed:Wait()
		
		-- Rotate right
		local shakeRight = TweenService:Create(displayIcon, shakeInfo, {Rotation = 20})
		shakeRight:Play()
		shakeRight.Completed:Wait()
	end

	-- Reset rotation before cracking
	displayIcon.Rotation = 0
	task.wait(0.2)

	-- 4. The Crack! (Flash screen white briefly)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flash.Parent = animGui
	
	TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	game:GetService("Debris"):AddItem(flash, 0.3)

	-- 5. Reveal the Pet!
	displayIcon.Text = petInfo.Icon
	displayIcon.TextSize = 250 -- Pop it slightly larger
	
	local bounceTween = TweenService:Create(displayIcon, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {TextSize = 200})
	bounceTween:Play()

	-- 6. Show the Pet Details (Name & Rarity)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 400, 0, 60)
	nameLabel.Position = UDim2.new(0.5, -200, 0.5, 80)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Text = hatchedPetName .. "!"
	nameLabel.TextColor3 = petInfo.Color -- Matches the pet's specific color!
	nameLabel.TextSize = 50
	applyCartoonyStyle(nameLabel)
	nameLabel.Parent = background

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(0, 400, 0, 40)
	rarityLabel.Position = UDim2.new(0.5, -200, 0.5, 140)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.FredokaOne
	rarityLabel.Text = string.upper(petInfo.Rarity)
	
	-- Special color for the rarity text
	if petInfo.Rarity == "Legendary" then
		rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Gold for legendary
	else
		rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	rarityLabel.TextSize = 30
	applyCartoonyStyle(rarityLabel)
	rarityLabel.Parent = background

	-- 7. Wait 3 seconds, then fade out and destroy the animation UI
	task.wait(3)
	
	local fadeOutInfo = TweenInfo.new(0.5)
	TweenService:Create(background, fadeOutInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(displayIcon, fadeOutInfo, {TextTransparency = 1}):Play()
	TweenService:Create(nameLabel, fadeOutInfo, {TextTransparency = 1}):Play()
	TweenService:Create(rarityLabel, fadeOutInfo, {TextTransparency = 1}):Play()
	
	task.wait(0.5)
	animGui:Destroy()
end)