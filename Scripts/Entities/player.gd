extends CharacterBody2D
class_name Player

@export var speed: int = 200
@export var player_health = 1000000
@export var player_max_health = 1000000
@export var throw_force: float = 500

const bottle_scene = preload("res://Scenes/Entities/flash_bottle.tscn")

@onready var animated_sprite = $AnimatedSprite2D
@onready var inventory = $ui/Inventory
@onready var health_bar = $ui/HealthBar

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
var attacking = false

func _ready():
	health_bar.value = player_max_health
	animated_sprite.modulate = Global.selected_color
	Global.player = self


func _process(_delta: float):
	update_animation()
	if Input.is_action_just_pressed("throw_bottle") and !attacking:
		throw_bottle()
	
	if Input.is_action_just_pressed("ui_craft"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()

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
	attacking = true
	var bottle_instance = bottle_scene.instantiate()
	get_parent().add_child(bottle_instance)
	bottle_instance.global_position = global_position

	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	# Call throw_bottle method on the bottle instance
	if bottle_instance.has_method("throw_bottle"):
		bottle_instance.throw_bottle(direction)
		await get_tree().create_timer(0.7).timeout
		attacking = false

func take_damage(amount):
	print("ouch")
	player_health -= amount
	health_bar.value = player_health
	if player_health <= 0:
		die()

func die():
	get_tree().paused = true
