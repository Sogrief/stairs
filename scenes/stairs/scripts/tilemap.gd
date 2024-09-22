extends TileMap

var spike_zone = preload("res://scenes/kill_zone/spike_zone.tscn")
var spike_zone_layer : int = 1

func _ready():
	add_spike_zones()
	
#------------------- fonction d'ajout d'une kill_zone aux tiles spikes -------------------
func add_spike_zones():
	var map_size = get_used_rect()
	var spikes_tiles = get_used_cells(spike_zone_layer)
	
	for i in range(spikes_tiles.size()):
		var spike_instance = spike_zone.instantiate()
		add_child(spike_instance)
		spike_instance.position = map_to_local(spikes_tiles[i])
