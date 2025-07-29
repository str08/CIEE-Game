extends Node2D

var time = 60

func _process(delta):
	time -= delta
	if time <= 0:
		$anim.play("fade_out")
	if time < -0.5:
		get_tree().change_scene_to_file("res://Scenes/FloatingIsland1.tscn")
