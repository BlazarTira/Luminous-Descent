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
	
func extract(item: InvItem) -> bool:
	var return_value: bool = false;
	for slot in slots:
		if slot.item == item:
			slot.amount -= 1;
			return_value = true;
		update.emit()
	return return_value;
