extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 4.0
@export var jump_speed: float = 4.0
@export var rotation_speed: float = 12.0
@export var mouse_sensitivity: float = 0.0015

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var body: MeshInstance3D = $Body

func _enter_tree():
	set_multiplayer_authority(int(name))
	pass

func _ready() -> void:
	print(multiplayer.is_server(), ",", name, ",",get_multiplayer_authority())
	set_process(is_multiplayer_authority())
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority():
		$SpringArm3D/Camera3D.make_current()
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += -gravity * delta
	get_move_input(delta)
	move_and_slide()
	
	if velocity.length() > 1.0:
		body.rotation.y = lerp_angle(body.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	pass

func get_move_input(delta: float):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "foreward", "backward")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
		jumping = true
	
	if is_on_floor():
		jumping = false
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	pass
