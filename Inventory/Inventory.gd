extends Resource

class_name Inventory

var drag_data = null

signal items_changed(indexes)

export(Array, Resource) var items = [
	null, null, null, null, null, null, null, null, null
]

func set_item(item_index, item):
	var previousItem = items[item_index]
	if previousItem is Item && previousItem.id == item.id:
		previousItem.amount += item.amount
	else:
		items[item_index] = item
	emit_signal("items_changed", [item_index])
	return previousItem
	
func swap_items(item_index, target_item_index):
	var targetItem = items[target_item_index]
	var item = items[item_index]
	items[target_item_index] = item
	items[item_index] = targetItem
	emit_signal("items_changed", [item_index, target_item_index])
	
func remove_item(item_index):
	var previousItem = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return previousItem
	
func make_items_unique():
	var unique_items = []
	for item in items:
		if item is Item: #to check if its not null
			unique_items.append(item.duplicate()) #bcz we want unique resource for every item and godot to save resource does shared resource by default
		else: #if its null
			unique_items.append(null)
	items = unique_items

func has_item(item_id):
	var ret = false
	for item in items:
		if item is Item && item.id == item_id:
			ret = true
			break
	return ret

func get_item_index(item_id):
	var index = -1
	for i in range(items.size()):
		var item = items[i]
		if item is Item && item.id == item_id:
			index = i
			break
	return index


func get_first_empty_slot_index():
	var index = -1
	for i in range(items.size()):
		var item = items[i]
		if !(item is Item):
			index = i
			break
	return index

#returns same item index if it exists. If it doesn't, returns the first empty slot's
#index if inv isn't full. Returns -1 otherwise (inv full, same item doesn't exist)
func get_first_replacement_index(item_id):
	var index = -1
	for i in range(items.size()):
		var item = items[i]
		if item is Item && item.id == item_id:
			index = i
			break
		if !(item is Item) && index == -1:
			index = i
	return index
	
func add_item(item_id):
	var new_item : Item
	new_item = load("res://Inventory/Items/" + item_id+ ".tres")
	new_item = new_item.duplicate() #items should be unique
	var item_slot_index = get_first_replacement_index(item_id) #get_first_empty_slot_index() use commented code for testing inventory size/scrolling in display
	if item_slot_index >= 0:
		set_item(item_slot_index, new_item)
	else:
		items.push_back(new_item)

func get_curr_slot_size():
	return items.size()

func expand_item_slots(new_num):
	if new_num > items.size():
		items.resize(new_num)
