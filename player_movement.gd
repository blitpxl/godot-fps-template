extends CharacterBody3D
class_name FPSPlayer

@export var camera_speed: float = 0.1
@export var camera_tilt: float = 1.0
@export var move_speed: float = 25.0
@onready var camera: Camera3D = $Camera

var mouse_motion_relative: Vector2 = Vector2(0, 0)
var unrotated_velocity: Vector3 = Vector3(0, 0, 0)
var lateral_movement: bool = false
var longitudinal_movement: bool = false
var _move_speed: float = move_speed

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion_relative = event.relative
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	camera.rotation.x -= mouse_motion_relative.y * camera_speed * delta
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -90, 90)  # for neck safety
	rotation.y -= mouse_motion_relative.x * camera_speed * delta
	mouse_motion_relative = Vector2(0, 0)
	
	if Input.is_action_pressed("move_forward"):
		velocity.z -= _move_speed * delta
		longitudinal_movement = true
	elif Input.is_action_pressed("move_backward"):
		velocity.z += _move_speed * delta
		longitudinal_movement = true
	else:
		longitudinal_movement = false
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= _move_speed * delta
		lateral_movement = true
	elif Input.is_action_pressed("move_right"):
		velocity.x += _move_speed * delta
		lateral_movement = true
	else:
		lateral_movement = false
		
	if lateral_movement and longitudinal_movement:
		_move_speed = move_speed / 2
	else:
		_move_speed = move_speed
	
	unrotated_velocity = velocity
	velocity = velocity.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_slide()
	velocity = unrotated_velocity
	velocity = lerp(velocity, Vector3(0, velocity.y, 0), 8 * delta)
	
	# show me your tilts
	if Input.is_action_just_pressed("move_left"):
		create_tween().tween_property(camera, "rotation_degrees:z", camera_tilt,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif Input.is_action_just_released("move_left") and not lateral_movement:
		create_tween().tween_property(camera, "rotation_degrees:z", 0, 
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	if Input.is_action_just_pressed("move_right"):
		create_tween().tween_property(camera, "rotation_degrees:z", -camera_tilt,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif Input.is_action_just_released("move_right") and not lateral_movement:
		create_tween().tween_property(camera, "rotation_degrees:z", 0,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	
	if Input.is_action_just_pressed("move_forward"):
		create_tween().tween_property(self, "rotation_degrees:x", camera_tilt,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif Input.is_action_just_released("move_forward") and not longitudinal_movement:
		create_tween().tween_property(self, "rotation_degrees:x", 0, 
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	if Input.is_action_just_pressed("move_backward"):
		create_tween().tween_property(self, "rotation_degrees:x", -camera_tilt,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif Input.is_action_just_released("move_backward") and not longitudinal_movement:
		create_tween().tween_property(self, "rotation_degrees:x", 0,
		0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
