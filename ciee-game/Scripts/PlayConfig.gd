extends  Node

# Playable area (Rect position, size)
var playfield_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func init_fullscreen(vp_size: Vector2):
	# full viewport as playfield
	playfield_rect = Rect2(Vector2.ZERO, vp_size)
