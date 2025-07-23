extends "res://Scripts/base_boss.gd"

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
	$WarningLine.visible = false
	cooldown_timer = dash_cooldown
	shoot_timer = shoot_interval

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
	
	dash_origin = position
	if dash_side:
		# Choose left or right edge
		var side = randi() % 2
		if side == 0:
			dash_origin = Vector2(-64, randf() * get_viewport_rect().size.y * 0.6)
			dash_target = Vector2(get_viewport_rect().size.x + 64, dash_origin.y)
		else:
			dash_origin = Vector2(get_viewport_rect().size.x + 64, randf() * get_viewport_rect().size.y * 0.6)
			dash_target = Vector2(-64, dash_origin.y)
		position = dash_origin
		$WarningLine.rotation = PI / 2 # Horizontal warning
		$WarningLine.position.y = dash_origin.y
		$WarningLine.position.x = get_viewport_rect().size.x / 2 - $WarningLine.size.x / 2
	else:
		dash_target = Vector2(position.x, get_viewport_rect().size.y + 64) # Vertical dash
		$WarningLine.rotation = 0
		$WarningLine.position.x = position.x
		$WarningLine.position.y = 0
		
	dash_timer = telegraph_time
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
	
# ---------------------
# SHOOTING PLACEHOLDER
# ---------------------
func shoot(bullet_count: int = 3):
	# Placeholder for bullets - replace with real bullet code later
	print("BossOne fires a %d-shot spread!" % bullet_count)

func _shoot_dash_burst():
	# Placeholder for dash bullet trail
	print("BossOne shoots a burst while dashing!")
