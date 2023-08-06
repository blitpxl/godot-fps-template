extends Camera3D

var mouse_delta: Vector2
var y_look_sensitivity: float
var is_crouching: bool = false

const STAND_HEIGHT = 1.5
const CROUCH_HEIGHT = 0.1

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching
	
func enable_dof(on: bool = true):
	attributes.dof_blur_near_enabled = on
	
func _process(delta):
	if is_crouching:
		position.y = lerpf(position.y, CROUCH_HEIGHT, 10 * delta)
	else:
		position.y = lerpf(position.y, STAND_HEIGHT, 10 * delta)
	
func _physics_process(delta):
	rotation.x += (-mouse_delta.y * y_look_sensitivity * delta)
	rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	mouse_delta = Vector2(0, 0)
