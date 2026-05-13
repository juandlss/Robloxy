-- src/shared/PetData.luau
local PetData = {}

-- Defines the eggs, their costs, and the pets inside them
PetData.Eggs = {
	["Basic Egg"] = {
		Cost = 50,
		Pets = {"Dog", "Cat", "Bunny", "Dragon"}
	}
}

-- Defines the stats, rarities, and visual colors of every pet
PetData.Pets = {
	["Dog"] = { Rarity = "Common", Multiplier = 1.2, Color = Color3.fromRGB(139, 69, 19), Icon = "🐶" },
	["Cat"] = { Rarity = "Common", Multiplier = 1.2, Color = Color3.fromRGB(200, 200, 200), Icon = "🐱" },
	["Bunny"] = { Rarity = "Uncommon", Multiplier = 1.5, Color = Color3.fromRGB(255, 255, 255), Icon = "🐰" },
	["Dragon"] = { Rarity = "Legendary", Multiplier = 3.0, Color = Color3.fromRGB(255, 50, 50), Icon = "🐉" }
}

return PetData