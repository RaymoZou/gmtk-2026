extends Control

# NOTE: assume main.tscn is the parent
@onready var day : Day = get_parent()

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	%RestartButton.pressed.connect(_button_pressed)

func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_hour_updated(_new_hour : int):
	%HourLabel.text = day.get_readable_hour()

# show a button that will reset the game
func _on_day_ended():
	%DayOverMenu.show()
