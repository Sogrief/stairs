@tool
class_name projectile
extends RigidBody2D

@onready var sprite_2d = $sprite_2d
@onready var collision_shape_2d = $collision_shape_2d
@onready var area_collision_shape_2d = $area_2d/collision_shape_2d

@export var projectile_size_array : Array[projectile_size] # tableau contenant des ressources de type projectile_size
@export var size : SIZE:
	set(value):
		if value != size: # si la taille du projectile a changé
			size = value
			size_changed.emit()
		
signal player_collision
signal size_changed

enum SIZE {
	SMALL = 0,
	MEDIUM = 1,
	BIG = 2
}

func _ready() -> void:
	size_changed.connect(projectile_update_size)

#------------------- mise à jour des propriétés du projectile -------------------
func projectile_update_size() -> void:
	#sprite_2d.scale = projectile_size_array[size].sprite_scale
	collision_shape_2d.shape = projectile_size_array[size].collision_shape
	area_collision_shape_2d.shape = projectile_size_array[size].area_collision_shape

func _on_area_2d_body_entered(body):
	if body is player:
		player_collision.emit()
