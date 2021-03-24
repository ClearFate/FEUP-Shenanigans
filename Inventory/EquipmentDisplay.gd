extends GridContainer

var inventory = preload("res://Inventory/Equipment.tres")
const InventorySlotDisplay = preload("res://Inventory/EquipmentSlotDisplay.tscn")
var total_slots

func _ready():
	inventory.connect("equipment_changed", self, "_on_items_changed")
	inventory.make_items_unique()
	self.total_slots = inventory.get_curr_slot_size()
#	print(inventory.items)
#	print(inventory.has_item("Orange"))
#	inventory.add_item("Orange")
#	print(inventory.get_item_index("Orange"))
#	inventory.remove_item(0)
	update_inventory_display()

func update_inventory_display():
	for item_index in inventory.items.size():
		update_inventory_slot_display(item_index)

func update_inventory_slot_display(item_index):
	var inventorySlotDisplay = get_child(item_index)
	var item = inventory.items[item_index]
	inventorySlotDisplay.display_item(item)


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
			inventory.set_item(inventory.drag_data.item_index, inventory.drag_data.item)
