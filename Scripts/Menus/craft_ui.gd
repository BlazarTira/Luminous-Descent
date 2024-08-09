extends Control

@export var craft_controller: Craft;
@export var default_craft_index: int = 0;

@onready var craftable_result_visual: TextureRect = $NinePatchRect/MarginContainer/VBoxContainer/recipe_selector/item_display
@onready var prev_recipe: Button = $NinePatchRect/MarginContainer/VBoxContainer/recipe_selector/prev_recipe
@onready var next_recipe: Button = $NinePatchRect/MarginContainer/VBoxContainer/recipe_selector/next_recipe
@onready var craft_button: Button = $NinePatchRect/MarginContainer/VBoxContainer/Button

func _ready():
	craft_controller.selected_craft_index = default_craft_index;
	prev_recipe.pressed.connect(func(): craft_controller.selected_craft_index -= 1);
	next_recipe.pressed.connect(func(): craft_controller.selected_craft_index += 1);
	craft_button.pressed.connect(_craft_item)
	craft_controller.on_item_changed.connect(_on_item_changed)
	visible = false;

func _process(delta):
	if Input.is_action_just_pressed("ui_craft"):
		visible = !visible;
		_on_item_changed(craft_controller.get_current_craft())
		
func _on_item_changed(item: InvItem):
	craftable_result_visual.texture = item.texture;
	
func _craft_item():
	var curr_craft = craft_controller.get_current_craft();
	if Global.player.inv.contains(curr_craft.components):
		for item in curr_craft.components:
			Global.player.extract(item)
		Global.player.collect(curr_craft)
		print("Crafting item!")
	print("Item couldn't be crafted.")
