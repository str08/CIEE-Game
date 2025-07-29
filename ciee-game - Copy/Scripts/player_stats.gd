	# GlobalData.gd
extends Node
	
var player_health = 3
var bullets = 1
var minerals = 0
var damage = 1
var wood = 0 
var last_island_visited = 0

func add_minerals(amount):
	minerals += amount

func change_health(amount):
	player_health += amount

func change_bullets(amount):
	bullets += amount

func change_damage(amount):
	damage += amount

func change_wood(amount):
	wood += amount

func change_last_island_visited(amount):
	last_island_visited = amount
	
