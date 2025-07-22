extends "res://Enemies/Scripts/basic_enemy.gd"

enum MovementType {
	HORIZONTAL_SWEEP,
	BOUNCE_VERTICAL,
	FIGURE_EIGHT,
	ZIGZAG_DIAGONAL,
	CIRCLE
}

@export var movement: MovementType = MovementType.HORIZONTAL_SWEEP
@export var amplitude: float = 100.0      # Horizontal/vertical distance
@export var vertical_limit: float = 200.0 # Max Y position to move down
@export var frequency: float = 2.0        # Speed factor for patterns

var time: float = 0.0
var going_down: bool = true  # For BOUNCE_VERTICAL
var direction: Vector2 = Vector2(1, 1) # For ZIGZAG_DIAGONAL
var angle: float = 0.0 # For circle
var pivot: Vector2 = Vector2.ZERO # Circle pivot

func _process(delta: float) -> void:
	time += delta
	match movement:
		MovementType.HORIZONTAL_SWEEP:
			_horizontal_sweep(delta)
		MovementType.BOUNCE_VERTICAL:
			_bounce_vertical(delta)
		MovementType.FIGURE_EIGHT:
			_figure_eight(delta)
		MovementType.ZIGZAG_DIAGONAL:
			_zigzag_diagonal(delta)
		MovementType.CIRCLE:
			_circle(delta)
	
func _ready():
	time = randf() * PI * 2 # Randomize start phase
	pivot = position # Use intial position as the center of the circle
	
	if use_random_movement:
		# Pick a random movment type from enum
		movement = MovementType.values()[randi() % MovementType.size()]
	
	# Random direction to move in at the beginning
	if randi() % 2 == 0:
		direction.x = 1
	else:
		direction.x = -1
	
	# Random multiplier for movement so bots don't act the same
	amplitude += randf_range(-20, 20)
	frequency += randf_range(-1, 1)

# Oscillates left/right while slowly moving down		
func _horizontal_sweep(delta: float) -> void:
	position.x += cos(time * frequency) * amplitude * delta
	position.y += speed * delta * 0.2 # Moves down slowly

# Moves up and down between y = 0 and y = vertical_limit
func _bounce_vertical(delta: float) -> void:
	if going_down:
		position.y += speed * delta
		if position.y >= vertical_limit:
			going_down = false
	else:
		position.y -= speed * delta
		if position.y <= 0:
			going_down = true
	# Optional left/right motion
	position.x += sin(time * frequency) * amplitude * delta
	
# Moves in a horizontal figure-eight
func _figure_eight(delta: float) -> void:
	position.x += cos(time * frequency) * amplitude * delta
	position.y += sin(time * frequency) * amplitude * 0.5 * delta

func _zigzag_diagonal(delta: float) -> void:
	# Move diagonally while bouncing off screen edges
	position += Vector2(speed * delta * direction.x, speed * delta * direction.y)
	
	# Reverse direction if hitting left/right edges
	if position.x < 0 or position.x > get_viewport_rect().size.x:
		direction.x *= -1
	# Reverse direction if hitting top/vertical limit
	if position.y < 0 or position.y > vertical_limit:
		direction.y *= -1
		
func _circle(delta: float) -> void:
	# Moves in a ricle around a pivot point
	angle += frequency * delta
	position.x = pivot.x + cos(angle) * amplitude
	position.y = pivot.y + sin(angle) * amplitude 
