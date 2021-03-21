extends "res://KinematicEntity.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var ROLL_SPEED = 120

var roll_vector = Vector2.DOWN

var stats = PlayerStats


enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

onready var animationPlayer = $AnimationPlayer #onready so it doesn't need to be initialized in ready
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var swordHitbox = $HitboxPivot/SwordHitbox #TODO: REMOVE ALL "sketchy af"
onready var interactionBox = $InteractionPivot/InteractionBox

const DeathEffect = preload("res://Effects/PlayerDeathEffect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	stats.connect("no_health", self, "on_death")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector #sketchy af


func _input(event):		
	if event.is_action_pressed("interact") && can_interact() && state == MOVE:
		animationState.travel("Idle")
		interactionBox.enable_interaction()
	elif event.is_action_released("interact"):
		interactionBox.disable_interaction()

func _physics_process(delta): #use _physics_process if using player position or other player attributes
	if !can_move():
		return
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state(delta):
	
	var input_vector = get_movement_direction()
	
	if input_vector != Vector2.ZERO:
		update_animation_direction_vector(input_vector)
		
		roll_vector = input_vector #updates the roll direction while moving
		swordHitbox.knockback_vector = roll_vector #sketchy af
		
		animationState.travel("Run")
		accelerate(input_vector, delta)
	else:
		animationState.travel("Idle")
		decelerate(delta)
		
	move()
	
	if Input.is_action_just_pressed("melee_attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL
	
func attack_state():
	animationState.travel("MeleeAttack")
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_animation_finished():
	velocity = Vector2.ZERO #so it doesn't move forward after the attack
	state = MOVE
	
func roll_animation_finished():
	velocity *= 0.8 #0 for no sliding
	state = MOVE

func get_movement_direction():
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return input_vector.normalized()

func update_animation_direction_vector(input_vector):
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Run/blend_position", input_vector)
	animationTree.set("parameters/MeleeAttack/blend_position", input_vector)
	animationTree.set("parameters/Roll/blend_position", input_vector)

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage

func create_death_effect():
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = global_position
#   vs
#	get_parent().add_child(grassEffect)
#	grassEffect.position = self.position

func on_death():
	create_death_effect()
	queue_free()
	
func can_move():
	return EventHandler.can_world_move()
	
func can_interact():
	return can_move()
