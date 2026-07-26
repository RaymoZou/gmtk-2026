class_name Day
extends Node3D

const STARTING_TIME = 100
var current_hour : int = 9 # up to 17
var ending_hour : int = 17 # the hour at which the day ends

signal hour_updated(new_hour : int)
signal day_ended(success: bool)

@export var SECONDS_PER_HOUR = 45 # each duration of an hour is simulated by 45 seconds
@onready var timer : Timer = $Timer
@onready var task_manager : TaskManager = $TaskManager

func _ready() -> void:
	# check for Overtime I upgrade
	var overtime_upgrade : LevelUpgradeInfo	= preload("res://upgrades/overtime.tres")
	if overtime_upgrade in GameManager.chosen_upgrades:
		ending_hour += 1
		print("The day has been extended to %s" % get_readable_hour())
	start_game()

# NOTE: assume main.tscn is the parent
func start_game():
	timer.timeout.connect(_on_time_out)
	timer.wait_time = SECONDS_PER_HOUR
	timer.start()
	print("game has started: the time is %s - get to work!" % get_readable_hour())
	hour_updated.emit(current_hour)

func _on_time_out():
	current_hour += 1
	hour_updated.emit(current_hour)
	print(get_readable_hour())

	# TODO: check TaskManager for time-sensitive tasks

	if current_hour == ending_hour:
		end_day()

func get_remaining_hours() -> int:
	return ending_hour - current_hour	

func get_readable_hour() -> String:
	if current_hour < 12:
		return "%d:00 AM" % current_hour
	elif current_hour == 12:
		return "%d:00 PM" % current_hour
	else:
		var formatted_time : int = current_hour - 12
		return "%d:00 PM" % formatted_time

func end_day() -> void:
	timer.timeout.disconnect(_on_time_out) # stop virtual time
	if task_manager.is_tasks_completed:
		day_ended.emit(true)
	else:
		day_ended.emit(false)
		GameManager.reset_upgrades()
