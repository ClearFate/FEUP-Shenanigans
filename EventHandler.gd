extends Node

const flag_file_path = "./Dialogue/flags.cfg"
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
	choose_starting_conversation()
	update_dialogue()

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
		var curr_conversation = get_curr_conversation()
		trim_branching_replies(curr_conversation)
		emit_signal("update_dialogue", curr_conversation)
		
func end_dialogue():
	state = EXPLORATION
	emit_signal("end_dialogue")

func get_curr_conversation():
	return dialogue[curr_conversation_id];
	
func get_next_conversation_id():
	var curr_conv = get_curr_conversation()
	if curr_conv.has("next"):
		return curr_conv["next"]
	else:
		return "end"

#removes branching options that do not meet the specified criteria (flags)
func trim_branching_replies(conversation : Dictionary):
	if conversation.has("replies"):
		var replies = conversation["replies"]
		trim_branching_options(replies)
		
func trim_branching_options(options):
	for key in options:
			var option = options[key]
			if option.has("flag") && !check_flag(option["flag"]):
				options.erase(key)

func choose_starting_conversation():
	curr_conversation_id = "001"
	if !dialogue.has("start"):
		return
	
	var start = dialogue["start"]
	trim_branching_options(start)
	if !start.empty():
		var options = start.keys()
		curr_conversation_id = options[0]
	

#checks if the flag is true (in the flags.cfg file)
func check_flag(flag):
	var ret = false
	var config = ConfigFile.new()
	var err = config.load(flag_file_path)
	if err == OK && config.has_section_key("npcs", flag): # If not, something went wrong with the file loading
		ret = config.get_value("npcs", flag) #TODO: UPDATE SECTION VALUE
	return ret

func set_flag(flag):
	var config = ConfigFile.new()
	var err = config.load(flag_file_path)
	if err == OK: # If not, something went wrong with the file loading
		# Store a variable if and only if it hasn't been defined yet
		if config.has_section_key("npcs", flag):
			if config.get_value("npcs", flag) == false:
				config.set_value("npcs", flag, true)
		else:
			config.set_value("npcs", flag, true)
	# Save the changes by overwriting the previous file
	config.save(flag_file_path)

#parses json
func load_dialogue(file_path) -> Dictionary:
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	
# warning-ignore:shadowed_variable
	var dialogue = parse_json(file.get_as_text())
	assert(dialogue.size() > 0)
	return dialogue