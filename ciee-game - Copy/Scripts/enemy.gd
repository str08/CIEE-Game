extends Area2D

const bullet_scene = preload	("res://Scenes/enemy_projectile.tscn")
@export var time_between_shots = 1.0
@export var spawn_point_count = 3
@export var radius = 15
@export var rotate_speed = 100
@export var direction_change_interval = 1 # Time interval for changing rotation

var rotation_direction = 1 # 1 for clockwise, -1 for counterclockwise
var direction_change_timer = 0 # Timer to track elapsed time

@export var health = 10

@onready var shoot_timer = $ShootTimer
@onready var rotator = $Rotator
@export var target_y_position: float =  get_viewport_rect().position.y -100  # Where it should stop flying down
@export var fly_in_speed: float = 150       # Pixels per second
var is_flying_in = true


func _ready():
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var angle = i * (2 * PI / spawn_point_count / 4)
		var pos = Vector2(radius * cos(angle), radius * sin(angle))
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)
	
	shoot_timer.wait_time = time_between_shots
	shoot_timer.stop()

func _physics_process(delta: float):
	print()
	if is_flying_in:
		position.y += fly_in_speed * delta
		if position.y >= target_y_position:
			position.y = target_y_position
			is_flying_in = false
			shoot_timer.start()  # Start shooting after arriving

		return  
	
	
	direction_change_timer += delta
	if direction_change_timer >= direction_change_interval:
		direction_change_timer = 0
		rotation_direction *= -1
		
	var new_rotation = rotator.rotation_degrees + rotate_speed * rotation_direction * delta
	rotator.rotation_degrees = fmod(new_rotation, 360)
	
	if health == 0:
		_die()

func _on_shoot_timer_timeout():
	for r in rotator.get_children():
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = r.global_position
		bullet.rotation = r.global_rotation

func _die():
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		var dmg = area.damage if "damage" in area else 1
		area.queue_free()
		health -= dmg

		if health <= 0:
			queue_free()
