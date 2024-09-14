extends Node2D

@export var projectile_scene : PackedScene
@onready var projectile_launcher : Sprite2D = %projectile_launcher # canon / spawner de projectiles
@onready var path : Path2D = %path_2d # parcours 2D de la map
@onready var path_follow : PathFollow2D = %path_follow_2d
@onready var player_reference : CharacterBody2D = %player # joueur
@onready var player_position : Vector2 = player_reference.global_position # la position en temps réel du joueur

var progress_add : float = 0.03 # progression ajoutée en plus de celle du joueur au spawner de projectiles
var path_points : Array # l'ensemble des points du path2D
var closest_point : Vector2 # point du path le plus proche du joueur
var timer : float = (randf() * 2.6) + 0.4 # le délai entre chaque projectile_scene compris entre 0.4 et 3.0

signal half_level_reached

func _ready():
	path_points = get_all_points_from_path() # récupération de tous les points du path2D
	closest_point = get_closest_path_point(path_points, player_position) # récupération du point le plus proche du joueur
	path_follow.progress_ratio = path_follow_progress() + progress_add  # mise à jour de la progression du path follow par rapport à la position du joueur dans le niveau
	self.global_position = projectile_launcher.global_position # initialisation de la position du spawn de projectile_scene avec celle du canon

func _process(delta):
	if path_follow_progress() >= 0.5: # si le joueur dépasse la moitié du niveau
		half_level_reached.emit()
	
	#------------------- position du spawner de projectiles -------------------
	player_position = player_reference.global_position # récupération de la position du joueur
	path_follow.progress_ratio = path_follow_progress() + progress_add  # mise à jour de la progression du path follow par rapport à la position du joueur dans le niveau
	
	if closest_point != get_closest_path_point(path_points, player_position): # si le point le plus proche a changé
		self.global_position = projectile_launcher.global_position # mise à jour de la position du spawn des projectiles
		closest_point = get_closest_path_point(path_points, player_position) # mise à jour du point le plus proche

	#------------------- spawn des projectiles -------------------
	var random_variation = randf_range(-0.5, 0.5) # variation aléatoire en radiant de la rotation
	var launcher_radiant_rotation = projectile_launcher.global_rotation + random_variation # rotation en gradiant du lanceur
	var launcher_direction = Vector2(cos(launcher_radiant_rotation), sin(launcher_radiant_rotation)) # direction normalisée du lanceur
	
	var impulse_force = 1000
	
	timer -= delta
	
	if timer < 0.0:
		timer = (randf() * 2.6) + 0.4
		
		# ajout d'un nouveau projectile_scene
		var projectile_instance = projectile_scene.instantiate() # création d'une instance du projectile_scene
		get_tree().current_scene.add_child(projectile_instance) # ajout du projectile_scene à la scène
		projectile_instance.global_position = self.global_position # spécifie la position du projectile_scene égale à celle du spawner
		projectile_instance.size = randi_range(0, projectile.SIZE.size() - 1) # randomisation de la taille des projectiles a leur apparition
		
		projectile_instance.apply_impulse(launcher_direction * -impulse_force) # ajout d'une impulsion au projectile
		
		var custom_gravity = Vector2(ProjectSettings.get_setting("physics/2d/default_gravity") , 0)
		
		half_level_reached.connect(projectile_instance.set_gravity.bind(custom_gravity))
#------------------- fonction qui récupère les coordonnées des points du Path 2D -------------------
func get_all_points_from_path() -> Array: 
	var points = []
	
	# vérifie si le Path2D a une courbe
	if path.curve:
		var curve = path.curve # récupération de la courbe
		var point_count = curve.get_point_count() # nombre de points de la courbe
		
		# récupération de chaque point
		for i in range(point_count):
			var point_position = curve.get_point_position(i) # récupération de la position des différents points de la courbe
			points.append(point_position) # ajout de la position des points au tableau
			
	return points
	
#------------------- fonction qui retourne les coordonnées du point le plus proche -------------------
func get_closest_path_point(points : Array, player_pos : Vector2) -> Vector2:
	var distances_from_player : Array = []
	
	for i in range(points.size()):
		var distance = points[i].distance_to(player_pos) # distance entre le joueur et chaque point du path
		distances_from_player.append(distance) # ajout de chaque distance dans un tableau
		
	return points[distances_from_player.find(distances_from_player.min())] # retourne les coordonnées du point le plus proche du joueur
	
#------------------- fonction qui retourne la progression du joueur -------------------
func path_follow_progress() -> float:
	var player_distance = path.curve.get_closest_offset(closest_point) # distance approximative parcourue par le joueur
	var progress_ratio = player_distance / path.curve.get_baked_length() # progress ratio approximatif du joueur
	return progress_ratio # retourne la progression
