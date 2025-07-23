extends "res://Enemies/Scripts/basic_enemy.gd"

enum MovementType {
	HORIZONTAL_SWEEP,
	BOUNCE_VERTICAL,
	FIGURE_EIGHT,
	ZIGZAG_DIAGONAL,
	CIRCLE
}

@export var movement: MovementType = MovementType.HORIZONTAL_SWEEP
@export var amplitude: float = 100.0
@export var vertical_limit: float = 200.0
@export var frequency: float = 2.0

# --- shooting params ---
@export var fire_interval: float = 1.25
@export var bullet_speed: float = 220.0
@export var bullet_spread_deg: float = 20.0
@export var bullet_count: int = 3

# --- runtime ---
var time: float = 0.0
var fire_timer: float = 0.0
var going_down: bool = true
var direction: Vector2 = Vector2(1, 1)
var angle: float = 0.0
var pivot: Vector2 = Vector2.ZERO

# debugging toggle
@export var debug_shoot: bool = false

func _ready():
	super._ready()  # call basic_enemy.gd

	time = randf() * PI * 2
	pivot = position
	fire_timer = randf_range(0.1, fire_interval)  # slight desync

	# Random initial horizontal direction
	#direction.x = (randi() % 2 == 0) if 1 else -1

	if randi() % 2 == 0:
		direction.x = 1
	else:
		direction.x = -1

	# Slight variation
	amplitude += randf_range(-20, 20)
	frequency += randf_range(-1, 1)

	#_fire_spread() #TEMP DEBUG

func _process(delta: float) -> void:
	time += delta

	# movement pattern
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

	# shooting
	fire_timer -= delta
	if fire_timer <= 0.0:
		_fire_spread()
		fire_timer = fire_interval

# ----------------
# movement patterns
# ----------------
func _horizontal_sweep(delta: float) -> void:
	position.x += cos(time * frequency) * amplitude * delta
	position.y += speed * delta * 0.2

func _bounce_vertical(delta: float) -> void:
	if going_down:
		position.y += speed * delta
		if position.y >= vertical_limit:
			going_down = false
	else:
		position.y -= speed * delta
		if position.y <= 0:
			going_down = true
	position.x += sin(time * frequency) * amplitude * delta

func _figure_eight(delta: float) -> void:
	position.x += cos(time * frequency) * amplitude * delta
	position.y += sin(time * frequency) * amplitude * 0.5 * delta

func _zigzag_diagonal(delta: float) -> void:
	position += Vector2(speed * delta * direction.x, speed * delta * direction.y)
	if position.x < 0 or position.x > get_viewport_rect().size.x:
		direction.x *= -1
	if position.y < 0 or position.y > vertical_limit:
		direction.y *= -1

func _circle(delta: float) -> void:
	angle += frequency * delta
	position.x = pivot.x + cos(angle) * amplitude
	position.y = pivot.y + sin(angle) * amplitude

# ----------------
# shooting
# ----------------
func _fire_spread():
	var muzzle_pos = $Muzzle.global_position
	var player_pos = _player_pos()
	var base_dir = (player_pos - muzzle_pos).normalized()
	
	if debug_shoot:
		print("ShooterEnemy firing at:", player_pos, " from:", muzzle_pos)
	
	_spread_pattern(muzzle_pos, base_dir, bullet_count, bullet_spread_deg, bullet_speed)

func _spread_pattern(spawn_pos: Vector2, base_dir: Vector2, num: int, degrees: float, speed: float):
	if num <= 0:
		return
	var base_ang = base_dir.angle()
	if num == 1:
		_spawn_enemy_bullet(spawn_pos, base_dir, speed)
		return
	var step = deg_to_rad(degrees) / float(num - 1)
	var start = base_ang - deg_to_rad(degrees) * 0.5
	for i in range(num):
		var ang = start + step * i
		var dir = Vector2.RIGHT.rotated(ang)
		_spawn_enemy_bullet(spawn_pos, dir, speed)
