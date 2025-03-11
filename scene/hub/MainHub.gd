# Path: res://scene/hub/MainHub.gd
extends Control

# Variables to track player selections
var selected_class = ""
var selected_quest = ""
var available_classes = ["Warrior", "Mage", "Rogue"]
var unlocked_classes = []
var starting_quest_options = ["Forest Ruins", "Ancient Mine", "Haunted Village"]

# References to UI elements
@onready var class_container = $HubUI/ClassSelection/ClassOptions
@onready var quest_container = $HubUI/QuestSelection/QuestOptions
@onready var class_description = $HubUI/ClassSelection/ClassDescription
@onready var quest_description = $HubUI/QuestSelection/QuestDescription
@onready var embark_button = $HubUI/EmbarkButton
@onready var back_button = $HubUI/BackButton

# Class descriptions
var class_descriptions = {
	"Warrior": "A sturdy front-line fighter with high HP and physical damage abilities. Can stagger enemies with powerful strikes.",
	"Mage": "A versatile spellcaster with elemental abilities that target various weaknesses. Lower HP but high damage potential.",
	"Rogue": "A quick striker specializing in critical hits and evasion. Can apply debuffs and exploit enemy weaknesses."
}

# Quest descriptions
var quest_descriptions = {
	"Forest Ruins": "A relatively simple quest through an ancient forest temple. Enemies are primarily beasts and plants with physical and water weaknesses.",
	"Ancient Mine": "Delve into an abandoned mine filled with constructs and earth elementals. Fire abilities are effective here.",
	"Haunted Village": "A challenging first quest with undead enemies resistant to physical damage but weak to light and fire."
}

func _ready():
	# Load unlocked classes from save
	load_unlocked_classes()
	
	# Set up initial UI
	setup_class_options()
	setup_quest_options()
	
	# Disable embark button until selections are made
	embark_button.disabled = true
	embark_button.pressed.connect(_on_embark_button_pressed)
	
	# Connect back button
	back_button.pressed.connect(_on_back_button_pressed)
func load_unlocked_classes():
	# For MVP, we'll start with just the base classes
	# Later this would load from save file
	unlocked_classes = available_classes.duplicate()

func setup_class_options():
	# Clear any existing buttons
	for child in class_container.get_children():
		child.queue_free()
	
	# Create buttons for each available class
	for character_class in unlocked_classes:
		var button = Button.new()
		button.text = character_class
		button.toggle_mode = true
		button.pressed.connect(_on_class_selected.bind(character_class))
		class_container.add_child(button)

func setup_quest_options():
	# Clear any existing buttons
	for child in quest_container.get_children():
		child.queue_free()
	
	# Create buttons for each available quest
	for quest_name in starting_quest_options:
		var button = Button.new()
		button.text = quest_name
		button.toggle_mode = true
		button.pressed.connect(_on_quest_selected.bind(quest_name))
		quest_container.add_child(button)

func _on_class_selected(character_class):
	# Update selected class
	selected_class = character_class
	
	# Update description
	class_description.text = class_descriptions[character_class]
	
	# Unselect other class buttons
	for child in class_container.get_children():
		if child.text != character_class:
			child.button_pressed = false
	
	# Check if can enable embark button
	update_embark_button()

func _on_quest_selected(quest_name):
	# Update selected quest
	selected_quest = quest_name
	
	# Update description
	quest_description.text = quest_descriptions[quest_name]
	
	# Unselect other quest buttons
	for child in quest_container.get_children():
		if child.text != quest_name:
			child.button_pressed = false
	
	# Check if can enable embark button
	update_embark_button()

func update_embark_button():
	# Enable button only if both class and quest are selected
	embark_button.disabled = selected_class.is_empty() or selected_quest.is_empty()

func _on_embark_button_pressed():
	# Save current selections to game state
	var game_data = {
		"player_class": selected_class,
		"current_quest": selected_quest,
		"hp": 100, # Starting values would vary by class
		"mp": 50,
		"inventory": [],
		"relics": []
	}
	
	# Save game data (for MVP we'll just print it)
	print("Starting new run with: ", game_data)
	
	# Transition to battle scene
	get_tree().change_scene_to_file("res://scene/battle/BattleScene.tscn")


func _on_back_button_pressed():
	print("Back button pressed!")
	get_tree().change_scene_to_file("res://scene/ui/StartMenu.tscn")