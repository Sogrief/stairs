extends Node2D

@export var projectile : PackedScene
var timer : float = 1.0

func _process(delta):
	print(timer)
	
	timer -= delta
	
	if timer < 0.0:
		timer = 1.0
		var projectile_instance = projectile.instantiate()
		add_child(projectile_instance)
	
	
