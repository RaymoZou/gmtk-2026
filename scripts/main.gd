class_name Day
extends Node3D

const STARTING_TIME = 100
@export var SECONDS_PER_HOUR = 45 # each duration of an hour is simulated by 45 seconds
var current_hour : int = 9 # up to 17
var ending_hour : int = 17 # the hour at which the day ends
@onready var timer : Timer = $Timer
# TASKS

# all possible task options
const tasks = [
	preload("res://tasks/email.tres"),
	preload("res://tasks/print.tres"),
	preload("res://tasks/sign_paper.tres"),
]

# the tasks which need to be completed by today
var curr_tasks : Array[Task] = []

signal hour_updated(new_hour : int)
signal day_ended
signal tasks_updated(tasks : Array[Task])

func get_random_task() -> Task:
	return tasks.pick_random()

func start_game():
	timer.timeout.connect(_on_time_out)
	timer.wait_time = SECONDS_PER_HOUR
	timer.start()
	print("game has started: the time is %s - get to work!" % get_readable_hour())
	hour_updated.emit(current_hour)

	curr_tasks.push_back(get_random_task())
	curr_tasks.push_back(get_random_task())
	curr_tasks.push_back(get_random_task())
	tasks_updated.emit(curr_tasks)

# increment the hour clock
func _on_time_out():
	current_hour += 1
	hour_updated.emit(current_hour)
	print(get_readable_hour())
	if current_hour == 17:
		end_day()
	# NOTE: add overtime?

func get_readable_hour() -> String:
	if current_hour < 12:
		return "%d:00 AM" % current_hour
	elif current_hour == 12:
		return "%d:00 PM" % current_hour
	else:
		var formatted_time : int = current_hour - 12
		return "%d:00 PM" % formatted_time

# when the game ends
# stop incrementing the hour
func end_day() -> void:
	print("ending the day")
	day_ended.emit() 
	timer.timeout.disconnect(_on_time_out)

	# TODO:
	# check if all the tasks were completed today
	# game over if not

# TODO:
func game_over():
	print("game over")
	pass

func _ready() -> void:
	start_game()
