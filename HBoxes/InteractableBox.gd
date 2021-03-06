extends Area2D

enum TYPE { DIALOGUE, ITEM, FLAG, FREE}
export(TYPE) var interaction_type = TYPE.DIALOGUE
export(String) var interaction_val = "branching_dialogue"
var can_interact = true

signal handle_interaction(type)

func interact():
	match interaction_type:
		TYPE.DIALOGUE:
			var dialogue_key = interaction_val
			EventHandler.handleDialogueEvent(dialogue_key)
		TYPE.FLAG:
			var flag_name = interaction_val
			EventHandler.set_flag(flag_name)
		TYPE.ITEM:
			var item_id = interaction_val
			EventHandler.handleItemEvent(item_id)
			emit_signal("handle_interaction", interaction_type)


func _on_InteractableBox_area_entered(area):
	if can_interact:
		interact()

