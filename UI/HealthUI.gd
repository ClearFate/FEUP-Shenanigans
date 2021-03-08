extends Control


var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIEmpty = $HeartUiEmpty
onready var heartUIFull = $HeartUIFull

const size_factor = 15


# Called when the node enters the scene tree for the first time.
func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	update_heart_display()

func set_max_hearts(value):
	max_hearts = max(value, 1)
	hearts = min(max_hearts, hearts)
	update_heart_display()
	update_max_heart_display()
	
func update_heart_display():
	if (heartUIFull != null):
		heartUIFull.rect_size.x = hearts * size_factor

func update_max_heart_display():
	if (heartUIEmpty != null):
		heartUIEmpty.rect_size.x = max_hearts * size_factor

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")

