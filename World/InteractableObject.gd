extends StaticBody2D

export(String) var dialogue_file_name = "branching_dialogue.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractionBox_area_entered(_area):
	interact()

func interact():
	EventHandler.handleDialogueEvent("./Dialogue/" + dialogue_file_name)
