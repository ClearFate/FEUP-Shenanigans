extends Resource

class_name Equipment

var drag_data = null
var stats = PlayerStats

signal equipment_changed(indexes)

export(Array, Resource) var items = [
	null, null
]

func set_item(item_index, item):
	var previousItem = items[item_index]
	if previousItem is Item && previousItem.id == item.id:
		previousItem.amount += item.amount
	else:
		items[item_index] = item
	emit_signal("equipment_changed", [item_index])
#	print(item.id)
	return previousItem
	
func swap_items(item_index, target_item_index):
	var targetItem = items[target_item_index]
	var item = items[item_index]
	items[target_item_index] = item
	items[item_index] = targetItem
	emit_signal("equipment_changed", [item_index, target_item_index])
	
func remove_item(item_index):
	var previousItem = items[item_index]
	items[item_index] = null
	emit_signal("equipment_changed", [item_index])
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
	
#func use_item(index):
#	var item = items[index-1]
#	if item is Item:
#		var item_name = item.id
#		match item_name:
#			"Axe":
#				stats.set_damage(4)
#				remove_item(index-1)
#			"Dagger":
#				stats.set_damage(2)
#				remove_item(index-1)
#			"Sword":
#				stats.set_damage(3)
#				remove_item(index-1)
#			"BasicShield":
#				stats.set_max_health(stats.max_health+1)
#				remove_item(index-1)
#			"FortifiedShield":
#				stats.set_max_health(stats.max_health+2)
#				remove_item(index-1)
#			"SteelShield":
#				stats.set_max_health(stats.max_health+3)
#				remove_item(index-1)
#			"Grapes":
#				stats.heal_health(1)
#				remove_item(index-1)
#			"Kebab":
#				stats.heal_health(5)
#				remove_item(index-1)
#			"Orange":
#				stats.heal_health(2)
#				remove_item(index-1)
#			"MageArmor":
#				stats.set_max_health(stats.max_health+1)
#				remove_item(index-1)
#			"MysticArmor":
#				stats.set_max_health(stats.max_health+2)
#				remove_item(index-1)
#			"PlateArmor":
#				stats.set_max_health(stats.max_health+4)
#				remove_item(index-1)

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
		items.push_back(new_item) #just in case (shouldn't be used in current implementation)

func remove_item_amount(item_id, amount):
	var index = get_item_index(item_id)
	if index >= 0:
		var item = items[index]
		if item.amount - amount >= 1:
			item.amount -= amount
		else:
			items[index] = null
	emit_signal("equipment_changed", [index])
	return index >= 0

func get_curr_slot_size():
	return items.size()

func expand_item_slots(new_num):
	if new_num > items.size():
		items.resize(new_num)
