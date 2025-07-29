extends BoxContainer

signal healthUp
signal attackUp
signal bulletUp22

var numBoughtLife = 0
var numBoughtAtk = 0
var numBoughtBul = 0

@onready var attack_up: Button = $AttackUp
@onready var life_up: Button = $LifeUp
@onready var more_bullets: Button = $MoreBullets

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Shop"):
		visible = !visible
		attack_up.disabled = !attack_up.disabled
		life_up.disabled = !life_up.disabled
		more_bullets.disabled = !more_bullets.disabled



func _on_life_up_pressed() -> void:
	if(PlayerStats.wood>=5):
		if numBoughtLife<3:
			PlayerStats.change_wood(-5)
			numBoughtLife+=1
			PlayerStats.change_health(1)
			$LifeUp.text="LIFE UP 5₩ "+ str(numBoughtLife) +"/3"

	pass # Replace with function body.

func _on_attack_up_pressed() -> void:
	if(PlayerStats.minerals>=5):
		if numBoughtAtk<3:
			PlayerStats.add_minerals(-5)
			numBoughtAtk+=1
			PlayerStats.change_damage(1)
			$AttackUp.text= "DMG UP ₼5 "+str(numBoughtAtk) +"/3"
	pass # Replace with function body.

func _on_more_bullets_pressed() -> void:
	if(PlayerStats.minerals>=5):
		if numBoughtBul<3:
			PlayerStats.add_minerals(-5)
			numBoughtBul+=1
			PlayerStats.change_bullets(1)
			$MoreBullets.text= "BULLET STREAMS UP ₼5 " + str(numBoughtBul)  + "/3"
	pass # Replace with function body.
