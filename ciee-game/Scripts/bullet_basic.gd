extends Area2D

@export var speed = -1000
@export var damage = 1

func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta

func _on_area_entered(_area: Area2D):
	queue_free()
