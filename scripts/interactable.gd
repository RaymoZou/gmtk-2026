@abstract
class_name Interactable
extends Area3D

signal task_completed(task: Task)

@export var interact_text : String = "Interact"
@export var can_interact : bool = true

func _ready() -> void:
	add_to_group("interactables")

@abstract
func interact(_body: Node3D)