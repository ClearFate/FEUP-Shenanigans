extends "res://HBoxes/Hitbox.gd"


var knockback_vector = Vector2.ZERO
var stats = PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	stats.connect("damage_changed", self, "update_damage")

func update_damage(val):
	damage = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
