extends Control


onready var inventoryContainer = $InventoryContainer
onready var button = $TextureButton

func _ready():
	inventoryContainer.visible = false

func _on_TextureButton_pressed():
	toggle_inventory()

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	inventoryContainer.visible = !inventoryContainer.visible
	button.release_focus()
