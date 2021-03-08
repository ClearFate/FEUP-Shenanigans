extends Area2D

export(bool) var show_hit = true

onready var start_layer = collision_layer + 0
onready var timer = $Invincibility


const HitEffect = preload("res://Effects/HitEffect.tscn") 

func create_hit_effect():
	var hitEffect = HitEffect.instance()
	get_parent().add_child(hitEffect)
	hitEffect.global_position = global_position
	
func set_invincibility():
	collision_layer = 0
	set_deferred("monitorable", false)

func remove_invincibility():
	collision_layer = start_layer
	set_deferred("monitorable", true)


func _on_Hurtbox_area_entered(_area):
	if show_hit:
		create_hit_effect()
	set_invincibility()
	timer.start(0.5)


func _on_Invincibility_timeout():
	timer.stop()
	remove_invincibility()
