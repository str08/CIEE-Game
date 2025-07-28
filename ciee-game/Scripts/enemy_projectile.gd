extends Area2D

@export var speed = 3000

func _physics_process(delta: float):
	position += transform.x * speed * delta

func _on_lifetime_timer_timeout():
	queue_free()
