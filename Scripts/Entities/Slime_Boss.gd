extends CharacterBody2D

@export var speed = 100
@export var jump_force = 500
@export var health = 1000
@export var max_health = 1000
@export var enemy_damage = 20
@export var teleport_offset = -100


@export var minion_scene = preload("res://Scenes/Entities/slime_minion.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var shockwave = $Shockwave_Sprite
@onready var health_bar = $CanvasLayer/HealthBar
@onready var slam_area = $"Slam Area"
@onready var player = null

var phase = 1
var action_timer = 0.0
var base_action_interval = 3.0  # Base time between actions, can be adjusted
var action_interval = base_action_interval  # Current interval between actions
var minions = []
var can_spawn_minions = true
var moving = true
var is_jumping = false

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	_start_phase(1)
	player = Global.player 

func _process(delta):
	# Debug print for current animation
	print("Current animation:", animated_sprite.animation)

func _physics_process(delta):
	if health <= 0:
		die()

	action_timer -= delta
	if action_timer <= 0:
		perform_action()
		# Set next action interval with some randomness
		action_interval = base_action_interval + randf() * 2
		action_timer = action_interval

	# Handle movement towards player
	if player and moving and not is_jumping:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

	update_animation()

func update_animation():
	if health <= 0:
		animated_sprite.play("dead")
	elif animated_sprite.animation != "teleportin" and animated_sprite.animation != "teleportout" and animated_sprite.animation != "slam":
		if is_jumping:
			animated_sprite.play("jump")
		elif velocity.length() > 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("idle")

func _start_phase(new_phase):
	phase = new_phase

func update_phase():
	if health <= max_health * 0.5 and phase < 2:
		_start_phase(2)

func perform_action():
	match phase:
		1:
			perform_phase_1_action()
		2:
			perform_phase_2_action()

func perform_phase_1_action():
	# Randomly choose an action
	var action = randi() % 4
	match action:
		0:
			jump_towards_player()
		1:
			spawn_minions(3)  # Adjust the number of minions as needed
		2:
			teleport_to_opposite_side()
		3:
			area_attack()

func perform_phase_2_action():
	# Randomly choose an action
	var action = randi() % 4
	match action:
		0:
			jump_towards_player()
		1:
			spawn_minions(5)  # Adjust the number of minions as needed
		2:
			teleport_to_opposite_side()
		3:
			area_attack()

func jump_towards_player():
	if player and moving:
		is_jumping = true
		var direction = (player.position - position).normalized()
		velocity.y = -jump_force
		velocity.x = direction.x * speed
		await get_tree().create_timer(1).timeout
		is_jumping = false
		update_animation()

func spawn_minions(amount):
	if can_spawn_minions:
		for i in range(amount):
			var minion_instance = minion_scene.instantiate()
			get_parent().add_child(minion_instance)
			minion_instance.global_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			minions.append(minion_instance)  # Add the minion to the list

func area_attack():
	# Implement an area attack
	moving = false
	print("slamming")
	animated_sprite.play("slam")
	var area_damage = 50
	var area_radius = 200
	var bodies = slam_area.get_overlapping_bodies()
	await get_tree().create_timer(1).timeout
	shockwave.play("shockwave")
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(area_damage)
	moving = true
	animated_sprite.play("jump")
	update_animation()

func teleport_to_opposite_side():
	moving = false
	animated_sprite.play("teleportin")
	await get_tree().create_timer(1).timeout
	# Calculate the direction from the enemy to the player
	var direction_to_player = (player.position - position).normalized()
	# Calculate the teleport position on the opposite side of the player
	var teleport_position = player.position - (direction_to_player * teleport_offset)
	# Set the enemy's position to the teleport position
	position = teleport_position
	animated_sprite.play("teleportout")
	await get_tree().create_timer(1).timeout
	area_attack()
	update_animation()

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func _on_hit_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(enemy_damage)

func die():
	animated_sprite.play("dead")
	for minion in minions:
		if minion and is_instance_valid(minion):
			minion.queue_free()
	await get_tree().create_timer(1).timeout
	queue_free()
