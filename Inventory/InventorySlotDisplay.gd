extends CenterContainer

signal show_tooltip(position, text)
signal hide_tooltip()

var inventory = preload("res://Inventory/Inventory.tres")
var equipment = preload("res://Inventory/Equipment.tres")

onready var itemTextureRect = $ItemTextureRect
onready var itemAmountLabel = $ItemTextureRect/ItemAmountLabel
onready var itemName = ""

func _ready():
	var inventoryUI = get_tree().current_scene.get_node("CanvasLayer/InventoryUI")
	self.connect("show_tooltip", inventoryUI, "show_tooltip")
	self.connect("hide_tooltip", inventoryUI, "hide_tooltip")

func display_item(item):
	if item is Item:
		itemTextureRect.texture = item.texture
		if(item.amount > 1):
			itemAmountLabel.text = str(item.amount)
		else:
			itemAmountLabel.text = ""
			itemName = item.name
	else:
		itemTextureRect.texture = load("res://Inventory/Items/EmptyInventorySlot.png")
		itemAmountLabel.text = ""
		itemName = ""

func get_drag_data(_position):
	var item_index = get_index() #index of a node position in a tree but in our case it coresponds with actual index in inventory
	var item = inventory.remove_item(item_index)
	if item is Item:
		var data = {}
		data.item = item
		data.item_index = item_index
		data.origin = "inv"
		var dragPreview = TextureRect.new()
		dragPreview.texture = item.texture
		set_drag_preview(dragPreview)
		inventory.drag_data = data
		return data

func can_drop_data(_position, data):
	return data is Dictionary and data.has("item")
	
func drop_data(_position, data):
	var my_item_index = get_index()
	var my_item = inventory.items[my_item_index]
	if data.origin == "equip":
#		equipment.remove_item(data.item_index)
		print("data-use: "+ str(data.use))
		var new_item_index = inventory.add_item(data.item.id)
		print("new item:" + str(new_item_index))
		print("data.item" + str(data.item))
		equipment.drag_data = null
	else:
		if my_item is Item and my_item.id == data.item.id:
			my_item.amount += data.item.amount
			inventory.emit_signal("items_changed", [my_item_index])
		else:
			inventory.swap_items(my_item_index, data.item_index)
			inventory.set_item(my_item_index, data.item)
	inventory.drag_data = null


func _on_ItemTextureRect_mouse_entered():
	if itemName != "":
		emit_signal("show_tooltip", itemName, self.rect_global_position)


func _on_ItemTextureRect_mouse_exited():
	emit_signal("hide_tooltip")
