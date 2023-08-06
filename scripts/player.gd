extends CharacterBody3D

# character movement variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var mouse_delta: Vector2
@export var x_look_sensitivity: float = 0.4
@export var y_look_sensitivity: float = 0.4
@export var movement_speed: float = 25.0
@onready var ref_movement_speed = movement_speed  # reference movement speed
var unrotated_velocity: Vector3

# for normalizing movement speed when the player move in two directions, e.g forward and right
var movement_z: bool = false
var movement_x: bool = false
# say you have 25.0 as your movement speed for each direction the player move, now if the player
# move forward and to the left at the same time then you're going to end up with the equivalent
# speed of 50.0 because you're adding up the movement speed for the two directions. To mitigate this
# issue, we can check if the player is moving in two directions and then the movement speed can
# be halved to achieve the target movement speed of 25.0.

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera.y_look_sensitivity = y_look_sensitivity

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		
	if Input.is_action_just_pressed("reload"):
		$Camera/gun.reload()
		
func compute_movement(delta) -> void:
	if Input.is_action_pressed("forward"):
		velocity.z -= movement_speed * delta
		movement_z = true
	elif Input.is_action_pressed("backward"):
		velocity.z += movement_speed * delta
		movement_z = true
	else:
		movement_z = false

	if Input.is_action_pressed("right"):
		velocity.x += movement_speed * delta
		movement_x = true
	elif Input.is_action_pressed("left"):
		velocity.x -= movement_speed * delta
		movement_x = true
	else:
		movement_x = false
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y += 350 * delta
		
		
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	# normalize movement speed on multidirection
	if movement_z and movement_x and movement_speed == ref_movement_speed:
		movement_speed /= 2
	else:
		movement_speed = ref_movement_speed
	
	unrotated_velocity = velocity
	velocity = velocity.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_slide()
	mouse_delta = Vector2(0, 0)
	velocity = lerp(unrotated_velocity, Vector3(0, velocity.y, 0), 8 * delta)
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	rotation.y -= mouse_delta.x * x_look_sensitivity * delta  # mouse x movement
	compute_movement(delta)
