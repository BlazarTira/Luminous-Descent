extends CharacterBody2D

@export var speed = 150
@export var erratic_factor = 0.5  # Adjust this for more or less erratic movement
@export var smooth_factor = 0.1   # Adjust this for smoother direction changes
@export var random_speed = 40     # Speed when flying randomly
@export var max_health = 30
@export var health = 30
@export var enemy_damage = 10



@onready var player = null
@onready var sprite = $AnimatedSprite2D
var direction = Vector2.ZERO
var chasing = false
var being_hit = false
var hurt = false
var dying = false

func _ready():
	player = Global.player

func _physics_process(delta):
	if chasing and player and !being_hit and !dying or hurt and !dying:
		var direction_to_player = (player.position - position).normalized()
		var random_offset = Vector2(randf() - 0.5, randf() - 0.5) * erratic_factor
		var target_direction = (direction_to_player + random_offset).normalized()
		
		# Interpolate the direction to smooth out changes
		direction = direction.lerp(target_direction, smooth_factor)
		direction = direction.normalized()
		
		velocity = direction * speed
	else:
		if direction == Vector2.ZERO or randf() < 0.01:
			# Choose a new random direction
			direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		
		velocity = direction * random_speed
	
	move_and_slide()
	update_animation()

func update_animation():
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		chasing = true

#func _on_detection_body_exited(body):
	#if body.is_in_group("player"):
		#is_chasing = false

func take_damage(amount):
	hurt = true
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
	dying = true
	print("Enemy died.")
	sprite.play("dead")
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_hit_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(enemy_damage)


