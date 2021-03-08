extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var push_vector = Vector2.ZERO
	if is_colliding():
		var areas = get_overlapping_areas()
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)
	return push_vector
	
	
