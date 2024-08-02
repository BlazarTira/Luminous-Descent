extends Area2D

@export var item: InvItem
var player = null
var player_in_area = false

@onready var interactsprite = $InteractAnim
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("inWorld")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		drop_shroom()
		sprite.play("Picked")
		await get_tree().create_timer(0.6).timeout
		queue_free()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_area = true
		interactsprite.visible = true
		print("in pickable area")

func _on_pickable_area_body_exited(body):
	if body.is_in_group("player"):
		player = body
		player_in_area = false
		interactsprite.visible = false
		print("left pickable area")

func drop_shroom():
	print("shard collected")
	player.collect(item)
