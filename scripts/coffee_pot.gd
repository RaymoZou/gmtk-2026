class_name CoffeePot
extends Interactable

var EFFICIENCY_FACTOR : float = 2 # how much to reduce the hold time 
var DURATION : float = 5.0 # duration in seconds

var upgrade : LevelUpgradeInfo = preload("res://upgrades/coffee_pot.tres")
var better_beans : LevelUpgradeInfo = preload("res://upgrades/coffee_pot.tres")

func _ready() -> void:
	if upgrade not in GameManager.chosen_upgrades:
		queue_free()

	# Better Beans upgrade
	if better_beans in GameManager.chosen_upgrades:
		EFFICIENCY_FACTOR  = 2.5
		DURATION  = 10.0


func interact(player: Player):
	# player.hold_duration /= EFFICIENCY_FACTOR
	%Jug.hide()
	can_interact = false
	player.increase_productivity(EFFICIENCY_FACTOR, DURATION)