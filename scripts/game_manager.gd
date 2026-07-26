# for data that needs to persist across scenes
extends Node

signal upgrade_selected(upgrade: LevelUpgradeInfo)
signal upgrade_confirmed()
var curr_day = 1
const ALL_UPGRADES : Array[LevelUpgradeInfo] = [
	preload("res://upgrades/coffee_pot.tres"),
	preload("res://upgrades/overtime.tres"),
	preload("res://upgrades/speedwalk.tres"),
	preload("res://upgrades/lucky_strike.tres")
]
@export var available_options : Array[LevelUpgradeInfo] = []
@export var chosen_upgrades : Array[LevelUpgradeInfo] = [
]

func _ready() -> void:
	reset_upgrades()


func reset_upgrades():
	available_options = ALL_UPGRADES.duplicate()
	chosen_upgrades = []
