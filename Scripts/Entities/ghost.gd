extends CharacterBody2D

@export var speed = 80
@export var teleport_distance = 50  # Distance threshold for teleportation
@export var teleport_offset = -64   # Distance to teleport behind the player
@export var max_health = 50
@export var health = 50
@export var enemy_damage = 10

@onready var player = null

var direction = Vector2.ZERO
var chasing = false
var being_hit = false
var has_teleported = false

func _ready():
	player = get_node("/root/Floor1/Player")

func _physics_process(delta):
	if chasing and player and !being_hit:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player < teleport_distance and not has_teleported:
			teleport_to_opposite_side()
		else:
			var input_vector = (player.position - position).normalized()
			direction = input_vector
			velocity = input_vector * speed
			move_and_slide()

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		chasing = true

func teleport_to_opposite_side():
	# Calculate the direction from the ghost to the player
	var direction_to_player = (player.position - position).normalized()
	# Calculate the teleport position on the opposite side of the player
	var teleport_position = player.position - (direction_to_player * teleport_offset)
	# Set the ghost's position to the teleport position
	position = teleport_position
	# Mark that the ghost has teleported
	has_teleported = true

func take_damage(amount):
	if being_hit:
		return  # Prevent taking damage again if already being hit

	print("Enemy took damage: ", amount)
	being_hit = true
	health -= amount
	if health <= 0:
		die()
	else:
		has_teleported = false
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
