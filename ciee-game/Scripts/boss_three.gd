extends "res://Scripts/base_boss.gd"

# Phase thresholds
@export var phase2_threshold: float = 0.66
@export var phase3_threshold: float = 0.33

# Teleport timing (Phase 1)
@export var p1_tele_interval: float = 2.0

# Clone behavior (Phase 2)
@export var p2_clone_count: int = 2
@export var p2_zig_amplitude: float = 60.0
@export var p2_zig_rate: float = 4.0
@export var p2_tele_interval: float = 1.5

# Chaos storm (Phase 3)
@export var p3_rapid_tele_interval: float = 0.8
@export var p3_real_burst_chance: float = 0.6
@export var p3_clone_count: int = 4

# Internal
var tele_spots: Array[Node] = []
var tele_clock: float = 0.0
var t: float = 0.0

func _ready():
	super._ready()
	_cache_spots()

func _cache_spots():
	tele_spots.clear()
	if has_node("TeleportPoints"):
		for c in $TeleportPoints.get_children():
			tele_spots.append(c)

func _process(delta: float) -> void:
	_update_phase()
	t += delta
	tele_clock += delta

	match current_phase:
		Phase.PHASE_ONE:
			_phase_one(delta)
		Phase.PHASE_TWO:
			_phase_two(delta)
		Phase.PHASE_THREE:
			_phase_three(delta)

# -----------------------
# Phase switching
# -----------------------
func _update_phase():
	var hp = float(health) / float(max_health)
	if hp <= phase3_threshold:
		current_phase = Phase.PHASE_THREE
	elif hp <= phase2_threshold:
		current_phase = Phase.PHASE_TWO
	else:
		current_phase = Phase.PHASE_ONE

# -----------------------
# Phase 1: Simple teleport + spiral burst
# -----------------------
func _phase_one(delta: float):
	if tele_clock >= p1_tele_interval:
		_teleport_random()
		_fire_spiral(12) # low density
		tele_clock = 0.0

# -----------------------
# Phase 2: Zigzag + clones firing decoys
# -----------------------
func _phase_two(delta: float):
	# Zigzag drift (still visible)
	position.x += sin(t * p2_zig_rate) * p2_zig_amplitude * delta

	if tele_clock >= p2_tele_interval:
		var decoy: bool = true
		_spawn_clones(p2_clone_count, decoy)
		_fire_spiral(18) # stronger
		tele_clock = 0.0

# -----------------------
# Phase 3: Rapid tele-storm + real vs decoy blasts
# -----------------------
func _phase_three(delta: float):
	if tele_clock >= p3_rapid_tele_interval:
		_teleport_random()
		# Decide if real or decoy burst
		if randf() <= p3_real_burst_chance:
			_fire_ring(24)  # real dangerous burst
		else:
			var decoy: bool = true
			var fade_out: bool = true
			_spawn_clones(p3_clone_count, decoy)
			_fire_spiral(12, fade_out)  # decoy that disappears
		tele_clock = 0.0

# -----------------------
# Teleport helpers
# -----------------------
func _teleport_random():
	if tele_spots.is_empty():
		return
	var pick = tele_spots[randi() % tele_spots.size()]
	_fade_to(pick.global_position)

# Simple snap version (no fade) if you prefer:
# position = pick.global_position

func _fade_to(target: Vector2):
	# If you want to animate fade out/in, do it here.
	# For now just snap:
	position = target

# -----------------------
# Clone spawner
# -----------------------
func _spawn_clones(count: int, decoy: bool = false):
	if not has_node("CloneContainer"):
		return
	var cc = $CloneContainer

	# Clear old clones
	for c in cc.get_children():
		c.queue_free()

	for i in count:
		var clone = _make_clone(decoy)
		# Random offset near boss
		var offset = Vector2(randf_range(-60, 60), randf_range(-40, 40))
		clone.position = position + offset
		cc.add_child(clone)

		if decoy:
			_clone_fire_decoy(clone)

func _make_clone(decoy: bool) -> Node2D:
	var n = Node2D.new()
	var rect = ColorRect.new()
	rect.color = decoy if Color(1, 1, 1, 0.3) else Color(1, 0, 0, 0.8)
	rect.size = Vector2(32, 32)
	n.add_child(rect)
	return n

# -----------------------
# Bullet pattern stubs
# -----------------------
func _fire_spiral(count: int, fade_out: bool = false):
	print("Boss3 spiral x%d (fade:%s)" % [count, str(fade_out)])

func _fire_ring(count: int):
	print("Boss3 ring x%d" % count)

func _clone_fire_decoy(clone: Node):
	print("Boss3 clone decoy fire at %s" % str(clone.position))
