extends Area2D

@export var speed: float = 200.0
@export var brightness: float = 1.0
@export var possible_textures: Array[Texture2D]
@export var minerals: PackedScene
@export var health = 10
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var damage

@onready var sprite := $Sprite2D

func _ready():
	
	if possible_textures.size() > 0:
		sprite.texture = possible_textures[randi() % possible_textures.size()]
	sprite.modulate = Color(brightness, brightness, brightness)

func _process(delta):
	position.y += speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		health-=area.damage
		if(health<=0):
			_spawn_mineral()
			area.queue_free()
			queue_free()


func _spawn_mineral():
	if minerals:
		var mineral = minerals.instantiate()
		mineral.position = self.position
		mineral.speed = speed * 0.75  # Optional: slower than meteor
		var ui = get_tree().current_scene.get_node("UI")  # Adjust this to the actual path
		mineral.connect("increaseMinerals", Callable(ui, "_on_increaseMinerals"))

		get_tree().current_scene.add_child(mineral)
