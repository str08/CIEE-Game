extends Area2D
@export var speed = -1000


func _ready() -> void:
	add_to_group("player_bullets")

func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta

func _on_area_entered(_area: Node):
	queue_free()
