extends "res://KinematicEntity.gd"

const EnemyDeathEffects = preload("res://Effects/EnemyDeathEffect.tscn")

var KNOCKBACK_SPEED = 150
var knockback = Vector2.ZERO

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController


# Called when the node enters the scene tree for the first time.
func _ready():
	print(stats.max_health)
	print(stats.health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			decelerate(delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				idle_wander_decision()
		WANDER:
			
			seek_player()
			var direction_vector = get_direction(wanderController.target_pos)
			accelerate(direction_vector, delta)
			
			
			if wanderController.get_time_left() == 0 || global_position.distance_to(wanderController.target_pos) <= MAX_SPEED * delta:
				idle_wander_decision()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction_vector = get_player_direction(player)
				accelerate(direction_vector, delta)
			else:
				state = IDLE
				
	sprite_face_mov_direction()
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_SPEED

func _on_Stats_no_health():
	create_death_effect()
	queue_free()
	
func create_death_effect():
	var enemyDeathEffect = EnemyDeathEffects.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func idle_wander_decision():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_timer(rand_range(1, 3))

func get_player_direction(player):
	return get_direction(player.global_position)
	
func get_direction(position):
	return global_position.direction_to(position)
	
func sprite_face_mov_direction():
	sprite.flip_h = velocity.x < 0
