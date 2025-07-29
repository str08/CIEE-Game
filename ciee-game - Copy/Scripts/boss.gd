extends Area2D
const bullet_scene = preload	("res://Scenes/enemy_projectile.tscn")

@export var fly_in_speed: float = 50       # Pixels per second
var is_flying_in = true

@export var time_between_shots = 0.3
@export var spawn_point_count = 4
@export var radius = 15
@export var rotate_speed = 100
@export var direction_change_interval = 0.95 # Time interval for changing rotation

var rotation_direction = 1 # 1 for clockwise, -1 for counterclockwise
var direction_change_timer = 0 # Timer to track elapsed time

@onready var shoot_timer = $ShootTimer
@onready var rotator = $Rotator

@export var health = 1200
@export var speed = 375
@export var bullet_speed = 375

var wave_time := 0.0
@export var wave_amplitude := 150.0
@export var wave_frequency := 0.5
@export var wave_speed := 200.0

var direction = 1

func _ready():
	_create_spawn_points(spawn_point_count)
	shoot_timer.wait_time = time_between_shots

func _physics_process(delta: float):
	if is_flying_in:
		position.y += fly_in_speed * delta
		if position.y >= get_viewport_rect().position.y-200:
			position.y = get_viewport_rect().position.y-200
			is_flying_in = false
			shoot_timer.start()

		return
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
		child.rotation = 0
	
	shoot_timer.wait_time = 0.125
	bullet_speed = 250

func _bullet_pattern_three(delta):
	print("PHASE 3")
	spawn_point_count = 9
	_create_spawn_points(spawn_point_count)
	
	_bullet_pattern_one(delta)
	
	shoot_timer.wait_time = 0.1
	bullet_speed = 600

func _movement_one(delta):
	var current_viewport = get_viewport_rect()
	position.x += speed * direction * delta
	
	if position.x > current_viewport.size.x -300:
		direction = -1
	elif position.x < -335:
		direction = 1

func _movement_two(delta):
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return  # Fallback safety

	wave_time += delta

	position.x += wave_speed * delta

	# Proper vertical base based on camera position
	var base_y = camera.global_position.y - get_viewport_rect().size.y / 2 + 100  # 100 px from top
	position.y = base_y + sin(wave_time * TAU * wave_frequency) * wave_amplitude

	# Flip wave direction if it reaches screen bounds
	var screen_left = camera.global_position.x - get_viewport_rect().size.x / 2
	var screen_right = camera.global_position.x + get_viewport_rect().size.x / 2

	if position.x > screen_right:
		wave_speed *= -1
		position.x = screen_right
	elif position.x < screen_left:
		wave_speed *= -1
		position.x = screen_left

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
	var win_screen = get_tree().current_scene.get_node("WinScreen")
	if win_screen:
		win_screen.visible = true
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player_bullets"):
		var dmg = area.damage if "damage" in area else 1
		area.queue_free()
		health -= dmg

		if health <= 0:
			_die()
