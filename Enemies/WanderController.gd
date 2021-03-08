extends Node2D

export(int) var wander_radius = 32

onready var start_pos = global_position
onready var target_pos = global_position

onready var timer = $Timer




func update_target_position():
	var target_vector = Vector2(get_random_radius_val(),get_random_radius_val())
	target_pos = start_pos  + target_vector
	
func get_random_radius_val():
	return rand_range(-wander_radius,wander_radius)

func get_time_left():
	return timer.time_left
	
func start_timer(duration):
	timer.start(duration)

func _on_Timer_timeout():
	update_target_position()


