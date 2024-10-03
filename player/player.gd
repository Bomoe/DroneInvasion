extends Area2D

signal dead
signal enemy_killed
signal life_lost
signal life_add

@onready var Bullet = preload("res://weapons/Bullet.tscn")

@export var speed = 400
@export var max_health = 3
var health = max_health
var can_shoot = true
var screen_size
var direction_to_mouse = Vector2.ZERO
var is_invuln = false

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
	bullet.global_position = position + direction_to_mouse * 50
	bullet.rotation = direction_to_mouse.angle()

	# Add the bullet to the scene tree
	get_parent().add_child(bullet)

	# Emit the fire signal on the bullet
	bullet.emit_signal("_on_fire")

func _on_body_entered(body: Node2D) -> void:
	if is_invuln:
		return
	is_invuln = true
	$InvulnTimer.start()
	$AnimatedSprite2D.self_modulate.a = .5
	if health <= 0:
		dead.emit()
		$CollisionShape2D.set_deferred("disabled", true)
		hide()
	health -= 1
	life_lost.emit(health)
	

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	health = max_health
	$AnimatedSprite2D.self_modulate.a = 1
	

func on_fire_timer_reset():
	can_shoot = true

func _on_enemy_killed():
	enemy_killed.emit()


func _on_invuln_timer_timeout() -> void:
	is_invuln = false
	$AnimatedSprite2D.self_modulate.a = 1
	
