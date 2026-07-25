class_name HUD
extends CanvasLayer

@onready var day : Day = get_parent()
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var task_item_ui : PackedScene = preload("res://ui/TaskItemUI.tscn")
@export var task_manager : TaskManager
# tasks is description : {completed : total}
var tasks: Dictionary[String, Dictionary] = {}

# UPGRADES
@onready var card_template : PackedScene = preload("res://ui/UpgradeCard.tscn")
@export var curr_selected : LevelUpgradeInfo
const MAX_OPTIONS = 3

# we want the actual clock to start at 9am
const OFFSET : int = 9

func _ready() -> void:
	day.hour_updated.connect(_on_hour_updated)
	day.day_ended.connect(_on_day_ended)
	task_manager.tasks_updated.connect(_on_tasks_updated)
	task_manager.all_tasks_completed.connect(_on_all_tasks_completed)

	# CONNECT PLAYER SIGNALS - NOTE: maybe move this to EventBus?
	var player := get_parent().get_node("Player")
	player.focused_changed.connect(_on_focused_changed)
	player.hold_progress.connect(_on_hold_progress)
	player.energized_changed.connect(_on_energized_changed)

	# check for Speedwalk upgrade
	var speedwalk_upgrade : LevelUpgradeInfo = preload("res://upgrades/speedwalk.tres")
	if speedwalk_upgrade in GameManager.chosen_upgrades:
		%SpeedwalkIcon.show()	


	var num_options : int = min(GameManager.available_options.size(), MAX_OPTIONS)
	for i in num_options:
		var random_upgrade : LevelUpgradeInfo = GameManager.available_options.pick_random()
		var template : LevelUpgradeCard = card_template.instantiate()
		template.upgrade_info = random_upgrade
		%CardContainer.add_child(template)
	%RestartButton.pressed.connect(_on_button_pressed)
	GameManager.upgrade_selected.connect(_on_upgrade_selected)

func _on_upgrade_selected(upgrade: LevelUpgradeInfo):
	curr_selected = upgrade

# end the day and restart
# TODO: create a game over button that restarts the GameManager game state
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/day.tscn")
	if curr_selected:
		GameManager.chosen_upgrades.push_back(curr_selected)
		GameManager.available_options.erase(curr_selected)

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

func _on_energized_changed(is_energized : bool) -> void:
	if is_energized:
		%EnergizedIcon.show()
	else:
		%EnergizedIcon.hide()

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
		%DayOverLabel.text = "HR would like to have a word with you in their office..."
		%DayOverLabel.modulate = Color.RED
		# clear the GameManager game state
		%RestartButton.text = "PLAY AGAIN"

func _on_focused_changed(text: String, visible: bool) -> void:
	%InteractLabel.visible = visible
	if visible:
		%InteractLabel.text = "[E] " + text

func _on_hold_progress(progress: float) -> void:
	%HoldProgressBar.value = progress * 100.0
	%HoldProgressBar.visible = progress > 0.0
