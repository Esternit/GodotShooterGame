extends CharacterBody3D


#@export var player_path : NodePath 
@export var accuracy : float
@onready var nav_agent = $"NavigationAgent3D"
@onready var player = get_tree().root.find_child("Player", true, false)

signal health_depleted

var shootcast
var bullet = load("res://bullet.tscn")
var instance
var timer = 0

#var player = null
var health = 3


const SPEED = 2.0
const ATTACK_RANGE = 2.0
var has_seen_enemy : bool

func _physics_process(_delta):
	move_and_slide()
	

func _ready():
	#player = get_node(player_path)
	shootcast = $pistol/ShootCast

func _process(delta):

	if shootcast.is_colliding() == true and shootcast.get_collider().name == "Player" and timer >= 3.0:
		
		timer = 0
		print("see you", timer)
		has_seen_enemy = true
	else:
		timer += delta
		has_seen_enemy = false
		
	#velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	var new_velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)
	
	
	if has_seen_enemy == true:
		instance = bullet.instantiate()
		instance.position = shootcast.global_position
		instance.transform.basis = shootcast.global_transform.basis
		get_parent().add_child(instance)	
	
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)

	

func hitter(dmg):
	health -= dmg
	print(health)
	if health <= 0:
		health_depleted.emit()
		queue_free()


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
	

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -90 and +90 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))

	# We calculate a random speed (integer)
	var random_speed = SPEED
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)
