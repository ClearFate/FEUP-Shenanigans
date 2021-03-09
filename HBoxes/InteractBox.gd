extends Area2D

onready var collisionShape = $CollisionShape2D

func _ready():
	disable_interaction()

func enable_interaction():
	collisionShape.set_deferred("disabled", false)
	
func disable_interaction():
	collisionShape.set_deferred("disabled", true)
