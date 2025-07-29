extends Area2D

@export var speed = 200
@export var time_between_shots = 0.2 
@export var spawn_point_count = 8
@export var radius = 15
@export var health = 1

var player
var target_pos
# Bullet/Death Vars
const bullet_scene = preload	("res://Scenes/enemy_projectile.tscn")
@onready var rotator = $Rotator
@onready var lifetime = $Lifetime

func _ready():
	player = get_tree().get_current_scene().get_node_or_null("Ship")

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var player_pos = player.position
	target_pos = (player_pos - position).normalized()

	if position.distance_to(player_pos) > 3:
		position += target_pos * speed * delta

	if health <= 0:
		_die()

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

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		var dmg = area.damage if "damage" in area else 1
		area.queue_free()
		health -= dmg
