class_name TaskManager
extends Node

signal tasks_updated(tasks : Array[Task])
signal all_tasks_completed

@export var interactable_tasks : Array[InteractableTask] = [] # all the interactable tasks in the scene
@export var curr_tasks : Array[Task] = []
var is_tasks_completed : bool = false 
const LUCKY_COUNT : int = 3 # maximum number of times Lucky Strike can be used
var curr_lucky_count : int = 0

func _ready() -> void:
	for interactable : InteractableTask in interactable_tasks:
		interactable.create_instances()
		interactable.task_completed.connect(_on_interactable_task_completed)
		for instance in interactable.task_instances:
			curr_tasks.push_back(instance)

	tasks_updated.emit(curr_tasks)

func get_random_task() -> InteractableTask:
	return interactable_tasks.pick_random()

func is_incomplete(task: Task) -> bool:
	return task.status == Task.Status.INCOMPLETE


# filter the array for incomplete tasks
# return the first item of the array
func complete_random_task():
	var incomplete_tasks : Array[Task] = curr_tasks.filter(func(t): return t.status == Task.Status.INCOMPLETE)
	if not incomplete_tasks.is_empty():
		var first : Task = incomplete_tasks[0]	
		first.complete_task()		
		print("Lucky Strike hits! %s has been completed!" % first.description)
		curr_lucky_count += 1
		tasks_updated.emit(curr_tasks)

func _on_interactable_task_completed(_task: Task) -> void:
	# if task in curr_tasks:
	tasks_updated.emit(curr_tasks)

	# check for Lucky Strike upgrade
	# AND has not been activated more than LUCKY_COUNT times
	var lucky : LevelUpgradeInfo = preload("res://upgrades/lucky_strike.tres")
	if lucky in GameManager.chosen_upgrades:
		var x = randi_range(0, 1)
		if x == 0:
			complete_random_task()
	
	# check if there are any incomplete tasks
	var has_incomplete = curr_tasks.any(is_incomplete)
	if not has_incomplete:
		all_tasks_completed.emit()
		is_tasks_completed = true
		var day : Day = get_parent()	
		day.end_day()