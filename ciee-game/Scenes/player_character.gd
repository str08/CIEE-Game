extends CharacterBody2D

@export var speed = 100
var facing = 3

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
	move_and_slide()
	
		
	
	
		
