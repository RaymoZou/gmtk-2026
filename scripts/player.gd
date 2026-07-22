extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var move_speed: float = 2

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.003
@export var min_pitch_deg: float = -89.0
@export var max_pitch_deg: float = 89.0

@onready var camera_pivot: Node3D = $Camera3D

var _pitch: float = 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Release/recapture mouse with Escape (handy for testing/UI)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Yaw: rotate the whole body left/right
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Pitch: rotate only the camera pivot up/down, clamped
		_pitch = clamp(
			_pitch - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
		camera_pivot.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Movement input relative to facing direction
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta * move_speed)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta * move_speed)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta * move_speed)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta * move_speed)

	move_and_slide()
