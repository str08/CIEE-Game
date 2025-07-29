extends Node2D

var time = .5
var canLeave = false
func _ready():
	$anim.play("fade_in")

	
func _process(delta):
	if canLeave:
		time-=delta
		if time<0:
			get_tree().change_scene_to_file("res://Scenes/game_boss.tscn")


func _on_next_area_transition_area_entered(area):
	$anim.play("fade_out")
	canLeave =true
	
	pass # Replace with function body.
