extends AudioStreamPlayer


export (bool) var loop = true


func _on_AudioStreamPlayer_finished():
	if loop:
		play();
