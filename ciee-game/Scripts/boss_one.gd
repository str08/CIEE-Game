extends "res://Bosses/Scripts/base_boss.gd"

enum State {
	NORMAL,
	TELEGRAPHING,
	DASHING
}

@export var dash_speed: float = 600.0
@export var telegraph_time: float = 1.0
@export var dash_return_speed: float = 300.0
@export var dash_cooldown: float = 3.0
@export var shoot_interval: float = 1.0 # Boss fires every 1 second in Phase 1
@export var phase2_threshold: float = 0.7 # Switch to Phase 2 at 70% HP
@export var phase3_threshold: float = 0.3 # Switch to Phase 3 at 30% HP

# Added bullets
@export var bullet_scene: PackedScene = preload("res://Bullets/Scenes/bullet.tscn")
@export_node_path("Node") var bullet_container_path: NodePath
@export_node_path("Node2D") var player_path: NodePath # optional, fallback if empty
@export var bullet_speed_p1: float = 220.0
@export var bullet_speed_p2: float = 260.0
@export var bullet_speed_p3: float = 300.0

@export var dash_trail_bullet_speed: float = 200.0
@export var dash_trail_bullet_count: int = 6 # shoot small arc outward?
@export var dash_trail_prep_count: int = 2 # 2 directions: left/right of path
@export var dash_trail_spread_deg: float = 30.0

var _bullet_container: Node = null
var _player_ref: Node2D = null

var state: State = State.NORMAL
var dash_target: Vector2
var dash_origin: Vector2
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var shoot_timer: float = 0.0

# For phase 3 bullet trail
var dash_shoot_timer: float = 0.0
@export var dash_shoot_interval: float = 0.2

# For side dashes (phase 2+)
var dash_side: bool = false # false = top dash, true = side dash

func _ready():
	super._ready() # Call BaseBoss ready
	$WarningLine.top_level = true
	$WarningLine.visible = false
	cooldown_timer = dash_cooldown
	shoot_timer = shoot_interval
	
	if bullet_container_path != NodePath():
		_bullet_container = get_node(bullet_container_path)
	else:
		# fallback: try Main/BulletContainer if exists
		if get_tree().get_root().has_node("Main/BulletContainer"):
			_bullet_container = get_tree().get_root().get_node("Main/BulletContainer")
	if player_path != NodePath():
		_player_ref = get_node_or_null(player_path)
	
func _process(delta: float) -> void:
	_update_phase()
	match current_phase:
		Phase.PHASE_ONE:
			_phase_one(delta)
		Phase.PHASE_TWO:
			_phase_two(delta)
		Phase.PHASE_THREE:
			_phase_three(delta)
			
			
# --------------
# PHASE HANDLING
# --------------
func _update_phase():
	var health_percent = float(health) / float(max_health)
	if health_percent <= phase3_threshold:
		current_phase = Phase.PHASE_THREE
	elif health_percent <= phase2_threshold:
		current_phase = Phase.PHASE_TWO
	else:
		current_phase = Phase.PHASE_ONE
			
# --------------
# PHASE 1 LOGIC
# --------------
func _phase_one(delta: float) -> void:
	match state:
		State.NORMAL:
			_normal_behavior(delta, 3) #3-shot spread
		State.TELEGRAPHING:
			_telegraph_behavior(delta)
		State.DASHING:
			_dash_behavior(delta, false) # no bullet trail in phase 1
			
# --------------
# PHASE 2 LOGIC
# --------------
func _phase_two(delta: float) -> void:
	match state:
		State.NORMAL:
			_normal_behavior(delta, 5) # 5-shot spread
		State.TELEGRAPHING:
			_telegraph_behavior(delta, true) # side dashes enabled
		State.DASHING:
			_dash_behavior(delta, false)
			
# --------------
# PHASE 3 LOGIC
# --------------
func _phase_three(delta: float) -> void:
	match state:
		State.NORMAL:
			_normal_behavior(delta, 7) # 7-shot spread
		State.TELEGRAPHING:
			_telegraph_behavior(delta, true)
		State.DASHING:
			_dash_behavior(delta, true) # bullet trail on dash
			

# ------------------
# COMMON BEHAVIORS
# ------------------
func _normal_behavior(delta: float, bullet_count: int) -> void:
	#Move left-right along the top
	position.x += sin(Time.get_ticks_msec() / 300.0) * 80 * delta
	
	# Shooting logic
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot(bullet_count)
		shoot_timer = shoot_interval
	
	# Dash cooldown
	cooldown_timer -= delta
	if cooldown_timer <= 0:
		_start_telegraph()
		
func _start_telegraph(side_dash: bool = false):
	state = State.TELEGRAPHING
	dash_side = side_dash
	var vp := get_viewport_rect()
	dash_origin = global_position

	if dash_side:
		# Horizontal dash
		var y := randf() * vp.size.y * 0.6
		if randi() % 2 == 0:
			dash_origin = Vector2(-64, y)
			dash_target = Vector2(vp.size.x + 64, y)
		else:
			dash_origin = Vector2(vp.size.x + 64, y)
			dash_target = Vector2(-64, y)
		global_position = dash_origin

		_show_warning_line(
			Vector2(0, global_position.y),
			Vector2(get_viewport_rect().size.x, global_position.y)
		)
		
	else:
		# Vertical dash
		dash_target = Vector2(dash_origin.x, vp.size.y + 64)
		_show_warning_line(
			Vector2(global_position.x, 0),
			Vector2(global_position.x, get_viewport_rect().size.y)
		)



	dash_timer = telegraph_time
	
func _show_warning_line(start: Vector2, end: Vector2):
	$WarningLine.clear_points()
	$WarningLine.add_point(start)
	$WarningLine.add_point(end)
	$WarningLine.visible = true

	
func _telegraph_behavior(delta: float, side_dash: bool = false):
	dash_timer -= delta
	if dash_timer <= 0:
		state = State.DASHING
		$WarningLine.visible = false
		
func _dash_behavior(delta: float, shoot_during_dash: bool):
	# Move toward dash target
	position = position.move_toward(dash_target, dash_speed * delta)
	
	if shoot_during_dash:
		dash_shoot_timer -= delta
		if dash_shoot_timer <= 0:
			_shoot_dash_burst()
			dash_shoot_timer = dash_shoot_interval
	
	if position.distance_to(dash_target) < 10:
		# Return to top after dash
		position = position.move_toward(dash_origin, dash_return_speed * delta)
		if position.distance_to(dash_origin) < 10:
			position = dash_origin
			cooldown_timer = dash_cooldown
			state = State.NORMAL
	
func _get_player_global_position() -> Vector2:
	if _player_ref:
		return _player_ref.global_position
	# fallback: aim roughly downward center screen
	var vp := get_viewport_rect()
	return Vector2(vp.size.x * 0.5, vp.size.y) # bottom center
	
func _spawn_bullet(dir: Vector2, speed: float, color: Color = Color(1, 1, 1, 1), radius: float = 4.0):
	if bullet_scene == null:
		return
	if _bullet_container == null:
		return
		
	var b = bullet_scene.instantiate()
	b.global_position = global_position
	if b.has_method("init"):
		b.init(dir, speed)
	b.color = color
	b.refresh_visual()
	_bullet_container.add_child(b)
	
func _fire_spread(count: int, speed: float, spread_degrees: float):
	# spread_degrees = total angle width (e.g., 30 means +- 15)
	if count <= 0:
		return
	var target_pos := _get_player_global_position()
	var base_dir := (target_pos - global_position).normalized()
	var base_angle := base_dir.angle()
	
	if count == 1:
		_spawn_bullet(base_dir, speed)
		return
	
	var step := 0.0
	if count > 1:
		step = deg_to_rad(spread_degrees) / float(count - 1)
	
	var start_angle := base_angle - deg_to_rad(spread_degrees) * 0.5
	
	for i in count:
		var ang := start_angle + step * float(i)
		var dir := Vector2.RIGHT.rotated(ang) # RIGHT rotated gives unit dir
		_spawn_bullet(dir, speed)

func shoot(bullet_count: int = 3):
	var speed := bullet_speed_p1
	match current_phase:
		Phase.PHASE_TWO:
			speed = bullet_speed_p2
		Phase.PHASE_THREE:
			speed = bullet_speed_p3
			
	# Tune spread wdth per phase
	var spread_deg := 20.0
	if current_phase == Phase.PHASE_TWO:
		spread_deg = 35.0
	elif current_phase == Phase.PHASE_THREE:
		spread_deg = 50.0
		
	_fire_spread(bullet_count, speed, spread_deg)

func _shoot_dash_burst():
	# Estimate dash direction from current movement toward dash_target
	var dir := (dash_target - global_position).normalized()
	var perp_left := dir.rotated(-PI/2)
	var perp_right := dir.rotated(PI/2)
	
	# Option A: simple two bullets sideways
	_spawn_bullet(perp_left, dash_trail_bullet_speed, Color.YELLOW, 3)
	_spawn_bullet(perp_right, dash_trail_bullet_speed, Color.YELLOW, 3)
	
	# Option B: short fans sideways
	_fire_spread_from_vector(perp_left,  dash_trail_bullet_count/2, dash_trail_bullet_speed, dash_trail_spread_deg, Color.YELLOW)
	_fire_spread_from_vector(perp_right, dash_trail_bullet_count/2, dash_trail_bullet_speed, dash_trail_spread_deg, Color.YELLOW)
	
func _fire_spread_from_vector(base_dir: Vector2, count: int, speed: float, spread_degrees: float, color: Color = Color.YELLOW):
	if count <= 0:
		return
	var base_angle := base_dir.angle()
	if count == 1:
		_spawn_bullet(base_dir, speed, color, 3.0)
		return
	var step := deg_to_rad(spread_degrees) / float(count - 1)
	var start_angle := base_angle - deg_to_rad(spread_degrees) * 0.5
	for i in range(count):
		var ang := start_angle + step * float(i)
		var dir := Vector2.RIGHT.rotated(ang)
		_spawn_bullet(dir, speed, color, 3.0)

func _input(event):
	if event.is_action_pressed("hit_boss"): # Map action required
		take_damage(20) # Deal 10 damage (change as needed)
		
func take_damage(amount: int):
	health -= amount
	print("Boss hit! HP: ", health)
	if health <= 0:
		_on_boss_defeated()
	
