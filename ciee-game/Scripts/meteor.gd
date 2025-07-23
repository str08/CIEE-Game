extends Node2D

@export var speed: float = 200.0
@export var brightness: float = 1.0
@export var possible_textures: Array[Texture2D]

@onready var sprite := $Sprite2D

func _ready():
	if possible_textures.size() > 0:
		sprite.texture = possible_textures[randi() % possible_textures.size()]
	sprite.modulate = Color(brightness, brightness, brightness)

func _process(delta):
	position.y += speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
