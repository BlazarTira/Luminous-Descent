extends CharacterBody2D

@export var speed: int = 200.0
@export var health: int = 1000000

const bottle_scene = preload("res://Scenes/Entities/flash_bottle.tscn")
@export var throw_force: float = 500.0


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

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

var direction = Vector2.ZERO
var last_non_zero_direction = Vector2.DOWN  # Default to down for initial state

func _process(_delta: float):
	update_animation()
	if Input.is_action_just_pressed("throw_bottle"):
		throw_bottle()

func _physics_process(_delta: float):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("up"):
		input_vector.y -= 1
	if Input.is_action_pressed("down"):
		input_vector.y += 1
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_vector.x += 1

	input_vector = input_vector.normalized()
	velocity = input_vector * speed

	if input_vector != Vector2.ZERO:
		direction = input_vector
		last_non_zero_direction = direction
	else:
		direction = Vector2.ZERO

	move_and_slide()
	
	var mouse_pos = get_global_mouse_position()
	

func update_animation():
	var anim = ""

	if direction == Vector2.ZERO:
		# Player is idle
		anim = "idle_" + get_animation_direction(last_non_zero_direction)
	else:
		# Player is moving
		anim = get_animation_direction(direction)

	if anim != "" and animated_sprite.animation != anim:
		animated_sprite.play(anim)

func get_animation_direction(dir: Vector2) -> String:
	if abs(dir.x) > 0 and abs(dir.y) > 0:
		if dir.x > 0 and dir.y < 0:
			return "upright"
		elif dir.x < 0 and dir.y < 0:
			return "upleft"
		elif dir.x > 0 and dir.y > 0:
			return "downright"
		elif dir.x < 0 and dir.y > 0:
			return "downleft"
	else:
		if dir.x > 0:
			return "right"
		elif dir.x < 0:
			return "left"
		elif dir.y < 0:
			return "up"
		elif dir.y > 0:
			return "down"
	return ""

func throw_bottle():
	var bottle_instance = bottle_scene.instantiate()
	get_parent().add_child(bottle_instance)
	bottle_instance.global_position = global_position

	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	# Call throw_bottle method on the bottle instance
	if bottle_instance.has_method("throw_bottle"):
		bottle_instance.throw_bottle(direction)

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
