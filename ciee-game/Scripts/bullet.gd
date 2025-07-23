extends Area2D

@export var speed: float = 250.0
@export var lifetime: float = 5.0
@export var radius: float = 4.0
@export var color: Color = Color.WHITE # white default

var velocity: Vector2 = Vector2.ZERO # normalized or not; normalize in init() convenience

func init(dir: Vector2, p_speed: float = -1.0) -> void:
	# dir can be any length; normalize
	velocity = dir.normalized()
	if p_speed > 0.0:
		speed = p_speed
		
func _ready():
	# Optional: shrink lifetime a bit for safety
	set_process(true)

func _process(delta: float) -> void:
	# Move
	global_position += velocity * speed * delta
	
	# Lifetime
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	
	# Off-screen cleanup
	var vp := get_viewport_rect()
	if global_position.x < -32 or global_position.x > vp.size.x + 32 \
	or global_position.y < -32 or global_position.y > vp.size.y + 32:
		queue_free()
		
func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	
func _notification(what):
	if what == NOTIFICATION_DRAW:
		# redraw if needed
		pass
		
# Call when changing color or radius at runtime 
func refresh_visual():
	queue_redraw()
	
