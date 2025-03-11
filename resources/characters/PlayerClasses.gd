# Path: res://resources/characters/PlayerClasses.gd
extends Resource
class_name PlayerClasses

# Base classes available from the start
static var base_classes = {
	"Warrior": {
		"description": "A sturdy front-line fighter with high HP and physical damage abilities. Can stagger enemies with powerful strikes.",
		"base_hp": 120,
		"base_mp": 40,
		"starting_abilities": ["Strike", "Defend", "Taunt"],
		"weakness_coverage": ["Physical"],
		"unlocked_by_default": true
	},
	"Mage": {
		"description": "A versatile spellcaster with elemental abilities that target various weaknesses. Lower HP but high damage potential.",
		"base_hp": 80,
		"base_mp": 100,
		"starting_abilities": ["Fire", "Ice", "Focus"],
		"weakness_coverage": ["Fire", "Ice"],
		"unlocked_by_default": true
	},
	"Rogue": {
		"description": "A quick striker specializing in critical hits and evasion. Can apply debuffs and exploit enemy weaknesses.",
		"base_hp": 90,
		"base_mp": 60,
		"starting_abilities": ["Stab", "Poison", "Evade"],
		"weakness_coverage": ["Physical", "Poison"],
		"unlocked_by_default": true
	}
}

# Advanced classes to be unlocked through gameplay
static var advanced_classes = {
	"Paladin": {
		"description": "A holy warrior with healing abilities and strong defense. Effective against undead and dark enemies.",
		"base_hp": 110,
		"base_mp": 70,
		"starting_abilities": ["Holy Strike", "Heal", "Protect"],
		"weakness_coverage": ["Light", "Physical"],
		"unlock_condition": "Complete 3 quests with a Warrior"
	},
	"Elementalist": {
		"description": "Master of all elements with access to a wide array of elemental spells and combinations.",
		"base_hp": 75,
		"base_mp": 120,
		"starting_abilities": ["Firestorm", "Blizzard", "Lightning"],
		"weakness_coverage": ["Fire", "Ice", "Lightning"],
		"unlock_condition": "Complete 3 quests with a Mage"
	},
	"Assassin": {
		"description": "Stealth specialist with high critical chance and the ability to bypass enemy defenses.",
		"base_hp": 85,
		"base_mp": 70,
		"starting_abilities": ["Backstab", "Vanish", "Expose Weakness"],
		"weakness_coverage": ["Physical", "Shadow"],
		"unlock_condition": "Complete 3 quests with a Rogue"
	}
}

# Function to get all available classes (including unlocked advanced classes)
static func get_all_classes(unlocked_advanced = []):
	var all_classes = base_classes.duplicate(true)
	
	for class_id in unlocked_advanced:
		if advanced_classes.has(class_id):
			all_classes[class_id] = advanced_classes[class_id]
	
	return all_classes

# Function to get details for a specific class
static func get_class_details(class_id):
	if base_classes.has(class_id):
		return base_classes[class_id]
	elif advanced_classes.has(class_id):
		return advanced_classes[class_id]
	return null