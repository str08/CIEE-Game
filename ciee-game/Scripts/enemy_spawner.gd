# EnemySpawner.gd
extends Node2D

@export var enemy_a_scene: PackedScene
@export var enemy_b_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var randomness: float = 0.3  # between 0.0 and 1.0
@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	# Choose a random enemy type
	var enemy_scene = enemy_a_scene if randf() < 0.5 else enemy_b_scene
	var enemy = enemy_scene.instantiate()

	# Random horizontal spawn position within viewport
	var viewport_width = get_viewport_rect().size.x
	
	var spawn_x = randf_range(-350, 320)
	enemy.position = Vector2(spawn_x, -270)  # spawn above the screen

	get_tree().current_scene.add_child(enemy)

	# Optional: vary the timer
	var variance = spawn_interval * randomness
	spawn_timer.wait_time = spawn_interval + randf_range(-variance, variance)
	spawn_timer.start()
