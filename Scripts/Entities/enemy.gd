extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health = 30
@export var health = 30
@export var enemy_damage = 10

var being_hit = false
var chasing = false
var player = null
var direction = Vector2.ZERO

@onready var hit_area = $HitArea

var animations = {
	Vector2.UP: "up",
	Vector2.DOWN: "down",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right",
	Vector2(1, -1): "upright",
	Vector2(-1, -1): "upleft",
	Vector2(1, 1): "downright",
	Vector2(-1, 1): "downleft"
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta):
	if chasing and player and !being_hit:
		var input_vector = (player.position - position).normalized()
		direction = input_vector

		velocity = input_vector * speed
		move_and_slide()

		update_animation()

	if being_hit:
		print("Enemy is being hit, not moving.")

func update_animation():
	if direction == Vector2.ZERO:
		return

	var anim = ""

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim = "right"
		else:
			anim = "left"
	else:
		if direction.y > 0:
			anim = "down"
		else:
			anim = "up"

	if abs(direction.x) > 0.5 and abs(direction.y) > 0.5:
		if direction.x > 0 and direction.y < 0:
			anim = "upright"
		elif direction.x < 0 and direction.y < 0:
			anim = "upleft"
		elif direction.x > 0 and direction.y > 0:
			anim = "downright"
		elif direction.x < 0 and direction.y > 0:
			anim = "downleft"

	if anim != "":
		animated_sprite.play(anim)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		chasing = true
		print("Chasing!")

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		chasing = false
		animated_sprite.stop()

func take_damage(amount):
	if being_hit:
		return  # Prevent taking damage again if already being hit

	print("Enemy took damage: ", amount)
	being_hit = true
	health -= amount
	if health <= 0:
		die()
	else:
		start_knockback()

func start_knockback():
	# Stop movement and start a timer to resume movement after knockback duration
	print("Enemy is in knockback.")
	velocity = Vector2.ZERO  # Stop movement
	var knockback_duration = 1.0  # Adjust as needed
	await get_tree().create_timer(knockback_duration).timeout
	being_hit = false
	print("Enemy knockback ended.")

func die():
	print("Enemy died.")
	queue_free()

func _on_hit_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(enemy_damage)
