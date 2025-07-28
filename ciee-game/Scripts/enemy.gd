extends Area2D

const bullet_scene = preload	("res://Enemy/enemy_projectile.tscn")
@export var time_between_shots = 0.2 
@export var spawn_point_count = 5
@export var radius = 15
@export var rotate_speed = 100
@export var direction_change_interval = 1 # Time interval for changing rotation

var rotation_direction = 1 # 1 for clockwise, -1 for counterclockwise
var direction_change_timer = 0 # Timer to track elapsed time

@onready var shoot_timer = $ShootTimer
@onready var rotator = $Rotator

func _ready():
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var angle = i * (2 * PI / spawn_point_count / 4)
		var pos = Vector2(radius * cos(angle), radius * sin(angle))
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)
	
	shoot_timer.wait_time = time_between_shots
	shoot_timer.start()

func _physics_process(delta: float):
	direction_change_timer += delta
	if direction_change_timer >= direction_change_interval:
		direction_change_timer = 0
		rotation_direction *= -1
		
	var new_rotation = rotator.rotation_degrees + rotate_speed * rotation_direction * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)

func _on_shoot_timer_timeout():
	for r in rotator.get_children():
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = r.global_position
		bullet.rotation = r.global_rotation
