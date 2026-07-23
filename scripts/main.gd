class_name Day
extends Node3D

const STARTING_TIME = 100
@export var SECONDS_PER_HOUR = 45 # each duration of an hour is simulated by 45 seconds
var current_hour : int = 9 # up to 17
var ending_hour : int = 17 # the hour at which the day ends
@onready var timer : Timer = $Timer

const tasks = [
	preload("res://tasks/email.tres"),
	preload("res://tasks/print.tres"),
	preload("res://tasks/sign_paper.tres"),
]

var curr_tasks : Array[Task] = []

signal hour_updated(new_hour : int)
signal day_ended(success: bool)
signal tasks_updated(tasks : Array[Task])
signal all_tasks_completed
signal game_over_signal

func get_random_task() -> Task:
	return tasks.pick_random().duplicate()

# NOTE: assume main.tscn is the parent
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

func _on_time_out():
	current_hour += 1
	hour_updated.emit(current_hour)
	print(get_readable_hour())

	for task in curr_tasks:
		if task.status == Task.Status.INCOMPLETE and task.deadline < ending_hour and task.deadline <= current_hour:
			fail_task(task)

	if current_hour == ending_hour:
		end_day()

func fail_task(task: Task) -> void:
	task.status = Task.Status.FAILED
	curr_tasks.push_back(get_random_task())
	curr_tasks.push_back(get_random_task())
	tasks_updated.emit(curr_tasks)

func _on_interactable_task_completed(_task: Task) -> void:
	tasks_updated.emit(curr_tasks)
	for t in curr_tasks:
		if t.status != Task.Status.COMPLETED:
			return
	print("All tasks have been completed")
	all_tasks_completed.emit()

func get_readable_hour() -> String:
	if current_hour < 12:
		return "%d:00 AM" % current_hour
	elif current_hour == 12:
		return "%d:00 PM" % current_hour
	else:
		var formatted_time : int = current_hour - 12
		return "%d:00 PM" % formatted_time

func end_day() -> void:
	print("ending the day")
	var success := true
	for task in curr_tasks:
		if task.status != Task.Status.COMPLETED:
			success = false
			break
	day_ended.emit(success)
	timer.timeout.disconnect(_on_time_out)
	if not success:
		game_over_signal.emit()

func _ready() -> void:
	start_game()
	for node in get_tree().get_nodes_in_group("interactables"):
		(node as Interactable).task_completed.connect(_on_interactable_task_completed)
