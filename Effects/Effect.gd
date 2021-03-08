extends AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("animation_finished", self, "_on_animation_finished")
	frame = 0 # shouldn't be necessary unless someone messed with the editor and didnt reset frame
	play("Animate")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_animation_finished():
	queue_free()
