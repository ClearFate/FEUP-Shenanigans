extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ACCELERATION = 500 #pixels/second^2
export var FRICTION = 500 #pixels/second^2
export var MAX_SPEED = 80 #pixels/second


var velocity = Vector2.ZERO 

#updates velocity according to the direction vector and entity acceleration
#direction_vector -> normalized direction vector
#delta -> time elapsed since last frame
func accelerate(direction_vector, delta):
	velocity = velocity.move_toward(direction_vector * MAX_SPEED, ACCELERATION * delta)

#reduces velocity according to entity friction
func decelerate(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
func move():
	velocity = move_and_slide(velocity)
