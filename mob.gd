extends CharacterBody3D


@export var player_path : NodePath 
@export var accuracy : float
@onready var nav_agent = $"NavigationAgent3D"

var shootcast
var bullet = load("res://bullet.tscn")
var instance
var timer = 0

var player = null
var health = 3

const SPEED = 2.0
const ATTACK_RANGE = 2.0
var has_seen_enemy : bool

func _physics_process(_delta):
	move_and_slide()
	

func _ready():
	player = get_node(player_path)
	shootcast = $pistol/ShootCast

func _process(delta):

	if shootcast.is_colliding() == true and shootcast.get_collider().name == "Player" and timer >= 3.0:
		
		timer = 0
		print("see you", timer)
		has_seen_enemy = true
	else:
		timer += delta
		has_seen_enemy = false
		
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	
	if has_seen_enemy == true:
		instance = bullet.instantiate()
		instance.position = shootcast.global_position
		instance.transform.basis = shootcast.global_transform.basis
		get_parent().add_child(instance)	
	
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)

	move_and_slide()

func hitter(dmg):
	health -= dmg
	print(health)
	if health <= 0:
		queue_free()
