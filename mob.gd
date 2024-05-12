extends CharacterBody3D


@export var player_path : NodePath 

@onready var nav_agent = $"NavigationAgent3D"

var player = null
var health = 3
const SPEED = 2.0
const ATTACK_RANGE = 2.0

func _physics_process(_delta):
	move_and_slide()
	

func _ready():
	player = get_node(player_path)

func _process(delta):
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()

func hitter(dmg):
	health -= dmg
	print(health)
	if health <= 0:
		queue_free()
