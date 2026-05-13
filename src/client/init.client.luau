-- src/client/init.client.luau
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1. MAIN UI CONTAINER
-- ==========================================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "PetSimHUD"
mainGui.ResetOnSpawn = false
mainGui.Parent = playerGui

local function applyCartoonyStyle(uiElement)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.15, 0)
	corner.Parent = uiElement
	
	if uiElement:IsA("TextLabel") or uiElement:IsA("TextButton") then
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2.5
		stroke.Color = Color3.fromRGB(0, 0, 0)
		stroke.Parent = uiElement
	end
end

-- ==========================================
-- 2. CURRENCY DISPLAY
-- ==========================================
local currencyContainer = Instance.new("Frame")
currencyContainer.Name = "CurrencyContainer"
currencyContainer.Size = UDim2.new(0, 200, 0, 50)
currencyContainer.Position = UDim2.new(0, 20, 1, -70) 
currencyContainer.BackgroundTransparency = 1
currencyContainer.Parent = mainGui

local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinDisplay"
coinLabel.Size = UDim2.new(1, 0, 1, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.Font = Enum.Font.FredokaOne 
coinLabel.Text = "🪙 0"
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0) 
coinLabel.TextSize = 28
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
applyCartoonyStyle(coinLabel)
coinLabel.Parent = currencyContainer

task.spawn(function()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if leaderstats then
		local coins = leaderstats:WaitForChild("Coins")
		coinLabel.Text = "🪙 " .. tostring(coins.Value)
		
		coins.Changed:Connect(function(newValue)
			coinLabel.Text = "🪙 " .. tostring(newValue)
		end)
	end
end)

-- ==========================================
-- 3. QUESTS TRACKER
-- ==========================================
local questContainer = Instance.new("Frame")
questContainer.Name = "QuestTracker"
questContainer.Size = UDim2.new(0, 250, 0, 150)
questContainer.Position = UDim2.new(1, -270, 0.4, 0) 
questContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
questContainer.BackgroundTransparency = 0.5 
applyCartoonyStyle(questContainer)
questContainer.Parent = mainGui

local questTitle = Instance.new("TextLabel")
questTitle.Size = UDim2.new(1, 0, 0, 30)
questTitle.BackgroundTransparency = 1
questTitle.Font = Enum.Font.FredokaOne
questTitle.Text = "⭐ Active Quests"
questTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
questTitle.TextSize = 20
applyCartoonyStyle(questTitle)
questTitle.Parent = questContainer

local quest1 = Instance.new("TextLabel")
quest1.Size = UDim2.new(0.9, 0, 0, 30)
quest1.Position = UDim2.new(0.05, 0, 0.3, 0)
quest1.BackgroundTransparency = 1
quest1.Font = Enum.Font.SourceSansBold
quest1.Text = "Break 10 Coin Piles: 0/10"
quest1.TextColor3 = Color3.fromRGB(255, 255, 0)
quest1.TextSize = 16
quest1.TextXAlignment = Enum.TextXAlignment.Center -- Fixed to Center!
quest1.Parent = questContainer

local quest2 = Instance.new("TextLabel")
quest2.Size = UDim2.new(0.9, 0, 0, 30)
quest2.Position = UDim2.new(0.05, 0, 0.55, 0)
quest2.BackgroundTransparency = 1
quest2.Font = Enum.Font.SourceSansBold
quest2.Text = "Unlock Main Area: 0/1"
quest2.TextColor3 = Color3.fromRGB(255, 255, 0)
quest2.TextSize = 16
quest2.TextXAlignment = Enum.TextXAlignment.Center -- Fixed to Center!
quest2.Parent = questContainer

-- ==========================================
-- 4. THE INVENTORY WINDOW
-- ==========================================
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryFrame"
inventoryFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
inventoryFrame.Position = UDim2.new(0.25, 0, 0.2, 0) 
inventoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inventoryFrame.Visible = false 
applyCartoonyStyle(inventoryFrame)
inventoryFrame.Parent = mainGui

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 50)
invTitle.BackgroundTransparency = 1
invTitle.Font = Enum.Font.FredokaOne
invTitle.Text = "🐾 PET INVENTORY"
invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
invTitle.TextSize = 30
applyCartoonyStyle(invTitle)
invTitle.Parent = inventoryFrame

local invPlaceholder = Instance.new("TextLabel")
invPlaceholder.Size = UDim2.new(1, 0, 0.8, 0)
invPlaceholder.Position = UDim2.new(0, 0, 0.2, 0)
invPlaceholder.BackgroundTransparency = 1
invPlaceholder.Font = Enum.Font.SourceSansItalic
invPlaceholder.Text = "(Pet Mechanics will load here from the other script)"
invPlaceholder.TextColor3 = Color3.fromRGB(150, 150, 150)
invPlaceholder.TextSize = 18
invPlaceholder.Parent = inventoryFrame

local closeInvBtn = Instance.new("TextButton")
closeInvBtn.Size = UDim2.new(0, 40, 0, 40)
closeInvBtn.Position = UDim2.new(1, -15, 0, -15) 
closeInvBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeInvBtn.Font = Enum.Font.FredokaOne
closeInvBtn.Text = "X"
closeInvBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeInvBtn.TextSize = 20
applyCartoonyStyle(closeInvBtn)
closeInvBtn.Parent = inventoryFrame

-- ==========================================
-- 5. SIDEBAR MENU BUTTONS
-- ==========================================
local sideMenu = Instance.new("Frame")
sideMenu.Name = "SideMenu"
sideMenu.Size = UDim2.new(0, 70, 0, 300)
sideMenu.Position = UDim2.new(0, 10, 0.3, 0) 
sideMenu.BackgroundTransparency = 1
sideMenu.Parent = mainGui

local inventoryButton = Instance.new("TextButton")
inventoryButton.Name = "InventoryToggle"
inventoryButton.Size = UDim2.new(1, 0, 0, 70)
inventoryButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255) 
inventoryButton.Font = Enum.Font.FredokaOne
inventoryButton.Text = "🐾\nPets"
inventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryButton.TextSize = 18
applyCartoonyStyle(inventoryButton)
inventoryButton.Parent = sideMenu

inventoryButton.MouseButton1Click:Connect(function()
	inventoryFrame.Visible = not inventoryFrame.Visible
end)

closeInvBtn.MouseButton1Click:Connect(function()
	inventoryFrame.Visible = false
end)