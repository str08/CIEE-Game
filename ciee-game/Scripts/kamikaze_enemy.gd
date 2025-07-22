extends "res://Enemies/Scripts/basic_enemy.gd"

enum KamikazeType {
	STRAIGHT,
	SPIRAL,
	ZIGZAG
}

@export var kamikaze_type: KamikazeType = KamikazeType.STRAIGHT
@export var acceleration: float = 50.0
@export var max_speed: float = 300.0
@export var zigzag_amplitude: float = 60.0
@export var spiral_rotation_speed: float = 4.0
@export var target_position: Vector2 = Vector2(320, 240) # Placeholder (screen center)
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
	if use_random_movement:
		kamikaze_type = KamikazeType.values()[randi() % KamikazeType.size()]

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
