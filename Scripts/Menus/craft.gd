class_name Craft extends Node

var current_craft: Array[InvItem] = [];
@export var craftable_items: Array[InvItem] = []
var selected_craft_index: int = 0:
	set(value):
		if value >= craftable_items.size():
			selected_craft_index = 0
		elif value < 0:
			selected_craft_index = craftable_items.size() - 1;
		else:
			selected_craft_index = value;
		on_item_changed.emit(craftable_items[selected_craft_index])
			
signal on_item_changed(item: InvItem);

func get_current_craft():
	return craftable_items[selected_craft_index]

func _ready():
	for item in craftable_items:
		if item.components.size() == 0:
			craftable_items.erase(item);
			print("Erasing %s since it does not have components" % item.name)

func add_item(item: InvItem, amount: int = 1):
	for i in amount:
		current_craft.append(item)
		
func _match_components(components: Array, item: InvItem):
	if item.components.size() != components.size(): 
		return false
	for entry in item.components:
		if !components.has(entry): 
			return false
	return true

func get_valid_recipes() -> Array[InvItem]:
	var items := []
	for item in craftable_items:
		if _match_components(current_craft, item):
			items.append(item)
	return items;

func finish_craft() -> InvItem:
	var valid_recipes = get_valid_recipes();
	if valid_recipes.size() != 0:
		return valid_recipes[0];
	else:
		return null;
