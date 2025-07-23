extends BoxContainer

signal increaseMinerals
@onready var mineral_count: Label = $MineralCount
@onready var lives: Label = $Lives
@onready var mineral: Area2D = $"../Mineral"
@onready var mineralCount=0
@onready var livesCount=3

 

func _ready():
	print("READY")
	$"../Mineral".connect("increaseMinerals", _on_increaseMinerals)
	mineral_count.text= "Minerals: " +str(mineralCount)
	lives.text= "Lives: "+str(livesCount)
	
	

func _on_increaseMinerals():
	mineralCount+=1
	mineral_count.text= "Minerals: " +str(mineralCount)
	print("WE GOT MONEY")
	print(mineralCount)
	
func _on_increaseLives():
	livesCount+=1
	lives.text= "Lives: " +str(livesCount)
	print("WE GOT LIFE")
	print(livesCount)
	
