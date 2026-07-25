# for data that needs to persist across scenes
extends Node

@export var available_options : Array[LevelUpgradeInfo] = [
	preload("res://upgrades/coffee_pot.tres"),
]
@export var chosen_upgrades : Array[LevelUpgradeInfo] = []

signal upgrade_selected(upgrade: LevelUpgradeInfo)
signal upgrade_confirmed()
