extends Node

@export var enemy_scene: PackedScene
var score
var total_kills = 0
var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over():
	$ScoreTimer.stop()
	$EnemyTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPos.position)
	$StartTimer.start()

func _on_score_timer_timeout():
	score += 1

func _on_start_timer_timeout():
	$EnemyTimer.start()
	$ScoreTimer.start()

func _on_enemy_timer_timeout():
	# Create a new instance of the enemy scene.
	var enemy = enemy_scene.instantiate()

	# Choose a random location on Path2D.
	var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
	enemy_spawn_location.progress_ratio = randf()

	# Set the enemy's direction perpendicular to the path direction.
	var direction = enemy_spawn_location.rotation + PI / 2

	# Set the enemy's position to a random location.
	enemy.position = enemy_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	enemy.rotation = direction

	# Choose the velocity for the enemy.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	enemy.linear_velocity = velocity.rotated(direction)

	# Spawn the enemy by adding it to the Main scene.
	add_child(enemy)

func _on_enemy_killed():
	total_kills += 1
	if total_kills % 10 == 0 and $EnemyTimer.wait_time > 0.20:
		enemies = get_tree().get_nodes_in_group("enemy")
		var enemy_to_call = enemies[0]
		enemy_to_call.call("_on_increase_speed")
		$EnemyTimer.wait_time -= 0.10
	print("Killed enemy, new total: ", total_kills)
	print ("New Enemy Timer wait time: ", $EnemyTimer.wait_time)
