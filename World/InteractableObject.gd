extends StaticBody2D

enum TYPE { DIALOGUE, ITEM, FLAG, FREE}
export(TYPE) var interaction_type setget update_type
export(String) var interaction_val setget update_interaction_val
export(Texture) var asset setget my_func

func my_func(tex):
	asset = tex
	get_node("Sprite").texture = asset

func update_type(type):
	interaction_type = type
	get_node("InteractableBox").interaction_type = self.interaction_type

func update_interaction_val(val):
	interaction_val = val
	get_node("InteractableBox").interaction_val = self.interaction_val
