extends StaticBody2D

enum TYPE { DIALOGUE, ITEM, FLAG, FREE}
export(TYPE) var interaction_type setget update_type
export(String) var interaction_val setget update_interaction_val
export(Texture) var asset setget my_func
export(bool) var hideable = false
export(String) var id = ""

onready var interactionArea = $InteractableBox

func _ready():
	if hideable:
		EventHandler.add_hideable(self)
		

func my_func(tex):
	asset = tex
	get_node("Sprite").texture = asset

func update_type(type):
	interaction_type = type
	get_node("InteractableBox").interaction_type = self.interaction_type

func update_interaction_val(val):
	interaction_val = val
	get_node("InteractableBox").interaction_val = self.interaction_val

func toggle_hiding():
	visible = !visible
	interactionArea.can_interact = !interactionArea.can_interact
	$CollisionShape2D.call_deferred("set", "disabled",!$CollisionShape2D.disabled )
