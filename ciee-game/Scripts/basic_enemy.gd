extends Node2D

# Shared properties for all enemies
@export var speed: float = 100.0
@export var health: int = 3
@export var use_random_movement: bool = false
var is_dead: bool = false

func _process(delta: float) -> void:
	# This will be overridden by subclasses
	pass

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0 and not is_dead:
		die()
		
func die() -> void:
	is_dead = true
	queue_free()
