extends CanvasLayer

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/day.tscn")
