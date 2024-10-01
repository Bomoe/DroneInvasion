extends RigidBody2D

@export var speed = 1000
var direction = Vector2.ZERO
var player


func _ready() -> void:
	player = get_parent().get_node("/root/Main")
	_on_fire()

func _process(delta: float) -> void:
	pass

func _on_fire():
	direction = (get_global_mouse_position() - global_position).normalized()
	linear_velocity = direction * speed
	print("Fired")
	emit_signal("on_fire")

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	player.call("_on_enemy_killed")
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()
