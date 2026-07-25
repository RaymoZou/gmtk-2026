class_name CoffeePot
extends Interactable

const EFFICIENCY_FACTOR : float = 2 # how much to reduce the hold time 
const DURATION : float = 5.0 # duration in seconds

var upgrade : LevelUpgradeInfo = preload("res://upgrades/coffee_pot.tres")

func _ready() -> void:
	if upgrade not in GameManager.chosen_upgrades:
		queue_free()

func interact(player: Player):
	# player.hold_duration /= EFFICIENCY_FACTOR
	%Jug.hide()
	can_interact = false
	player.increase_productivity(EFFICIENCY_FACTOR, DURATION)