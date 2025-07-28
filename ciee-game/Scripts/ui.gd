extends BoxContainer

signal increaseMinerals
@onready var mineral_count: Label = $MineralCount
@onready var lives: Label = $Lives
@onready var mineral: Area2D = $"../Mineral"
@onready var mineralCount=0
@onready var livesCount=3

 

func _ready():
	print("READY")
	mineral_count.text= "Minerals: " +str(mineralCount)
	lives.text= "Lives: "+str(livesCount)
	

func _process(delta: float) -> void:
	mineral_count.text= "Minerals: " +str(PlayerStats.minerals)
	lives.text= "Lives: "+str(PlayerStats.player_health)


#func _on_increaseLives():
	#livesCount+=1
	#lives.text= "Lives: " +str(livesCount)
	#print("WE GOT LIFE")
	#print(livesCount)
#
#func _on_decreaseLives():
	#livesCount+=1
	#lives.text= "Lives: " +str(livesCount)
	#print("WE LOST LIFE")
	#print(livesCount)
