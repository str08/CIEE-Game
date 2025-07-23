extends CharacterBody2D

var speed = 400  # speed in pixels/sec
@export var cooldown = 0.05
@export var bullet_scene : PackedScene
@onready var screensize = get_viewport_rect().size
@export var shape_scene: PackedScene  # Drag and drop your shape scene here.
@export var health = 3
@export var damage = 1
@export var bullets = 1
var slow_indicator : Node2D = null  # New variable to track the circle
var can_shoot = true
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shop_menu: BoxContainer = $"../ShopMenu"

func _ready():
	$"../ShopMenu".connect("healthUp", _on_healthUp)
	$"../ShopMenu".connect("attackUp", _on_attackUp)
	$"../ShopMenu".connect("bulletUp", _on_bulletUp)

	var upgrade  = 0.0
	
	start()

func start():
	
	$GunCooldown.wait_time = cooldown
	
func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var spacing = 20  # distance between bullet streams
	var num_bullets = max(1, bullets)
	var total_width = (num_bullets - 1) * spacing
	var start_x = -total_width / 2  # center bullets around player

	for i in range(num_bullets):
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		var x_offset = start_x + i * spacing
		var bullet_pos = position + Vector2(x_offset, -10)  # shoot from top of player

		bullet.start(bullet_pos)
	
func _process(_delta):
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
	
func _on_gun_cooldown_timeout():
	can_shoot = true
	
func _on_healthUp():
	print("MORE HEALTH")
	health+=1

func _on_attackUp():
	print("MORE DMG")

	damage+=1

func _on_bulletUp():
	print("NEW STREAM")
	bullets+=1
