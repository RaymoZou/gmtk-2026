class_name CoffeePot
extends Interactable

const EFFICIENCY_FACTOR : float = 2

var upgrade : LevelUpgradeInfo = preload("res://upgrades/coffee_pot.tres")

func _ready() -> void:
	if upgrade not in GameManager.chosen_upgrades:
		queue_free()

func interact(player: Player):
	print("Speed has been upgraded for %s" % player.name)
	player.hold_duration /= EFFICIENCY_FACTOR
	print("Player hold duration is now %s" % player.hold_duration)
	%Jug.hide()
	can_interact = false