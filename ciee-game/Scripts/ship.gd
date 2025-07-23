extends CharacterBody2D

var speed = 400  # speed in pixels/sec
@export var cooldown = 0.05
@export var bullet_scene : PackedScene
@onready var screensize = get_viewport_rect().size
@export var shape_scene: PackedScene  # Drag and drop your shape scene here.
@export var health = 3
var slow_indicator : Node2D = null  # New variable to track the circle
var can_shoot = true
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready():
	start()

func start():
	
	$GunCooldown.wait_time = cooldown
	
func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -10))
	
func _process(delta: float) -> void:
	var temp_speed = speed
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if Input.is_action_pressed("Slow"):
		temp_speed*=.5
		if slow_indicator == null:
			slow_indicator = shape_scene.instantiate()
			add_child(slow_indicator)
			slow_indicator.position = collision_shape_2d.position
	else:
		if slow_indicator != null:
			slow_indicator.queue_free()
			slow_indicator = null
	velocity = direction * temp_speed

	if Input.is_action_pressed("Shoot"):
		shoot()

	move_and_slide()
	#_clamp_to_playfield()
	
func _on_gun_cooldown_timeout():
	can_shoot = true

#func _clamp_to_playfield():
	#var r := playConfig.playfield_rect
	## If sprite is centered on the node, no half-size needed
	#global_position.x = clamp(global_position.x, r.position.x, r.position.x + r.size.x)
	#global_position.y = clamp(global_position.y, r.position.y, r.position.y + r.size.y)
