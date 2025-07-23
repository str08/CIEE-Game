extends BoxContainer

signal healthUp
signal attackUp
signal bulletUp

var numBoughtLife = 0
var numBoughtAtk = 0
var numBoughtBul = 0

@onready var attack_up: Button = $AttackUp
@onready var life_up: Button = $LifeUp
@onready var more_bullets: Button = $MoreBullets

func _on_life_up_pressed() -> void:
	if numBoughtLife<3:
		numBoughtLife+=1
		emit_signal("healthUp")
	$LifeUp.text="LIFE UP "+ str(numBoughtLife) +"/3"

	pass # Replace with function body.

func _on_attack_up_pressed() -> void:
	if numBoughtAtk<3:
		numBoughtAtk+=1
		emit_signal("attackUp")
	$AttackUp.text= "ATTACK UP "+str(numBoughtAtk) +"/3"

	pass # Replace with function body.

func _on_more_bullets_pressed() -> void:
	if numBoughtBul<3:
		numBoughtBul+=1
		emit_signal("bulletUp")
	$MoreBullets.text= "BULLETS UP " + str(numBoughtBul)  + "/3"

	pass # Replace with function body.
