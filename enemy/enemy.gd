extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	add_to_group("enemy")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player = get_tree().get_nodes_in_group("player")[0]
	if player and player.is_visible_in_tree(): 
		var direction = (player.position - position).normalized()
		position += direction * GlobalSettings.current_enemy_speed * delta
		look_at(player.position)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_increase_speed():
	GlobalSettings.current_enemy_speed += 10
