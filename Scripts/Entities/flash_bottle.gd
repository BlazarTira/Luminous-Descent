extends CharacterBody2D

@export var throw_force: float = 150.0
@export var flash_damage: int = 1000

@onready var bottle_sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var flash_light = $BottleFlash
@onready var flash_area = $FlashArea2D

var is_flashing = false

func _ready():
	animation_player.play("bottle_spin")

func throw_bottle(direction: Vector2):
	velocity = direction.normalized() * throw_force

func _physics_process(_delta):
	if !is_flashing:
		move_and_slide()

func _on_hit_area_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("world"):
		flash()

func flash():
	is_flashing = true
	flash_area.monitoring = true
	animation_player.play("flash")
	bottle_sprite.hide()
	check_flash_damage()
	await get_tree().create_timer(1).timeout
	queue_free()
	is_flashing = false

func check_flash_damage():
	var bodies = flash_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"):
			body.take_damage(flash_damage)
