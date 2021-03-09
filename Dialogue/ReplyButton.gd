extends Button

signal chosen_reply(id)

var id : String

func init(string_id, string_text):
	id = string_id
	text = string_text


func _on_Button_pressed():
	emit_signal("chosen_reply", id)
