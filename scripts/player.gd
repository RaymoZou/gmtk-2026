class_name Player
extends CharacterBody3D
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var move_speed: float = 2
@export var hold_duration: float = 2 # how long to hold to complete a task

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.003
@export var min_pitch_deg: float = -89.0
@export var max_pitch_deg: float = 89.0

signal focused_changed(text: String, visible: bool)
signal hold_progress(progress: float)
# TODO: generalize energized_changed to status_changed
signal energized_changed(status: bool) # status change after drinking coffee

@onready var camera_pivot: Node3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/InteractRay
@onready var day : Day = get_parent()

var _pitch: float = 0.0
var _focused_interactable: Interactable = null
var _is_holding: bool = false
var _hold_progress: float = 0.0
const SPEED_MULTIPLIER : float = 1.5 # for the Speedwalk Upgrade


func _ready() -> void:

	# check for Speedwalk Upgrade
	var speedwalk_upgrade : LevelUpgradeInfo = preload("res://upgrades/speedwalk.tres")
	if speedwalk_upgrade in GameManager.chosen_upgrades:
		move_speed *= SPEED_MULTIPLIER
		print("Speedwalk detected. Move speed is now %d" % move_speed)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	day.day_ended.connect(_on_day_ended)

# temporarily decreases hold time by 'hold' seconds
# for 'duration' seconds
func increase_productivity(hold_factor : float, duration: float):
	var prev_hold : float = hold_duration
	hold_duration = (hold_duration / hold_factor)
	energized_changed.emit(true)
	await get_tree().create_timer(duration).timeout
	energized_changed.emit(false)
	hold_duration = prev_hold


func _on_day_ended(_success: bool):
	print("day has ended")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

	if event.is_action_pressed("interact") and _focused_interactable and _focused_interactable.can_interact:
		_focused_interactable.is_interacting = true
		_is_holding = true
		_hold_progress = 0.0
		hold_progress.emit(0.0)

	if event.is_action_released("interact") and _is_holding:
		if _focused_interactable:
			_focused_interactable.is_interacting = false
		_is_holding = false
		_hold_progress = 0.0
		hold_progress.emit(0.0)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		_pitch = clamp(
			_pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
		camera_pivot.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta * move_speed)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta * move_speed)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta * move_speed)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta * move_speed)

	move_and_slide()
	_update_focused()


func _process(delta: float) -> void:
	if _is_holding:
		if _focused_interactable and _focused_interactable.can_interact:
			_hold_progress = min(_hold_progress + delta / hold_duration, 1.0)
			hold_progress.emit(_hold_progress)

			# finished holding
			if _hold_progress >= 1.0:
				_focused_interactable.is_interacting = false
				_focused_interactable.interact(self)
				_is_holding = false
				_hold_progress = 0.0
				hold_progress.emit(0.0)
		else:
			_is_holding = false
			_hold_progress = 0.0
			hold_progress.emit(0.0)

func _update_focused() -> void:
	var collider = interact_ray.get_collider()
	var new_focus: Interactable = null

	if interact_ray.is_colliding() and collider is Interactable and collider.can_interact:
		new_focus = collider

	if new_focus != _focused_interactable:
		_focused_interactable = new_focus
		if _focused_interactable:
			focused_changed.emit(_focused_interactable.interact_text, true)
		else:
			focused_changed.emit("", false)
