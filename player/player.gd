extends Area2D

signal hit
signal enemy_killed

@onready var Bullet = preload("res://weapons/Bullet.tscn")

@export var speed = 400
var can_shoot = true
var screen_size
var direction_to_mouse = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = get_global_mouse_position()
	direction_to_mouse = (mouse_position - position).normalized()
	var perpendicular = Vector2(-direction_to_mouse.y, direction_to_mouse.x)

	look_at(mouse_position)


	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity += perpendicular * speed
	if Input.is_action_pressed("move_left"):
		velocity -= perpendicular * speed
	if Input.is_action_pressed("move_down"):
		velocity -= direction_to_mouse * speed
	if Input.is_action_pressed("move_up"):
		velocity += direction_to_mouse * speed
	if Input.is_action_pressed("primary_fire"):
		if can_shoot:
			fire_bullet()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func fire_bullet():
	$FireTimer.start()
	can_shoot = false
	var bullet = Bullet.instantiate()
	bullet.global_position = position + direction_to_mouse * 10
	bullet.rotation = direction_to_mouse.angle()

    # Add the bullet to the scene tree
	get_parent().add_child(bullet)

    # Emit the fire signal on the bullet
	bullet.emit_signal("_on_fire")

func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	print("Player position: ", position)
	print("Player group:", is_in_group("player"))
	$CollisionShape2D.disabled = false

func on_fire_timer_reset():
	can_shoot = true

func _on_enemy_killed():
	enemy_killed.emit()