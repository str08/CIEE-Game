extends CharacterBody2D

@export var speed = 100
var facing = 3
var gatherCooldown = 0

func _process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * speed
	if Input.is_action_pressed("Left"):
		facing = 1
		$anim.play("walkLeft")
	elif Input.is_action_pressed("Right"):
		facing = 2
		$anim.play("walkRight")
	elif Input.is_action_pressed("Up"):
		facing = 3
		$anim.play("walkUp")
	elif Input.is_action_pressed("Down"):
		facing = 0
		$anim.play("walkDown")
		
	if velocity.x == 0 && velocity.y == 0:
		match facing:
			0:
				$anim.play("idleDown")
			1:
				$anim.play("idleLeft")
			2:
				$anim.play("idleRight")
			3:
				$anim.play("idleUp")
	
	if Input.is_action_just_pressed("Shoot"):
		match facing:
			0:
				$interactDown/coll.disabled = false
				print("down")
			1:
				$interactLeft/coll.disabled = false
				print("left")
			2:
				$interactRight/coll.disabled = false
				print("right")
			3:
				$interactUp/coll.disabled = false
				print("up")
		gatherCooldown = .1
	if gatherCooldown <= 0:
		$interactDown/coll.disabled = true
		$interactLeft/coll.disabled = true
		$interactRight/coll.disabled = true
		$interactUp/coll.disabled = true
	else:
		gatherCooldown -= delta
	move_and_slide()

func _on_zindex_lower_area_area_entered(area):
	z_index = 0

func _on_zindex_lower_area_area_exited(area):
	z_index = 1


func _on_wood_gather_area_area_entered(area):
	print("gathered")
