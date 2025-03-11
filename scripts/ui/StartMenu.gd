# Path: res://scripts/ui/StartMenu.gd
extends Control

# Reference to save game file
var save_file_path = "user://savegame.save"

func _ready():
	# Connect button signals to their respective functions
	$VBoxContainer/NewGame.pressed.connect(_on_new_game_button_pressed)
	$VBoxContainer/Continue.pressed.connect(_on_continue_button_pressed)
	$VBoxContainer/Codex.pressed.connect(_on_codex_button_pressed)
	$VBoxContainer/Options.pressed.connect(_on_options_button_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_button_pressed)
	
	# Check if save file exists and disable/enable Continue button
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	if save_file == null:
		# No save file exists, disable Continue button
		$VBoxContainer/Continue.disabled = true
	else:
		# Save file exists, enable Continue button
		$VBoxContainer/Continue.disabled = false
		save_file.close()

func _on_new_game_button_pressed():
	# Start a new game
	print("Starting new game...")
	# Replace with your actual first game scene
	get_tree().change_scene_to_file("res://scene/hub/MainHub.tscn")

func _on_continue_button_pressed():
	# Load saved game
	print("Loading saved game...")
	# Load save file and resume game (to be implemented)
	get_tree().change_scene_to_file("res://scene/hub/MainHub.tscn")
	# You'll need to implement actual save/load logic here

func _on_codex_button_pressed():
	# Open the codex showing unlocked relics and classes
	print("Opening codex...")
	# Replace with your actual codex scene
	get_tree().change_scene_to_file("res://scene/ui/Codex.tscn")

func _on_options_button_pressed():
	# For MVP, we can just print to console since options aren't implemented yet
	print("Options button pressed - to be implemented")
	# Uncomment when you have an options scene:
	# get_tree().change_scene_to_file("res://scene/ui/OptionsMenu.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
