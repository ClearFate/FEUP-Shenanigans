extends Node

signal start_dialogue(dialogue)
signal update_dialogue(dialogue)
signal end_dialogue()

enum {
	EXPLORATION,
	DIALOGUE,	
	INVENTORY,
	PAUSED
}

var state = EXPLORATION

var dialogue : Dictionary
var curr_conversation_id

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if state == DIALOGUE:
		if event.is_action_pressed("ui_accept"):
			next_dialogue()

func can_world_move():
	return state == EXPLORATION


func handleDialogueEvent(dialogue_file_path):
	dialogue = load_dialogue(dialogue_file_path)
	begin_dialogue()

func begin_dialogue():
	state = DIALOGUE
	curr_conversation_id = "001"
	emit_signal("start_dialogue", get_curr_conversation())

func next_dialogue():
	curr_conversation_id = get_next_conversation_id()
	update_dialogue()
	

func handle_reply(next_id):
	curr_conversation_id = next_id
	update_dialogue()

func update_dialogue():
	if curr_conversation_id == "end":
		end_dialogue()
	else:
		emit_signal("update_dialogue", get_curr_conversation())
		
func end_dialogue():
	state = EXPLORATION
	emit_signal("end_dialogue")

func get_curr_conversation():
	return dialogue[curr_conversation_id];
	
func get_next_conversation_id():
	var curr_conv = get_curr_conversation()
	return curr_conv["next"]

#parses json
func load_dialogue(file_path) -> Dictionary:
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	
# warning-ignore:shadowed_variable
	var dialogue = parse_json(file.get_as_text())
	assert(dialogue.size() > 0)
	return dialogue
