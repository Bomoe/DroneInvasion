extends Node

@export var enemy_scene: PackedScene
var total_kills = 0
var enemies = []
var time_elapsed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over():
	toggle_is_game_over(true)

func new_game():
	get_tree().call_group("enemy", "queue_free")
	toggle_is_game_over(false)
	total_kills = 0
	time_elapsed = 0
	$KillCountLabel.text = "0 Enemies Killed"
	$TimeElapsedLabel.text = "00:00:00"
	$HealthLabel.text = "%s Lives Left" % $Player.max_health
	$Player.start($StartPos.position)
	$StartTimer.start()
	GlobalSettings.current_enemy_speed = GlobalSettings.max_enemy_speed

func toggle_is_game_over(isGameOver):
	if isGameOver:
		$GameOverLabel.show()
		$GameOverPanel.show()
		$TryAgainButton.show()
		$TimeElapsedTimer.stop()
		$EnemyTimer.stop()
	else:
		$GameOverLabel.hide()
		$GameOverPanel.hide()
		$TryAgainButton.hide()

func _on_start_timer_timeout():
	$EnemyTimer.start()
	$TimeElapsedTimer.start()

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
	$KillCountLabel.text = "%s Enemies Killed" % total_kills

func _on_player_life_lost(newHealth) -> void:
	if newHealth >= 0:
		$HealthLabel.text = "%s Lives Left" % newHealth
	else:
		game_over()


func _on_time_elapsed_timer_timeout() -> void:
	time_elapsed += 1
	var hours = time_elapsed / 3600
	var minutes = (time_elapsed % 3600) / 60
	var seconds = time_elapsed % 60
	$TimeElapsedLabel.text = "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_try_again_button_pressed() -> void:
	new_game()
