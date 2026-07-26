class_name TaskManager
extends Node

signal tasks_updated(tasks : Array[Task])
signal all_tasks_completed

@export var interactable_tasks : Array[InteractableTask] = [] # all the interactable tasks in the scene
@export var curr_tasks : Array[Task] = []
var is_tasks_completed : bool = false 

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


func _on_interactable_task_completed(_task: Task) -> void:
	# if task in curr_tasks:
	tasks_updated.emit(curr_tasks)

	# check if there are any incomplete tasks
	var has_incomplete = curr_tasks.any(is_incomplete)
	if not has_incomplete:
		all_tasks_completed.emit()
		is_tasks_completed = true
