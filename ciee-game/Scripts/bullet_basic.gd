extends Area2D
@export var lifetime = 1.5
@export var speed = -1000
@export var damage: int


func _ready() -> void:
	add_to_group("player_bullets")

func start(pos):
	position = pos

func _process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	position.y += speed * delta
	var vp := get_viewport_rect()
	#if global_position.x < -500 or global_position.x>vp.size.x+32 \
	  #or global_position.y < -32 or global_position.y>vp.size.y+32:
		#queue_free()


func _on_area_entered(_area: Area2D):
	queue_free()
