extends BoxContainer

signal increaseMinerals
@onready var mineral_count: Label = $MineralCount
@onready var mineralCount=0
@onready var livesCount=3
var hearts_list : Array[TextureRect]

 

func _ready():
	var hearts_parent = $HealthBar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print("READY")
	mineral_count.text= "Minerals: " +str(mineralCount)
	

func _process(delta: float) -> void:
	for i in range(hearts_list.size()):
		hearts_list[i].visible=i<PlayerStats.player_health
	mineral_count.text= "Minerals: " +str(PlayerStats.minerals)
	
