extends Area2D

const bullet_scene = preload	("res://Enemy/enemy_projectile.tscn")
@export var time_between_shots = 0.3
@export var spawn_point_count = 5
@export var radius = 15
@export var rotate_speed = 100
@export var direction_change_interval = 0.95 # Time interval for changing rotation

var rotation_direction = 1 # 1 for clockwise, -1 for counterclockwise
var direction_change_timer = 0 # Timer to track elapsed time

@onready var shoot_timer = $ShootTimer
@onready var rotator = $Rotator

@export var health = 1200
@export var speed = 500
@export var bullet_speed = 500

var wave_time := 0.0
@export var wave_amplitude := 150.0
@export var wave_frequency := 0.5
@export var wave_speed := 200.0

var direction = 1

func _ready():
	_create_spawn_points(spawn_point_count)
	shoot_timer.wait_time = time_between_shots
	shoot_timer.start()

func _physics_process(delta: float):
	_update_phase(delta)

func _create_spawn_points(num: int):
	for child in rotator.get_children():
		child.queue_free()

	for i in range(num):
		var spawn_point = Node2D.new()
		var angle = i * (2 * PI / num / 4)
		var pos = Vector2(radius * cos(angle), radius * sin(angle))
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)

func _on_shoot_timer_timeout():
	for r in rotator.get_children():
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = r.global_position
		bullet.rotation = r.global_rotation
		bullet.speed = bullet_speed

func _bullet_pattern_one(delta):
	direction_change_timer += delta
	if direction_change_timer >= direction_change_interval:
		direction_change_timer = 0
		rotation_direction *= -1
		
	var new_rotation = rotator.rotation_degrees + rotate_speed * rotation_direction * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)

func _bullet_pattern_two(delta):
	spawn_point_count = 1
	_create_spawn_points(spawn_point_count)
	
	var spacing = 0
	for i in range(rotator.get_child_count()):
		var child = rotator.get_child(i)
		child.position = Vector2((i - (spawn_point_count - 1) / 2.0) * spacing, 0)
		child.rotation = PI / 2
	
	shoot_timer.wait_time = 0.125
	bullet_speed = 250

func _bullet_pattern_three(delta):
	spawn_point_count = 9
	_create_spawn_points(spawn_point_count)
	
	_bullet_pattern_one(delta)
	
	shoot_timer.wait_time = 0.1
	bullet_speed = 600

func _movement_one(delta):
	var current_viewport = get_viewport_rect()
	position.x += speed * direction * delta
	
	if position.x > current_viewport.size.x + 32:
		direction = -1
	elif position.x < -32:
		direction = 1

func _movement_two(delta):
	var current_viewport = get_viewport_rect()
	
	wave_time += delta

	position.x += wave_speed * delta

	var base_y = current_viewport.size.y / 3
	position.y = base_y + sin(wave_time * TAU * wave_frequency) * wave_amplitude

	if position.x > current_viewport.size.x or position.x < 0:
		wave_speed *= -1
		position.x = clamp(position.x, 0, current_viewport.size.x)

func _movement_three(delta):
	
	_movement_two(delta)

# Boss Phases ----------------------------------------
# Basic attack pattern
func _phase_one(delta):
	_bullet_pattern_one(delta)
	_movement_one(delta)
	
# More advanced attack pattern with zig zag
func _phase_two(delta):
	_bullet_pattern_two(delta)
	_movement_two(delta)
	
func _phase_three(delta):
	_bullet_pattern_three(delta)
	_movement_three(delta)

func _update_phase(delta):
	if health <= 0:
		_die()
	elif health <= 900:
		_phase_two(delta)
	elif health <= 400:
		_phase_three(delta)
	else:
		_phase_one(delta)
		
func _die():
	queue_free()
