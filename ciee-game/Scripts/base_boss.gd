extends Node2D

enum Phase {
	PHASE_ONE,
	PHASE_TWO,
	PHASE_THREE
}

@export var max_health: int = 300

var health: int
var current_phase: Phase = Phase.PHASE_ONE

func _process(delta: float) -> void:
	match current_phase:
		Phase.PHASE_ONE:
			_pattern_one(delta)
		Phase.PHASE_TWO:
			_pattern_two(delta)
		Phase.PHASE_THREE:
			_pattern_three(delta)
			
func _ready():
	health = max_health
	$PhaseTimer.timeout.connect(_on_phase_timer_timeout)
	$PhaseTimer.start()
			
func _pattern_one(delta: float) -> void:
	# Place holder
	position.x += sin(Time.get_ticks_msec() / 200.0) * 60 * delta

func _pattern_two(delta: float) -> void:
	# Place holder
	position.x += cos(Time.get_ticks_msec() / 400.0) * 40 * delta
	position.y += sin(Time.get_ticks_msec() / 400.0) * 40 * delta
	
func _pattern_three(delta: float) -> void:
	# Place holder
	position.x += sin(Time.get_ticks_msec() / 100.0) * 100 * delta	
	
func take_damage(amount: int) -> void:
	health -= amount
	if health < 0:
		health = 0
	_update_health_bar()
	
	if health <= 0:
		_on_boss_defeated()
		
func _update_health_bar():
	if has_node("UI/HealthBar"):
		var bar = $UI/HealthBar
		var health_percent = float(health) / float(max_health) * 100
		bar.value = health_percent
		
		# Change color
		if health_percent > 70:
			bar.modulate = Color(0, 1, 0) # Green
		elif health_percent > 30:
			bar.modulate = Color(1, 1, 0) # Yellow
		else:
			bar.modulate = Color(1, 0, 0) # Red
	
func _on_phase_timer_timeout() -> void:
	# Switch Phases
	match current_phase:
		Phase.PHASE_ONE:
			current_phase = Phase.PHASE_TWO
		Phase.PHASE_TWO:
			current_phase = Phase.PHASE_THREE
		Phase.PHASE_THREE:
			$PhaseTimer.stop()

func _on_boss_defeated() -> void:
	queue_free()
