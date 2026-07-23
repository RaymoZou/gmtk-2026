class_name Interactable
extends Area3D

signal task_completed(task: Task)

@export var interact_text : String = "Interact"
@export var can_interact : bool = true
@export var task : Task

func _ready() -> void:
	add_to_group("interactables")

func interact(_body: Node3D):
	if task and task.status != Task.Status.COMPLETED:
		task.complete_task()
		task_completed.emit(task)