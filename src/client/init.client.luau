-- src/client/init.client.luau
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1. MAIN UI CONTAINER & STYLING
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
currencyContainer.Size = UDim2.new(0, 200, 0, 50)
currencyContainer.Position = UDim2.new(0, 20, 1, -70) 
currencyContainer.BackgroundTransparency = 1
currencyContainer.Parent = mainGui

local coinLabel = Instance.new("TextLabel")
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
quest1.TextXAlignment = Enum.TextXAlignment.Center
quest1.Parent = questContainer

-- ==========================================
-- 4. THE INVENTORY SYSTEM
-- ==========================================
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Size = UDim2.new(0.5, 0, 0.65, 0)
inventoryFrame.Position = UDim2.new(0.25, 0, 0.175, 0) 
inventoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inventoryFrame.Visible = false 
applyCartoonyStyle(inventoryFrame)
inventoryFrame.Parent = mainGui

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 50)
invTitle.BackgroundTransparency = 1
invTitle.Font = Enum.Font.FredokaOne
invTitle.Text = "🎒 INVENTORY"
invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
invTitle.TextSize = 30
applyCartoonyStyle(invTitle)
invTitle.Parent = inventoryFrame

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

-- --- TABS ---
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.9, 0, 0, 40)
tabContainer.Position = UDim2.new(0.05, 0, 0.12, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = inventoryFrame

local petsTabBtn = Instance.new("TextButton")
petsTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
petsTabBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
petsTabBtn.Font = Enum.Font.FredokaOne
petsTabBtn.Text = "🐾 Pets"
petsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
petsTabBtn.TextSize = 20
applyCartoonyStyle(petsTabBtn)
petsTabBtn.Parent = tabContainer

local itemsTabBtn = Instance.new("TextButton")
itemsTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
itemsTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
itemsTabBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150) 
itemsTabBtn.Font = Enum.Font.FredokaOne
itemsTabBtn.Text = "🧪 Items"
itemsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
itemsTabBtn.TextSize = 20
applyCartoonyStyle(itemsTabBtn)
itemsTabBtn.Parent = tabContainer

-- --- ITEM GRID ---
local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Size = UDim2.new(0.9, 0, 0.7, 0)
itemScroll.Position = UDim2.new(0.05, 0, 0.25, 0)
itemScroll.BackgroundTransparency = 1
itemScroll.ScrollBarThickness = 8
itemScroll.Parent = inventoryFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 90, 0, 90) 
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent = itemScroll

local function createItemBox(icon, labelText, quantity, color)
	local box = Instance.new("Frame")
	box.BackgroundColor3 = color
	applyCartoonyStyle(box)
	box.Parent = itemScroll
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 0.7, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Enum.Font.SourceSans
	iconLabel.Text = icon
	iconLabel.TextSize = 45
	iconLabel.Parent = box
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.7, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Text = labelText
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	applyCartoonyStyle(nameLabel)
	nameLabel.Parent = box
	
	if quantity > 1 then
		local qtyLabel = Instance.new("TextLabel")
		qtyLabel.Size = UDim2.new(0, 30, 0, 30)
		qtyLabel.Position = UDim2.new(1, -25, 1, -25)
		qtyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		qtyLabel.Font = Enum.Font.FredokaOne
		qtyLabel.Text = "x" .. tostring(quantity)
		qtyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		qtyLabel.TextSize = 12
		
		local qtyCorner = Instance.new("UICorner")
		qtyCorner.CornerRadius = UDim.new(1, 0) 
		qtyCorner.Parent = qtyLabel
		qtyLabel.Parent = box
	end
end

-- --- TAB LOGIC ---
local function loadPetsTab()
	petsTabBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255) -- Active Blue
	itemsTabBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150) -- Inactive Gray
	
	for _, child in ipairs(itemScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	createItemBox("🐶", "Dog", 1, Color3.fromRGB(200, 200, 200))
	createItemBox("🐱", "Cat", 1, Color3.fromRGB(200, 200, 200))
	createItemBox("🐰", "Bunny", 1, Color3.fromRGB(85, 255, 127))
	createItemBox("🐉", "Dragon", 1, Color3.fromRGB(255, 85, 255))
end

local function loadItemsTab()
	itemsTabBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255) -- Active Blue
	petsTabBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150) -- Inactive Gray
	
	for _, child in ipairs(itemScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	createItemBox("🧪", "Luck Potion", 5, Color3.fromRGB(46, 204, 113))
	createItemBox("🔥", "Damage Potion", 2, Color3.fromRGB(231, 76, 60))
	createItemBox("💰", "Coin Boost", 10, Color3.fromRGB(241, 196, 15))
	createItemBox("🎫", "Golden Ticket", 1, Color3.fromRGB(255, 170, 0))
end

petsTabBtn.MouseButton1Click:Connect(loadPetsTab)
itemsTabBtn.MouseButton1Click:Connect(loadItemsTab)
loadPetsTab() -- Default

-- ==========================================
-- 5. SHOP WINDOW
-- ==========================================
local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0.4, 0, 0.65, 0)
shopFrame.Position = UDim2.new(0.3, 0, 0.175, 0) 
shopFrame.BackgroundColor3 = Color3.fromRGB(30, 144, 255) 
shopFrame.Visible = false 
applyCartoonyStyle(shopFrame)
shopFrame.Parent = mainGui

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 50)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.FredokaOne
shopTitle.Text = "🛒 EXCLUSIVE SHOP"
shopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTitle.TextSize = 30
applyCartoonyStyle(shopTitle)
shopTitle.Parent = shopFrame

local closeShopBtn = closeInvBtn:Clone()
closeShopBtn.Parent = shopFrame

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(0.9, 0, 0.8, 0)
shopScroll.Position = UDim2.new(0.05, 0, 0.15, 0)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 8
shopScroll.Parent = shopFrame

local shopListLayout = Instance.new("UIListLayout")
shopListLayout.Padding = UDim.new(0, 10)
shopListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
shopListLayout.Parent = shopScroll

local function createGamepassItem(name, priceRobux, color)
	local itemFrame = Instance.new("Frame")
	itemFrame.Size = UDim2.new(0.95, 0, 0, 80)
	itemFrame.BackgroundColor3 = color
	applyCartoonyStyle(itemFrame)
	itemFrame.Parent = shopScroll
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.6, 0, 1, 0)
	title.Position = UDim2.new(0.05, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.Text = name
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	applyCartoonyStyle(title)
	title.Parent = itemFrame
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0.3, 0, 0.6, 0)
	buyBtn.Position = UDim2.new(0.65, 0, 0.2, 0)
	buyBtn.BackgroundColor3 = Color3.fromRGB(85, 255, 127) 
	buyBtn.Font = Enum.Font.FredokaOne
	buyBtn.Text = "R$ " .. tostring(priceRobux)
	buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtn.TextSize = 20
	applyCartoonyStyle(buyBtn)
	buyBtn.Parent = itemFrame
end

createGamepassItem("🍀 2x Luck", 399, Color3.fromRGB(46, 204, 113))
createGamepassItem("⚔️ 2x Damage", 299, Color3.fromRGB(231, 76, 60))
createGamepassItem("🐾 +1 Pet Equip", 499, Color3.fromRGB(155, 89, 182))
createGamepassItem("⚡ Fast Walk", 149, Color3.fromRGB(241, 196, 15))

-- ==========================================
-- 6. NEW: SEPARATE SIDEBAR MENU BUTTONS
-- ==========================================
local sideMenu = Instance.new("Frame")
sideMenu.Size = UDim2.new(0, 70, 0, 300)
sideMenu.Position = UDim2.new(0, 10, 0.3, 0) 
sideMenu.BackgroundTransparency = 1
sideMenu.Parent = mainGui

local sideMenuLayout = Instance.new("UIListLayout")
sideMenuLayout.Padding = UDim.new(0, 10)
sideMenuLayout.Parent = sideMenu

-- 1. The Pets Button
local petsSideBtn = Instance.new("TextButton")
petsSideBtn.Size = UDim2.new(1, 0, 0, 70)
petsSideBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255) 
petsSideBtn.Font = Enum.Font.FredokaOne
petsSideBtn.Text = "🐾\nPets" 
petsSideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
petsSideBtn.TextSize = 18
applyCartoonyStyle(petsSideBtn)
petsSideBtn.Parent = sideMenu

-- 2. The Items Button
local itemsSideBtn = Instance.new("TextButton")
itemsSideBtn.Size = UDim2.new(1, 0, 0, 70)
itemsSideBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150) -- Gray items button
itemsSideBtn.Font = Enum.Font.FredokaOne
itemsSideBtn.Text = "🧪\nItems" 
itemsSideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
itemsSideBtn.TextSize = 18
applyCartoonyStyle(itemsSideBtn)
itemsSideBtn.Parent = sideMenu

-- 3. The Shop Button
local shopSideBtn = Instance.new("TextButton")
shopSideBtn.Size = UDim2.new(1, 0, 0, 70)
shopSideBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
shopSideBtn.Font = Enum.Font.FredokaOne
shopSideBtn.Text = "🛒\nShop"
shopSideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shopSideBtn.TextSize = 18
applyCartoonyStyle(shopSideBtn)
shopSideBtn.Parent = sideMenu

-- ==========================================
-- 7. SMART TOGGLE LOGIC
-- ==========================================

-- Clicking Pets on the side menu
petsSideBtn.MouseButton1Click:Connect(function()
	if inventoryFrame.Visible and petsTabBtn.BackgroundColor3 == Color3.fromRGB(85, 170, 255) then
		-- If it's already open and on the Pets tab, close it
		inventoryFrame.Visible = false
	else
		-- Otherwise, open it and force it to the Pets tab
		inventoryFrame.Visible = true
		shopFrame.Visible = false 
		loadPetsTab()
	end
end)

-- Clicking Items on the side menu
itemsSideBtn.MouseButton1Click:Connect(function()
	if inventoryFrame.Visible and itemsTabBtn.BackgroundColor3 == Color3.fromRGB(85, 170, 255) then
		-- If it's already open and on the Items tab, close it
		inventoryFrame.Visible = false
	else
		-- Otherwise, open it and force it to the Items tab
		inventoryFrame.Visible = true
		shopFrame.Visible = false 
		loadItemsTab()
	end
end)

-- Clicking Shop on the side menu
shopSideBtn.MouseButton1Click:Connect(function()
	shopFrame.Visible = not shopFrame.Visible
	inventoryFrame.Visible = false 
end)

closeInvBtn.MouseButton1Click:Connect(function()
	inventoryFrame.Visible = false
end)

closeShopBtn.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

print("Pet Simulator HUD with smart side-buttons loaded!")