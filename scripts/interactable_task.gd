class_name InteractableTask
extends Interactable

signal task_completed(task : Task)

@export var task : Task # to be populated in the Inspector
@export var sfx : Resource # to be populated in the Inspector
@onready var sound_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	task = task.duplicate() # so we don't modify the original
	interact_text = task.description
	sound_player.stream = sfx

func interact(_body: Node3D):
	if task and task.status != Task.Status.COMPLETED:
		task.complete_task()
		task_completed.emit(task)
		sound_player.play()
