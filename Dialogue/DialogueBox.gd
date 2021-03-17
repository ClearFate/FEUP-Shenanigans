extends Control


onready var ReplyButton = preload("res://Dialogue/ReplyButton.tscn")

onready var textLabel = $RichTextLabel
onready var answerBox = $ScrollContainer/AnswerBox

# Called when the node enters the scene tree for the first time.
func _ready():
	EventHandler.connect("end_dialogue", self, "close_dialogue_box")
	EventHandler.connect("update_dialogue", self, "update_dialogue_box")
	visible = false

#func init_dialogue_box(conversation):
#	update_dialogue_box(conversation)
#	visible = true

func close_dialogue_box():
	visible = false

func update_dialogue_box(conversation):
	if !visible:
		visible = true
	textLabel.text = conversation["name"] + ": " + conversation["text"]
	init_answer_box(conversation)

func init_answer_box(conversation):
	remove_replies()
	if conversation.has("replies"):
		var replies = conversation["replies"]
		for key in replies:
			var curr_reply = replies[key]
			var curr_reply_text = curr_reply["text"]
			var replyButton = ReplyButton.instance()
			replyButton.init(key, curr_reply_text)
			replyButton.connect("chosen_reply", EventHandler, "handle_reply")
			answerBox.add_child(replyButton)

func remove_replies():
	for n in answerBox.get_children():
		answerBox.remove_child(n)
		n.queue_free()
