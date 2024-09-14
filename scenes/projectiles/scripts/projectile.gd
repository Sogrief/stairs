class_name projectile
extends RigidBody2D

var custom_gravity : Vector2

#------------------- propriétés du projectile à changer lorsque sa taille change -------------------
@onready var sprite_2d = $sprite_2d
@onready var collision_shape_2d = $collision_shape_2d
@onready var area_collision_shape_2d = $area_2d/collision_shape_2d

@export var projectile_size_array : Array[projectile_size] # tableau contenant des ressources de type projectile_size
@export var size : SIZE:
	set(value):
		if value != size: # si la taille du projectile change le signal est envoyé
			size = value
			size_changed.emit()
		
signal player_collision #signal envoyé lors de la collision de ce projectile avec le joueur
signal size_changed # signal envoyé lorsque la size du projectile est mise à jour

#------------------- les différentes tailles de projectiles -------------------
enum SIZE {
	SMALL = 0,
	MEDIUM = 1,
	BIG = 2
}

func _ready() -> void:
	size_changed.connect(projectile_update_size) # à la naissance du projectile, le signal de taille est connecté
	custom_integrator = true  # Activer le custom integrator pour cet objet
	
#------------------- mise à jour des propriétés du projectile lors de la réception du signal -------------------
func projectile_update_size() -> void:
	sprite_2d.scale = projectile_size_array[size].sprite_scale # taille du sprite 2D
	collision_shape_2d.shape = projectile_size_array[size].collision_shape # taille du collision shape 2D
	area_collision_shape_2d.shape = projectile_size_array[size].area_collision_shape # taille du collision shape de l'area 2D

#------------------- envoi du signal de collision avec le joueur -------------------
func _on_area_2d_body_entered(body):
	if body is player:
		player_collision.emit()
		
		
#------------------- met à jour la gravité quand moitié du niveau dépassée -------------------	
func set_gravity(dir: Vector2) -> void:
	custom_gravity = dir * gravity_scale
	
func _integrate_forces(state) -> void:
	print(custom_gravity)
	
	var custom_grav = Vector2(0, 980 * gravity_scale)  # calcul manuel de la gravité
	state.linear_velocity += custom_grav * state.step  # modification de la vélocité linéaire de l'objet
