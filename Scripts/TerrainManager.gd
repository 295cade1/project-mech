extends Node


var terrain_preload = preload("res://Terrain/Terrain.tscn")
var terrain

var map_data_folder = "res://GameData/MapData/"


func start():
	terrain = terrain_preload.instance()
	terrain.start(_pick_terrain_data())
	get_tree().root.get_node("Root").call_deferred("add_child",terrain)

func complete(building_points):
	terrain.complete(building_points)



func _pick_terrain_data():
	var dir = Directory.new()
	dir.open(map_data_folder)
	dir.list_dir_begin(true, true)
	var files = []
	while(true):
		var file = dir.get_next()
		if(file == ""):
			break
		else:
			if(!file.ends_with(".import")):
				files.append(file)
	dir.list_dir_end()
	var file_index = int(randi()%files.size())

	print(files[file_index])

	return (load(map_data_folder + files[file_index]) as Texture)
