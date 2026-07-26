# for data that needs to persist across scenes
extends Node

const ALL_UPGRADES : Array[LevelUpgradeInfo] = [
	preload("res://upgrades/coffee_pot.tres"),
	preload("res://upgrades/overtime.tres"),
	preload("res://upgrades/speedwalk.tres")
]

@export var available_options : Array[LevelUpgradeInfo] = [
	preload("res://upgrades/coffee_pot.tres"),
	preload("res://upgrades/overtime.tres"),
	preload("res://upgrades/speedwalk.tres")
]

@export var chosen_upgrades : Array[LevelUpgradeInfo] = [
]

signal upgrade_selected(upgrade: LevelUpgradeInfo)
signal upgrade_confirmed()

func reset_upgrades():
	available_options = ALL_UPGRADES.duplicate()
	chosen_upgrades = []
