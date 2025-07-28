extends RigidBody2D

func _on_wood_gather_small(area):
	PlayerStats.change_wood(1)
	print(PlayerStats.wood)
	modulate = Color8(85, 85, 85)
	
func _on_wood_gather_medium(area):
	PlayerStats.change_wood(3)
	print(PlayerStats.wood)
	modulate = Color8(85, 85, 85)
	
func _on_wood_gather_large(area):
	PlayerStats.change_wood(5)
	print(PlayerStats.wood)
	modulate = Color8(85, 85, 85)
