extends "res://Scripts/basic_enemy.gd"

enum KamikazeType {
	STRAIGHT,
	SPIRAL,
	ZIGZAG
}
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ship: CharacterBody2D = get_parent().get_node_or_null("Ship")
#@onready var ship: CharacterBody2D = $Ship
@export var kamikaze_type: KamikazeType = KamikazeType.STRAIGHT
@export var acceleration: float = 50.0
@export var max_speed: float = 300.0
@export var zigzag_amplitude: float = 60.0
@export var spiral_rotation_speed: float = 4.0
#@export var target_position: Vector2 = Vector2(320, 240) # Placeholder (screen center)
@export var target_position: Vector2  # Placeholder (screen center)

# t_p = $"/root/Main/Player".position

var velocity: Vector2 = Vector2.ZERO
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	match kamikaze_type:
		KamikazeType.STRAIGHT:
			_straight_dive(delta)
		KamikazeType.SPIRAL:
			_spiral_dive(delta)
		KamikazeType.ZIGZAG:
			_zigzag_dive(delta)

func _ready():
	add_to_group("enemy")
	if ship:
		target_position = ship.position
	else:
		print("Could not find player!")	#if use_random_movement:
	#	kamikaze_type = KamikazeType.values()[randi() % KamikazeType.size()]
	animated_sprite_2d.play("flying")

func _straight_dive(delta: float) -> void:
	var direction = (target_position - position).normalized()
	velocity += direction * acceleration * delta
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	position += velocity * delta

func _spiral_dive(delta: float) -> void:
	var direction = (target_position - position).normalized()
	velocity += direction * acceleration * delta
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	# Add rotational component for a spiral effect
	velocity = velocity.rotated(sin(time * spiral_rotation_speed) * 0.01)
	position += velocity * delta
	
func _zigzag_dive(delta: float) -> void:
	var base_direction = (target_position - position).normalized()
	velocity += base_direction * acceleration * delta
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	# Apply horizontal oscillation for zigzag motion
	position += velocity * delta
	position.x += sin(time * 8) * zigzag_amplitude * delta
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		var dmg = area.damage if "damage" in area else 1
		area.queue_free()
		health -= dmg

		if health <= 0:
			animated_sprite_2d.play("explosion")
			queue_free()
