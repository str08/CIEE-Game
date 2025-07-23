extends "res://Scripts/basic_enemy.gd"

enum RaiderPattern {
	DASH,
	ZIGZAG_FAST,
	CIRCLE_SWEEP
}

@export var pattern: RaiderPattern = RaiderPattern.DASH
@export var dash_speed: float = 500.0
@export var zigzag_amplitude: float = 120.0
@export var circle_radius: float = 100.0
@export var frequency: float = 2.0

var direction: int = 1
var angle: float = 0.0
var pivot: Vector2
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	match pattern:
		RaiderPattern.DASH:
			_dash(delta)
		RaiderPattern.ZIGZAG_FAST:
			_zigzag_fast(delta)
		RaiderPattern.CIRCLE_SWEEP:
			_circle_sweep(delta)

func _ready():
	pivot = position
	time = randf() * PI * 2
	#if use_random_movement:
	#	pattern = RaiderPattern.values()[randi() % RaiderPattern.size()]
	
func _dash(delta: float) -> void:
	position.x += dash_speed * direction * delta
	if position.x > get_viewport_rect().size.x + 32:
		direction = -1
		position.y += 50 # Moves slightly down on each pass
	elif position.x < -32:
		direction = 1
		position.y += 50

func _zigzag_fast(delta: float) -> void:
	position.y += speed * 1.5 * delta # Moves down fast
	position.x += sin(time * frequency * 3) * zigzag_amplitude * delta

func _circle_sweep(delta: float) -> void:
	angle += frequency * delta
	position.x = pivot.x + cos(angle) * circle_radius
	position.y = pivot.y + sin(angle) * circle_radius * 0.5
