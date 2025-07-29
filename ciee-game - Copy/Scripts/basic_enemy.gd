extends Node2D
class_name BaseEnemy

@export var speed: float = 100.0
@export var health: int = 3

# Runtime links
@export_node_path("Node2D") var player_path: NodePath
@export_node_path("Node") var bullet_container_path: NodePath
@export var bullet_scene: PackedScene  # drag bullet.tscn in Inspector

var _player: Node2D
var _bullet_container: Node

func _ready():
	# player ref
	if player_path != NodePath():
		_player = get_node_or_null(player_path)
	else:
		_player = get_tree().get_root().get_node_or_null("Main/Player")

	# bullet container ref
	if bullet_container_path != NodePath():
		_bullet_container = get_node_or_null(bullet_container_path)
	else:
		_bullet_container = get_tree().get_root().get_node_or_null("Main/BulletContainer")

	add_to_group("enemies")

func _player_pos() -> Vector2:
	if _player:
		return _player.global_position
	return PlayConfig.playfield_rect.size * 0.5  # fallback center

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

# --- bullet helper ---
func _spawn_enemy_bullet(pos: Vector2, dir: Vector2, speed: float, color: Color = Color.RED):
	print("Bullet spawn at: ", pos)
	if bullet_scene == null or _bullet_container == null:
		return
	var b = bullet_scene.instantiate()
	_bullet_container.add_child(b)
	b.global_position = pos
	if b.has_method("init"):
		b.init(dir, speed)
	if b.has_variable("color"):
		b.color = color
		if b.has_method("refresh_visual"):
			b.refresh_visual()
