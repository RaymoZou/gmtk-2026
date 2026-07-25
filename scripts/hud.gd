extends CanvasLayer

@onready var day : Day = get_parent()
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var task_item_ui : PackedScene = preload("res://ui/TaskItemUI.tscn")
@export var task_manager : TaskManager
# tasks is description : {completed : total}
var tasks: Dictionary[String, Dictionary] = {}

# we want the actual clock to start at 9am
const OFFSET : int = 9

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	task_manager.tasks_updated.connect(_on_tasks_updated)
	task_manager.all_tasks_completed.connect(_on_all_tasks_completed)
	%RestartButton.pressed.connect(_button_pressed)

	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)
	player.hold_progress.connect(_on_hold_progress)


func _on_tasks_updated(new_tasks : Array[Task]) -> void:
	for child in %Tasks.get_children():
		child.queue_free()
	tasks.clear()

	# construct the dictionary
	for task : Task in new_tasks:
		if task.description not in tasks:
			tasks[task.description] = {"completed": 0, "total": 0}
		tasks[task.description]["total"] += 1
		if task.status == Task.Status.COMPLETED:
			tasks[task.description]["completed"] += 1

	# render the dictionary
	for desc : String in tasks.keys():
		var label : RichTextLabel = task_item_ui.instantiate()
		var completed : int = tasks[desc]["completed"]
		var total : int = tasks[desc]["total"]
		label.text = "%s (%d/%d)" % [desc, completed, total]
		if completed == total:
			label.modulate = Color.GREEN
		%Tasks.add_child(label)

func _on_all_tasks_completed() -> void:
	%AllDoneLabel.show()

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/day.tscn")

# new_hour will be between 9 and 17
func _on_hour_updated(new_hour : int):
	%HourLabel.text = "%s (%d hours remaining)" % [day.get_readable_hour(), day.get_remaining_hours()]
	%HourProgressBar.value = new_hour - OFFSET
	# TODO: enable animation - it looks weird so disabled for now
	# animation_player.play("hour_changed")

func _on_day_ended(success: bool):
	%DayOverMenu.show()
	if success:
		%DayOverLabel.text = "You survive to work another day..."
		%DayOverLabel.modulate = Color.GREEN
	else:
		%DayOverLabel.text = "GAME OVER :("
		%DayOverLabel.modulate = Color.RED

func _on_focused_changed(text: String, visible: bool) -> void:
	%InteractLabel.visible = visible
	if visible:
		%InteractLabel.text = "[E] " + text

func _on_hold_progress(progress: float) -> void:
	%HoldProgressBar.value = progress * 100.0
	%HoldProgressBar.visible = progress > 0.0
