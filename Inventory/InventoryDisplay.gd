extends GridContainer

var inventory = preload("res://Inventory/Inventory.tres")
const InventorySlotDisplay = preload("res://Inventory/InventorySlotDisplay.tscn")
var total_slots

func _ready():
	inventory.connect("items_changed", self, "_on_items_changed")
	inventory.make_items_unique()
	self.total_slots = inventory.get_curr_slot_size()
	if total_slots > get_child_count():
		update_inventory_slot_display_max()
#	print(inventory.items)
#	print(inventory.has_item("Orange"))
#	inventory.add_item("Orange")
#	print(inventory.get_item_index("Orange"))
	update_inventory_display()

func update_inventory_display():
	for item_index in inventory.items.size():
		update_inventory_slot_display(item_index)

func update_inventory_slot_display(item_index):
	var inventorySlotDisplay = get_child(item_index)
	var item = inventory.items[item_index]
	inventorySlotDisplay.display_item(item)

#adds display slots according to total inventory increase
func update_inventory_slot_display_max():
	var total_columns = self.columns #get displayed col num
	var inventory_slot_size = inventory.get_curr_slot_size() #actual inventory slot number
	var desired_lines = get_quotient_ceiling(inventory_slot_size, columns) #get desired lines
	var curr_slots_num = get_child_count() # display slot number
	var curr_slot_line = get_quotient_floor(curr_slots_num, columns) #current slot's line
	var initial_last_slot_line = curr_slot_line #last slot line before starting
	var curr_slot_col = curr_slots_num % total_columns #current_slot's column 
	for y in range(curr_slot_line,desired_lines):
		if curr_slot_line > initial_last_slot_line:
			self.rect_size.y += 60 #updates display height
		for x in range(curr_slot_col, total_columns):
			print (y*total_columns + x)
			var slotDisplay = InventorySlotDisplay.instance()
			add_child(slotDisplay)
			var pos = slotDisplay.rect_position
			pos.x += 106 * x
			pos.y += 60 * y
			slotDisplay.rect_position = pos
		curr_slot_col = 0
	inventory.expand_item_slots(desired_lines * total_columns) #update inventory empty slots if needed
	total_slots = inventory_slot_size

func get_quotient_ceiling(divisor, dividend):
	return ceil(float(divisor) / dividend)

func get_quotient_floor(divisor, dividend):
	return floor(float(divisor) / dividend)

func _on_items_changed(indexes):
	for item_index in indexes:
		update_inventory_slot_display(item_index)

func _unhandled_input(event):
	if event.is_action_released("ui_left_mouse"):
		if inventory.drag_data is Dictionary:
			if inventory.items[inventory.drag_data.item_index] == null:
				inventory.set_item(inventory.drag_data.item_index, inventory.drag_data.item)
