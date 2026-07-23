extends CanvasLayer

# NOTE: assume main.tscn is the parent
@onready var day : Day = get_parent()

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	%RestartButton.pressed.connect(_button_pressed)

	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_hour_updated(_new_hour : int):
	%HourLabel.text = day.get_readable_hour()

func _on_day_ended():
	%DayOverMenu.show()

func _on_focused_changed(text: String, visible: bool) -> void:
	print(text)
	%InteractLabel.visible = visible
	if visible:
		%InteractLabel.text = "[E] " + text
