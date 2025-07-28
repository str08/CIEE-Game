extends Area2D

# Alive Vars
@export var speed = 20

var player_pos
var target_pos

@onready var player = get_parent().get_node_or_null("Ship")

# Bullet/Death Vars
const bullet_scene = preload	("res://Enemy/enemy_projectile.tscn")
@export var time_between_shots = 0.2 
@export var spawn_point_count = 100
@export var radius = 15

@onready var rotator = $Rotator
@onready var lifetime = $Lifetime

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	#player_pos = player.position
	#target_pos = (player_pos - position).normalized()
	
	#if position.distance_to(player_pos) > 3:
	#	position += target_pos * speed * delta

func _on_lifetime_timeout():
	_die()

func _die():
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var angle = i * (2 * PI / spawn_point_count)
		var pos = Vector2(radius * cos(angle), radius * sin(angle))
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotator.add_child(spawn_point)
	shoot()
	queue_free()

func shoot():
	for r in rotator.get_children():
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = r.global_position
		bullet.rotation = r.global_rotation
