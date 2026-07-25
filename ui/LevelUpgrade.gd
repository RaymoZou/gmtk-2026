extends Panel

@export var upgrade_info : LevelUpgradeInfo

func _ready() -> void:
	%Title.text = upgrade_info.title
	%Icon.texture = upgrade_info.icon
	%Description.text = upgrade_info.description
	%FunnyDescription.text = "[i]%s[/i]" % upgrade_info.funny_text
