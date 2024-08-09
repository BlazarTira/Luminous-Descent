extends Resource
class_name Inv

signal update

@export var slots: Array[InvSlot]
var crafting: Craft = Craft.new();

func insert(item: InvItem):
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()
	
func has_item(item: InvItem):
	return slots.any(func(x: InvSlot): return x.item == item);
	
func get_slot(item: InvItem) -> InvSlot:
	var slot = slots.filter(func(x: InvSlot): return x.item == item);
	if slot.size() == 0:
		return InvSlot.new(); #by default the amount is 0 so we can just return that
	else:
		return slot[0] #else return the first slot that has this data
		
func contains(items: Array[InvItem]) -> bool:
	var can_craft: bool = true;
	for item in items:
		var slot = get_slot(item);
		if items.count(item) > slot.amount:
			can_craft = false;
	return can_craft
	
func extract(item: InvItem) -> bool:
	var return_value: bool = false;
	for slot in slots:
		if slot.item == item:
			slot.amount -= 1;
			return_value = true;
		update.emit()
	return return_value;
