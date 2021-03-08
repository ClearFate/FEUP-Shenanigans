extends Node

export(int) var damage = 1
export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health #so it's consistent with onready retrievals

signal no_health
signal health_changed(value)
signal max_health_changed(value)


# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health

func is_dead():
	return health <= 0

func set_health(val):
	health = val
	emit_signal("health_changed", health)
	if is_dead():
		emit_signal("no_health")

func set_max_health(val):
	max_health = max(val, 1)
	health = min(max_health, health)
	emit_signal("max_health_changed", max_health)
