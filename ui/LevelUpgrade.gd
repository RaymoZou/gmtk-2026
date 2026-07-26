class_name LevelUpgradeCard
extends Button

var upgrade_info : LevelUpgradeInfo

func _ready() -> void:
	%Title.text = upgrade_info.title
	%Icon.texture = upgrade_info.icon
	%Description.text = upgrade_info.description
	%FunnyDescription.text = "[i]%s[/i]" % upgrade_info.funny_text
	pressed.connect(_on_pressed)
	GameManager.upgrade_selected.connect(_on_upgrade_selected)

func _on_pressed() -> void:
	GameManager.upgrade_selected.emit(upgrade_info)

# TODO: make a StyleBoxFlat border and save it as a scene
func _on_upgrade_selected(selected: LevelUpgradeInfo) -> void:
	if selected == upgrade_info:
		var border_style := StyleBoxFlat.new()
		border_style.bg_color = Color(0, 0.6, 1, 0.2)
		border_style.border_color = Color(0, 0.6, 1, 1)
		border_style.border_width_top = 3
		border_style.border_width_bottom = 3
		border_style.border_width_left = 3
		border_style.border_width_right = 3
		border_style.corner_radius_top_left = 8
		border_style.corner_radius_top_right = 8
		border_style.corner_radius_bottom_left = 8
		border_style.corner_radius_bottom_right = 8
		border_style.content_margin_top = 8
		border_style.content_margin_bottom = 8
		border_style.content_margin_left = 8
		border_style.content_margin_right = 8
		add_theme_stylebox_override("normal", border_style)
		add_theme_stylebox_override("hover", border_style)
	else:
		reset_style()

func reset_style() -> void:
	remove_theme_stylebox_override("normal")
	remove_theme_stylebox_override("hover")
