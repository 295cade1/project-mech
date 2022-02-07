extends Node


var building_points = []

var building_preload = preload("res://Building/Building.tscn")
var terrain

var rand = RandomNumberGenerator.new()

func start(terrain_base):
	terrain = terrain_base
	_place_building(Vector3(0,100,0))


func _place_building(location):
	var building = building_preload.instance()
	building.size = rand.randi_range(5,10)
	location.y = terrain.get_height_from_image(location)
	building.transform.origin = location
	building_points.append(location)
	get_tree().root.get_node("Root").call_deferred("add_child",building)