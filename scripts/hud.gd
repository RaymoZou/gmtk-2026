extends CanvasLayer

@onready var day : Day = get_parent()
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var task_manager : TaskManager

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	task_manager.tasks_updated.connect(_on_tasks_updated)
	task_manager.all_tasks_completed.connect(_on_all_tasks_completed)
	%RestartButton.pressed.connect(_button_pressed)

	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)
	player.hold_progress.connect(_on_hold_progress)



func _on_tasks_updated(tasks : Array[Task]) -> void:
	for child in %Tasks.get_children():
		child.queue_free()

	for task in tasks:
		var label := Label.new()
		match task.status:
			Task.Status.COMPLETED:
				label.text = "[x] " + task.description
				label.modulate = Color.GREEN
			Task.Status.FAILED:
				label.text = "[!] " + task.description
				label.modulate = Color.RED
			_:
				label.text = "[ ] " + task.description
		%Tasks.add_child(label)

func _on_all_tasks_completed() -> void:
	%AllDoneLabel.show()

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/day.tscn")

func _on_hour_updated(_new_hour : int):
	%HourLabel.text = day.get_readable_hour()
	animation_player.play("hour_changed")

func _on_day_ended(success: bool):
	%DayOverMenu.show()
	if success:
		%DayOverLabel.text = "All tasks completed!"
		%DayOverLabel.modulate = Color.GREEN
	else:
		%DayOverLabel.text = "GAME OVER"
		%DayOverLabel.modulate = Color.RED

func _on_focused_changed(text: String, visible: bool) -> void:
	%InteractLabel.visible = visible
	if visible:
		%InteractLabel.text = "[E] " + text

func _on_hold_progress(progress: float) -> void:
	%HoldProgressBar.value = progress * 100.0
	%HoldProgressBar.visible = progress > 0.0