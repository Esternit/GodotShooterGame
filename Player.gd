extends CharacterBody3D

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
@onready var walldetec = $WallDetector

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0 

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var health = 3
var bullet = load("res://bullet.tscn")
var instance
var just_shot = false

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0 
const JUMP_VELOCITY = 10.0

var threshold_time = 0.2
var timer = 0
var action_started = false
var climbing = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if event.is_action("shoot") and event.is_pressed() and not event.is_echo():
		just_shot = true
		play_shoot_effects()
		instance = bullet.instantiate()
		instance.position = raycast.global_position
		instance.transform.basis = raycast.global_transform.basis
		get_parent().add_child(instance)
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.health -= 1
		just_shot = false
		
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not climbing:
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept"):
		action_started = true
		
	if Input.is_action_pressed("ui_accept") and action_started:
		timer += delta
		
	if timer >= threshold_time and action_started:
		action_started = false
		timer = 0
		if walldetec.is_colliding():
			climbing = true
			print(climbing)

	if Input.is_action_just_released("ui_accept"):
		if timer < threshold_time and action_started:
			
			print("press")
		action_started = false
		climbing = false
		timer = 0
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and climbing == false:
		velocity.y = JUMP_VELOCITY

	
	if Input.is_action_just_pressed("sprint"):
		speed = SPRINT_SPEED
	if Input.is_action_just_released("sprint") or speed == null:
		speed = WALK_SPEED

		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("IdleAnimation")
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
	move_and_slide()

func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP + 1.225
	pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	return pos
	
