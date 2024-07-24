extends Node2D

const Player = preload("res://Scenes/Entities/player.tscn")
const Enemy1 = preload("res://Scenes/Entities/enemy.tscn")
const GlowingMushroom = preload("res://Scenes/Materials/glowing_mushroom.tscn")
const CrystalShard = preload("res://Scenes/Materials/crystal_shard.tscn")
const EthericDust = preload("res://Scenes/Materials/etheric_dust.tscn")

var borders = Rect2(3, 3, 36, 19)
var player_spawn_position = Vector2(19, 11)
var min_enemy_distance = 5  # Minimum distance from player for enemy spawn

@onready var tileMap = $TileMapWalls

func _ready():
	randomize()
	generate_level()

func generate_level():
	var map_dict = {}  # Use a dictionary to ensure unique positions
	var num_walkers = 3
	var walker_steps = 250  # Reduced steps per walker to ensure coverage

	for i in range(num_walkers):
		var walker_start_position = Vector2(randi() % int(borders.size.x) + borders.position.x, randi() % int(borders.size.y) + borders.position.y)
		var walker = Walker.new(walker_start_position, borders)
		var steps = walker.walk(walker_steps)
		for step in steps:
			map_dict[step] = true  # Store step positions as dictionary keys
		walker.queue_free()
	
	var map = map_dict.keys()  # Convert dictionary keys back to array
	
	# Ensure the player spawn position is carved out
	var player_spawn = find_valid_spawn_position(player_spawn_position, map)
	var player = Player.instantiate()
	add_child(player)
	player.position = player_spawn * 32
	
	for location in map:
		tileMap.erase_cell(0, location)
	
	var used_tiles = tileMap.get_used_cells(0)
	for tile in used_tiles:
		tileMap.erase_cell(0, tile)
	tileMap.set_cells_terrain_connect(0, used_tiles, 0, 0)
	
	spawn_enemies(map, player.position)
	spawn_materials(map)

func find_valid_spawn_position(spawn_position, carved_positions):
	# If the spawn_position is carved out, return it
	if spawn_position in carved_positions:
		return spawn_position

	# Find the nearest carved position to the intended spawn position
	var nearest_position = null
	var nearest_distance = float("inf")

	for position in carved_positions:
		var distance = spawn_position.distance_to(position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_position = position
	
	# If no carved position is found, return a random carved position as a fallback
	if nearest_position == null and carved_positions.size() > 0:
		nearest_position = carved_positions[randi() % carved_positions.size()]
	
	return nearest_position

func spawn_enemies(carved_positions, player_position):
	var enemy_scenes = [Enemy1]
	var num_enemies = randi() % 10 + 5  # Randomly spawn between 5 and 15 enemies

	for i in range(num_enemies):
		var random_position = carved_positions[randi() % carved_positions.size()]
		# Check distance from player and if position is within borders
		while random_position.distance_to(player_spawn_position) < min_enemy_distance or !borders.has_point(random_position):
			random_position = carved_positions[randi() % carved_positions.size()]
		
		var random_enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
		var enemy = random_enemy_scene.instantiate()
		add_child(enemy)
		enemy.position = random_position * 32

func spawn_materials(carved_positions):
	var material_scenes = [GlowingMushroom, CrystalShard, EthericDust]
	var num_materials = randi() % 5 + 5  # Randomly spawn between 10 and 30 materials

	for i in range(num_materials):
		var random_position = carved_positions[randi() % carved_positions.size()]
		random_position = random_position * 32 + Vector2(16, 16)  # Adjust to center of tile
		var random_material_scene = material_scenes[randi() % material_scenes.size()]
		var material = random_material_scene.instantiate()
		add_child(material)
		material.position = random_position

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
