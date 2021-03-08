extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Hurtbox_area_entered(_area):
	destroy_grass()

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position
#   vs
#	get_parent().add_child(grassEffect)
#	grassEffect.position = self.position

func destroy_grass():
	create_grass_effect()
	queue_free() #waits for the frame to end before freeing, unlike the imediate free()
