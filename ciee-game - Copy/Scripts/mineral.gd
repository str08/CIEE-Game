extends Area2D

@onready var sprite = $Sprite2D
@export var speed: float = 3.5
signal increaseMinerals

func _ready() -> void:
	print("STARTED MINERAL")
	sprite.frame = randi() % 20  # Randomize frame from 0 to 19

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
		
func _on_area_entered(area: Area2D) -> void:
	print("Touched by:", area)
	if area.is_in_group("player_pickup"):
		print("Picked up mineral!")
		PlayerStats.add_minerals(1)
		#emit_signal("increaseMinerals")
		queue_free()
