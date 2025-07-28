extends AudioStreamPlayer2D

var time = 136

func _ready():
	play(0)

func _process(delta):
	time -= delta
	if time <= 0:
		play(0)
		print("play")
		time = 136
