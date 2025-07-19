extends CharacterBody2D

var speed = 400  # speed in pixels/sec

@export var cooldown = 0.25
@export var bullet_scene : PackedScene
@onready var screensize = get_viewport_rect().size

var can_shoot = true

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
	b.start(position + Vector2(0, -120))
	
func _process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	if Input.is_action_pressed("Shoot"):
		shoot()

	move_and_slide()
	
func _on_gun_cooldown_timeout():
	can_shoot = true
