extends CharacterBody2D

var speed = 400  # speed in pixels/sec
@export var cooldown = 0.05
@export var bullet_scene : PackedScene
@onready var screensize = get_viewport_rect().size
@export var shape_scene: PackedScene  # Drag and drop your shape scene here.
var slow_indicator : Node2D = null  # New variable to track the circle
var can_shoot = true
var is_invincible =false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#@onready var shop_menu: BoxContainer = $"../ShopMenu"
#@onready var pickup_area: Area2D = $PickupArea
@onready var audio_stream_player = $AudioStreamPlayer
@onready var sprite_2d = $Sprite2D
var blink_timer := 0.0
var blink_interval := 0.1  # secondsasd
var original_modulate := Color(1, 1, 1, 1)

func _ready():
	$PickupArea.add_to_group("player_pickup")
	add_to_group("player")



	var upgrade  = 0.0
	
	start()

func start():
	
	$GunCooldown.wait_time = cooldown


func _start_blinking():
	original_modulate = modulate
	set_process(true)

func _stop_blinking():
	modulate = Color(1, 1, 1, 1)  # Fully opaque white
	set_process(false)
	

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var spacing = 20  # distance between bullet streams
	var num_bullets = max(1, PlayerStats.bullets)
	var total_width = (num_bullets - 1) * spacing
	var start_x = -total_width / 2  # center bullets around player
	
	for i in range(num_bullets):
		
		var bullet = bullet_scene.instantiate()
		bullet.damage = PlayerStats.damage
		get_tree().root.add_child(bullet)
		
		var x_offset = start_x + i * spacing
		var bullet_pos = position + Vector2(x_offset, -10)  # shoot from top of player
		audio_stream_player.play()

		bullet.start(bullet_pos)
	
func _process(delta):
	if is_invincible:
		blink_timer += delta
		if blink_timer >= blink_interval:
			blink_timer = 0
			modulate.a = 0.3 if modulate.a == 1.0 else 1.0
		
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
	var viewport_size = get_viewport_rect().size
	var half_size = viewport_size / 2.0
	var margin = 16  # padding so player doesn’t touch screen edge

	# Assuming camera is fixed at (0, 0)
	var min_x = -half_size.x + margin
	var max_x = half_size.x - margin
	var min_y = -half_size.y + margin
	var max_y = half_size.y - margin

	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)
	
func _on_gun_cooldown_timeout():
	can_shoot = true
	


func _on_attackUp():
	print("MORE DMG")
	PlayerStats.change_damage(1)

func _on_bulletUp():
	print("NEW STREAM")
	PlayerStats.change_bullets(1)



func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
	print("Entered area:", area.name)
	print(area.get_shape_owners())
	PlayerStats.change_health(-1)
	
	print("Health:",PlayerStats.player_health )
	is_invincible = true
	$InvincibilityFrames.start()
	$CollisionShape2D.disabled = true  # Optional: prevent further physics collision during i-frames
	if(PlayerStats.player_health<=0):
		get_tree().quit()
		# You can add logic to handle player death here if health <= 0
	


func _on_invincibility_frames_timeout():
	modulate = Color(1, 1, 1, 1)  # Fully opaque white
	is_invincible = false
	$CollisionShape2D.disabled = false  # Re-enable collisions
