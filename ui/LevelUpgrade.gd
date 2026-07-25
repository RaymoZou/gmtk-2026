class_name LevelUpgradeCard
extends Button

var upgrade_info : LevelUpgradeInfo

func _ready() -> void:
	%Title.text = upgrade_info.title
	%Icon.texture = upgrade_info.icon
	%Description.text = upgrade_info.description
	%FunnyDescription.text = "[i]%s[/i]" % upgrade_info.funny_text
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.upgrade_selected.emit(upgrade_info)
