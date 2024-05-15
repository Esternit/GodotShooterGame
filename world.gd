extends Node

@export var mob_scene: PackedScene
var countmobs = 1

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_mob_timer_timeout():
	print("timer")
	if(countmobs <= 5):
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

		# Choose a random location on the SpawnPath.
		# We store the reference to the SpawnLocation node.
		var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
		# And give it a random offset.
		mob_spawn_location.progress_ratio = randf()

		var player_position = $Player.position
		mob.initialize(mob_spawn_location.position, player_position)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
		countmobs+=1
		print("mob spawned")


func _on_mob_health_depleted():
	countmobs-=1
