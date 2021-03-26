extends "res://HBoxes/InteractableBox.gd"

export(bool) var set_delayed_flags = false

func _ready():
	can_interact = false;




func _on_EventTriggerArea_body_entered(body):
	if set_delayed_flags:
		EventHandler.set_pending_flags()
	else:
		interact()
