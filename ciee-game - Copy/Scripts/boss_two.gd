extends "res://Scripts/base_boss.gd"

#----------------
# Phase tuning
#----------------
@export var phase2_threshold: float = 0.66
@export var phase3_threshold: float = 0.33

# Phase 1 movement
@export var p1_hover_amplitude: float = 80.0
@export var p1_hover_speed: float = 300.0 # ms divisor in sin()

# Phase 2 orbit
@export var p2_orbit_radius_x: float = 160.0
@export var p2_orbit_radius_y: float = 60.0
@export var p2_orbit_rate: float = 1.0 # radians/sec

# Phase 3 teleport + blasts
@export var p3_burst_interval: float = 1.5
@export var p3_wall_interval: float = 2.5
@export var p3_teleport_cooldown: float = 0.5

# Bullet pattern knobs (hand off to bullet system later)
@export var ring_bullet_count_p1: int = 16
@export var ring_bullet_count_p2: int = 24
@export var ring_bullet_count_p3: int = 36
@export var rain_columns: int = 8
@export var wall_rows: int = 4

# Internal
var t: float = 0.0
var phase_clock: float = 0.0
var next_burst: float = 0.0
var next_wall: float = 0.0
var can_teleport: bool = true

# Cached teleport locations
var teleport_spots: Array[Node] = []

func _ready():
	super._ready()
	_cache_teleports()
	
func _cache_teleports():
	teleport_spots.clear()
	if has_node("TeleportPoints"):
		for child in $TeleportPoints.get_children():
			teleport_spots.append(child)
			
func _process(delta: float) -> void:
	_update_phase()
	t += delta
	phase_clock += delta
	
	match current_phase:
		Phase.PHASE_ONE:
			_phase_one(delta)
		Phase.PHASE_TWO:
			_phase_two(delta)
		Phase.PHASE_THREE:
			_phase_three(delta)
			
#-----------------
# Phase switching
#-----------------
func _update_phase():
	var hp = float(health) / float(max_health)
	if hp <= phase3_threshold:
		current_phase = Phase.PHASE_THREE
	elif hp <= phase2_threshold:
		current_phase = Phase.PHASE_TWO
	else:
		current_phase = Phase.PHASE_ONE
		
#----------------------------------
# Phase 1 -- Hover + radial rings
#----------------------------------
func _phase_one(delta: float):
	# Slow top hover
	var hover_x = sin(Time.get_ticks_msec() / p1_hover_speed) * p1_hover_amplitude
	position.x = clamp(position.x + hover_x * delta, 0, get_viewport_rect().size.x)
	
	# Fire ring every ~2 seconds
	if phase_clock >= 2.0:
		_fire_ring(ring_bullet_count_p1)
		phase_clock = 0.0
		
#----------------------------------
# Phase 2 -- Orbit + bullet rain
#----------------------------------
var p2_angle: float = 0.0

func _phase_two(delta: float):
	p2_angle += p2_orbit_rate * delta
	var cx = get_viewport_rect().size.x * 0.5
	var cy = get_viewport_rect().size.y * 0.25 # upper quarter
	position.x = cx + cos(p2_angle) * p2_orbit_radius_x
	position.y = cy + sin(p2_angle) * p2_orbit_radius_y
	
	# Rain every second 
	if phase_clock >= 1.0:
		_fire_rain(rain_columns)
		# also occasional ring burst
		if randi() % 3 == 0:
			_fire_ring(ring_bullet_count_p2)
		phase_clock = 0.0
		
#-----------------------------------------------
# Phase 3 -- Teleport, ring bullet, bullet wall
#-----------------------------------------------
var p3_current_spot: Node
var p3_time_since_tele: float = 0.0

func _phase_three(delta: float):
	p3_time_since_tele += delta
	next_burst -= delta
	next_wall -= delta
	
	# Teleport rhythm
	if can_teleport and p3_time_since_tele >= p3_teleport_cooldown:
		_teleport_to_random_spot()
		p3_time_since_tele = 0.0
	
	# Burst
	if next_burst <= 0.0:
		_fire_ring(ring_bullet_count_p3)
		next_burst = p3_burst_interval
	
	# Wall sweep
	if next_wall <= 0.0:
		_fire_wall(wall_rows)
		next_wall = p3_burst_interval
		
#------------------
# Teleport Helpers
#------------------
func _teleport_to_random_spot():
	if teleport_spots.is_empty():
		return
	var pick = teleport_spots[randi() % teleport_spots.size()]
	position = pick.global_position
	
#---------------------
# Bullet pattern stubs
#---------------------
func _fire_ring(count: int):
	# TODO: call bullet system to spwn radial bullets
	print("BossTwo rain x%d" % count)
	
func _fire_rain(columns: int):
	# TODO: spawn vertical falling bullets across screen width
	print("BossTwo rain x%d cols" % columns)

func _fire_wall(rows: int):
	# TODO: spawn a sweeping horizontal wall (maybe from boss downward)
	print("BossTwo wall x%d rows" % rows)
	
# MAYBE ADD A CIRCLE OF BULLETS THAT COME OUT OF TELEPORT POINT
# WHEN THEY TELEPORT
