extends Control


onready var inventoryContainer = $InventoryContainer
onready var button = $InventoryButton
onready var tooltip = $Tooltip
onready var tooltipLabel = $Tooltip/Label

func _ready():
	inventoryContainer.visible = false
	tooltip.visible = false

func _on_TextureButton_pressed():
	toggle_inventory()

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	inventoryContainer.visible = !inventoryContainer.visible
	button.release_focus()

func show_tooltip(text, position):
	tooltipLabel.text = text
	position.y -= 3.5
	position.x -= 29.5 #alignment 
	tooltip.set_global_position(position)
	tooltip.visible = true

func hide_tooltip():
	tooltipLabel.text = ""
	tooltip.visible = false
