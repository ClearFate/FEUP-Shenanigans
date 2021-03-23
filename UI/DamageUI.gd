extends Control

var damageHit = 2

onready var label = $DamageAmount

func _ready():
	PlayerStats.connect("damage_changed", self, "set_damage")
	
func set_damage(val):
	label.text = str(val)
