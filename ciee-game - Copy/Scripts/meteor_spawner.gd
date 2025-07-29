extends Node2D

@export var meteor_background: PackedScene
@export var meteor_foreground: PackedScene

@export var spawn_interval = 0.3
@export var min_speed = 100.0
@export var max_speed = 500.0

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()
	$Timer.timeout.connect(_on_spawn_meteor)

func _on_spawn_meteor():
	var meteor
	var distance = randi() % 2
	if(distance==0):
		meteor = meteor_background.instantiate()

		meteor.position.x = randf_range(-370, 330)
		meteor.position.y = -270
	
		var speed = randf_range(min_speed, max_speed)
		meteor.speed = speed
		var brightness = lerp(0.1, .4, (speed - min_speed) / (max_speed - min_speed))
		meteor.brightness = brightness

	else:
		meteor= meteor_foreground.instantiate()
		meteor.position.x = randf_range(-370, 330)
		meteor.position.y = -270
		var speed = randf_range(min_speed, max_speed)
		meteor.speed = speed
		
		
	get_tree().current_scene.add_child(meteor)
