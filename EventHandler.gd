extends Node

onready var inventory = preload("res://Inventory/Inventory.tres")

const flag_file_path = "./Dialogue/flags.cfg"
const all_dialogues_path = "./Dialogue/all_dialogues.json"
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

var gave_item = false #true when a dialogue option resulted in a reward, false otherwise
#used to give the item received message before resuming the dialogue

var has_replies = false

#entities that can be hidden with interactions/dialogue
var hideable_entities = []

#flags waiting to be triggered in "safe zones" (away from their effect)
var pending_flags = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if state == DIALOGUE:
		if event.is_action_pressed("ui_accept") && !has_replies:
			next_dialogue()
	elif Input.is_action_pressed("exit_game"):
		end_game("leave")

func can_world_move():
	return state == EXPLORATION

func handleItemEvent(item_name):
	var item_message  = { "001": {"reward": item_name,"text": "..."}}
	dialogue = item_message
	begin_dialogue()

func handleDialogueEvent(dialogue_key):
	var dialogues = load_dialogue(all_dialogues_path)
	dialogue = get_dialogue_from_all(dialogues, dialogue_key)
	begin_dialogue()
	

func begin_dialogue():
	state = DIALOGUE
	choose_starting_conversation()
	update_dialogue()

func next_dialogue():
	if !gave_item:
		curr_conversation_id = get_next_conversation_id()
		handle_branch_node()
	update_dialogue()
	

func handle_reply(next_id):
	curr_conversation_id = next_id
	handle_branch_node()
	update_dialogue()

func update_dialogue():
	has_replies = false
	if curr_conversation_id == "end":
		end_dialogue()
	else:
		var curr_conversation = get_curr_conversation()
		if curr_conversation.has("reward") && gave_item:
			gave_item = false
			var item = curr_conversation["reward"]
			give_item(item)
			item_reward_message(item)
		else:
			if curr_conversation.has("visibility"):
				toggle_hiding_entity(curr_conversation["visibility"])
			if curr_conversation.has("reward"):
				gave_item = true #TODO: refactor this, mayhaps?
			if curr_conversation.has("remove_item"):
				take_item(curr_conversation["remove_item"])
			if curr_conversation.has("set_flag"):
				set_flag(curr_conversation["set_flag"])
			if curr_conversation.has("delayed_flag"):
				add_pending_flag(curr_conversation["delayed_flag"])
			if curr_conversation.has("heal"):
				PlayerStats.heal()
			if curr_conversation.has("finish"):
				end_game("end")
			trim_branching_replies(curr_conversation)
			if curr_conversation.has("replies"):
				has_replies = true
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
	for key in options.keys():
		var option = options[key]
		if option.has("flag") && !check_flag(option["flag"]):
			options.erase(key)
		if option.has("no_flag") && check_flag(option["no_flag"]):
			options.erase(key)
		if option.has("item") && !has_item(option["item"]):
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


func choose_branch_conversation(branch_conv):
	trim_branching_options(branch_conv)
	if !branch_conv.empty():
		var options = branch_conv.keys()
		curr_conversation_id = options[0]

func handle_branch_node():
	if "branch" in curr_conversation_id:
			var branch_conv = get_curr_conversation()
			choose_branch_conversation(branch_conv)
			
#flag methods

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

func reset_flags():
	var config = ConfigFile.new()
	var err = config.load(flag_file_path)
	if err == OK: # If not, something went wrong with the file loading
		var sections = config.get_sections()
		for section in sections:
			config.erase_section(section)
	# Save the changes by overwriting the previous file
	config.save(flag_file_path)

func add_pending_flag(flag):
	pending_flags.push_back(flag)

func set_pending_flags():
	while pending_flags.size() > 0:
		var flag = pending_flags.pop_front()
		set_flag(flag)

#item methods

func has_item(item_id):#TODO: TEST
	return inventory.has_item(item_id)

func give_item(item_id): #TODO: TEST
	return inventory.add_item(item_id)

func take_item(item_id):
	return inventory.remove_item_amount(item_id, 1)

func item_reward_message(item_name):
	var item_message  = {"text":"You received a " + item_name}
	emit_signal("update_dialogue", item_message)

func end_game(end_type):
	reset_flags()
	if end_type == "end":
		get_tree().change_scene("res://UI/EndMenu.tscn")
	else:
		get_tree().change_scene("res://UI/GameMenu.tscn")

#dialogue file loading

#parses json
func load_dialogue(file_path) -> Dictionary:
	var file = File.new()
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	
# warning-ignore:shadowed_variable
	var dialogue = parse_json(file.get_as_text())
	assert(dialogue.size() > 0)
	return dialogue

func get_dialogue_from_all(dialogues, dialogue_key):
	var ret_dialogue = null
	if dialogues.has(dialogue_key):
		ret_dialogue = dialogues[dialogue_key]
	return ret_dialogue

func add_hideable(entity):
	hideable_entities.push_back(entity)

func get_id_entity(entity_id):
	var ret = null
	for entity in hideable_entities:
		if entity.id == entity_id:
			ret = entity
			break
	return ret

func toggle_hiding_entity(entity_id):
	var entity = get_id_entity(entity_id)
	if entity != null:
		entity.toggle_hiding()
