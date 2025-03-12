# Path: res://scene/battle/BattleScene.gd
extends Control

# Battle state
enum BattleState { PLAYER_TURN, ENEMY_TURN, WON, LOST }
var current_state = BattleState.PLAYER_TURN

# Player stats (will be loaded from game data later)
var player_stats = {
	"class": "Warrior",
	"hp": 100,
	"max_hp": 100,
	"mp": 50,
	"max_mp": 50,
	"abilities": ["Attack", "Defend", "Special"]
}

# Enemy data for this battle
var current_enemy = {
	"name": "Forest Troll",
	"hp": 80,
	"max_hp": 80,
	"weaknesses": ["Fire"],
	"stagger": 0,  # 0-100%
	"stagger_threshold": 100,
	"is_staggered": false,
	"attacks": ["Slam", "Roar"]
}

# Relic data
var active_relics = [
	{
		"name": "Ancient Medallion",
		"description": "Increases damage by 20% when enemy is below half health",
		"effect": "damage_boost_low_hp"
	}
]

# References to UI elements - UPDATED for new scene structure
@onready var player_hp_bar = $BattleUI/MainPanels/PlayerPanel/HPBar
@onready var player_mp_bar = $BattleUI/MainPanels/PlayerPanel/MPBar
@onready var enemy_hp_bar = $BattleUI/EnemyPanel/HPBar
@onready var stagger_bar = $BattleUI/EnemyPanel/StaggerBar
@onready var battle_log = $BattleUI/BattleLog
@onready var action_buttons = $BattleUI/ActionPanel/ActionButtons
@onready var relics_panel = $BattleUI/MainPanels/RelicsPanel/VBoxContainer

func _ready():
	# Set up initial UI
	update_ui()
	setup_action_buttons()
	populate_relics()
	
	# Display battle intro
	log_message("Battle started! A " + current_enemy.name + " appears!")
	log_message("Player turn - Select an action")

func update_ui():
	# Update player stats
	player_hp_bar.value = (float(player_stats.hp) / player_stats.max_hp) * 100
	player_mp_bar.value = (float(player_stats.mp) / player_stats.max_mp) * 100
	player_hp_bar.get_parent().get_node("HPLabel").text = str(player_stats.hp) + "/" + str(player_stats.max_hp)
	player_mp_bar.get_parent().get_node("MPLabel").text = str(player_stats.mp) + "/" + str(player_stats.max_mp)
	$BattleUI/MainPanels/PlayerPanel/ClassLabel.text = player_stats.class
	
	# Update enemy stats
	enemy_hp_bar.value = (float(current_enemy.hp) / current_enemy.max_hp) * 100
	stagger_bar.value = current_enemy.stagger
	$BattleUI/EnemyPanel/NameLabel.text = current_enemy.name
	$BattleUI/EnemyPanel/HPLabel.text = str(current_enemy.hp) + "/" + str(current_enemy.max_hp)
	$BattleUI/EnemyPanel/StaggerLabel.text = "Stagger: " + str(current_enemy.stagger) + "%"
	
	# Update action buttons based on state
	for button in action_buttons.get_children():
		button.disabled = current_state != BattleState.PLAYER_TURN

func setup_action_buttons():
	# Clear existing buttons
	for child in action_buttons.get_children():
		child.queue_free()
	
	# Create buttons for each ability
	for ability in player_stats.abilities:
		var button = Button.new()
		button.text = ability
		button.pressed.connect(_on_action_button_pressed.bind(ability))
		action_buttons.add_child(button)
	
	# Add flee button
	var flee_button = Button.new()
	flee_button.text = "Flee"
	flee_button.pressed.connect(_on_flee_button_pressed)
	action_buttons.add_child(flee_button)

func populate_relics():
	# Clear existing relics
	for child in relics_panel.get_children():
		child.queue_free()
	
	# Add each active relic to the panel
	for relic in active_relics:
		var relic_label = Label.new()
		relic_label.text = relic.name
		relic_label.tooltip_text = relic.description
		relics_panel.add_child(relic_label)

func log_message(message):
	# Add message to battle log
	battle_log.text += message + "\n"
	# Auto-scroll to bottom
	battle_log.scroll_vertical = battle_log.get_line_count()

func _on_action_button_pressed(action):
	match action:
		"Attack":
			# Basic attack
			var damage = randi_range(10, 15)
			# Apply relic effects if applicable
			if current_enemy.hp < current_enemy.max_hp / 2:
				for relic in active_relics:
					if relic.effect == "damage_boost_low_hp":
						damage = int(damage * 1.2)
						log_message("Ancient Medallion glows, boosting damage!")
			
			# Apply damage
			current_enemy.hp = max(0, current_enemy.hp - damage)
			log_message("Player attacks for " + str(damage) + " damage!")
			
			# Update stagger meter
			current_enemy.stagger += 10
			if current_enemy.stagger >= current_enemy.stagger_threshold:
				current_enemy.is_staggered = true
				current_enemy.stagger = current_enemy.stagger_threshold
				log_message("Enemy is STAGGERED! It will skip its next turn!")
			
		"Defend":
			# Defensive stance
			log_message("Player takes defensive stance. Damage reduced for next turn.")
			
		"Special":
			# Special ability based on class
			if player_stats.mp >= 15:
				player_stats.mp -= 15
				var damage = randi_range(20, 25)
				current_enemy.hp = max(0, current_enemy.hp - damage)
				current_enemy.stagger += 25
				log_message("Player uses special attack for " + str(damage) + " damage!")
				
				if current_enemy.stagger >= current_enemy.stagger_threshold:
					current_enemy.is_staggered = true
					current_enemy.stagger = current_enemy.stagger_threshold
					log_message("Enemy is STAGGERED! It will skip its next turn!")
			else:
				log_message("Not enough MP for special attack!")
				return  # Don't end turn if not enough MP
	
	# Update UI
	update_ui()
	
	# Check if battle is over
	if current_enemy.hp <= 0:
		end_battle(true)
		return
	
	# Start enemy turn if not staggered
	if current_enemy.is_staggered:
		log_message("Enemy is staggered and misses its turn!")
		current_enemy.is_staggered = false
		current_enemy.stagger = 0
		update_ui()
	else:
		# Switch to enemy turn after a short delay
		current_state = BattleState.ENEMY_TURN
		update_ui()
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func enemy_turn():
	# Enemy attacks
	var attack_index = randi() % current_enemy.attacks.size()
	var attack_name = current_enemy.attacks[attack_index]
	var damage = randi_range(8, 12)
	
	log_message("Enemy uses " + attack_name + "!")
	player_stats.hp = max(0, player_stats.hp - damage)
	log_message("Player takes " + str(damage) + " damage!")
	
	# Update UI
	update_ui()
	
	# Check if battle is over
	if player_stats.hp <= 0:
		end_battle(false)
		return
	
	# Back to player turn
	current_state = BattleState.PLAYER_TURN
	log_message("Player turn - Select an action")
	update_ui()

func _on_flee_button_pressed():
	# 50% chance to flee successfully
	if randf() < 0.5:
		log_message("Fled successfully!")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scene/hub/MainHub.tscn")
	else:
		log_message("Failed to flee!")
		# Enemy gets a free attack
		current_state = BattleState.ENEMY_TURN
		update_ui()
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func end_battle(victory):
	if victory:
		current_state = BattleState.WON
		log_message("Victory! Enemy defeated.")
		log_message("Returning to hub...")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scene/hub/MainHub.tscn")
	else:
		current_state = BattleState.LOST
		log_message("Defeat! You have been defeated.")
		log_message("Returning to main menu...")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scene/ui/StartMenu.tscn")