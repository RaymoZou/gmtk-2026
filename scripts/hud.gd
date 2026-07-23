extends CanvasLayer

# NOTE: assume main.tscn is the parent
@onready var day : Day = get_parent()

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	day.tasks_updated.connect(_on_tasks_updated)
	%RestartButton.pressed.connect(_button_pressed)

	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)

# it might be inefficient to re-render the entire list
# can we do it by individual task?
func _on_tasks_updated(tasks : Array[Task]) -> void:

	# clear all children
	# for task in tasks:
	# 	task.queue_free()

	# add new tasks
	for task in tasks:
		var label : Label = Label.new()
		label.text = task.description
		%Tasks.add_child(label)
		# TODO: also display the status

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_hour_updated(_new_hour : int):
	%HourLabel.text = day.get_readable_hour()

func _on_day_ended():
	%DayOverMenu.show()

func _on_focused_changed(text: String, visible: bool) -> void:
	%InteractLabel.visible = visible
	if visible:
		%InteractLabel.text = "[E] " + text
