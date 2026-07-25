# NOTE: there can be multiple instances of 'task'
class_name InteractableTask
extends Interactable

signal task_completed(task : Task)

@export var task_instance : Task # to be populated in the Inspector
@export var sfx : Resource # to be populated in the Inspector
@onready var sound_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
var task_instances : Array[Task]
var num_instances : int = 1 # this scales with the number of days

# duplicate the task x times
func _enter_tree() -> void:
	for i in num_instances:
		task_instances.push_back(task_instance.duplicate())

func _ready() -> void:
	interact_text = task_instance.description
	sound_player.stream = sfx

func get_incompleted_task() -> Task:
	for t in task_instances:
		if t.status == Task.Status.INCOMPLETE:
			return t
	return null

# find an incomplete task and mark it as completed
func interact(_body: Node3D):
	var task : Task = get_incompleted_task()
	if task and task.status != Task.Status.COMPLETED:
		task.complete_task()
		is_interacting = false
		sound_player.stop()
		task_completed.emit(task)

func _process(_delta: float) -> void:
	if is_interacting:
		if not sound_player.playing:
			sound_player.play()
	elif sound_player.playing:
		sound_player.stop()
