extends CanvasLayer

# NOTE: assume main.tscn is the parent
@onready var day : Day = get_parent()

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	day.tasks_updated.connect(_on_tasks_updated)
	day.all_tasks_completed.connect(_on_all_tasks_completed)
	%RestartButton.pressed.connect(_button_pressed)

	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)

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
	%AllDoneLabel.visible = false

func _on_all_tasks_completed() -> void:
	%AllDoneLabel.show()

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_hour_updated(_new_hour : int):
	%HourLabel.text = day.get_readable_hour()

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
