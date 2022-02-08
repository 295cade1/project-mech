extends Node

const SEAHEIGHT = 35

const MINBUILDINGHEIGHT = 5
const MAXBUILDINGHEIGHT = 10

const CHANCEFORBUILDING = float(3.0/5.0)

var building_points = []

var building_preload = preload("res://Building/Building.tscn")
var terrain


var rand = RandomNumberGenerator.new()

func start(terrain_base):
	rand.randomize()
	terrain = terrain_base
	_create_building_grid()

func _create_building_grid():

	for x in range(-500,500,40):
		for z in range(-500,500,40):
			for building in building_points:
				if(Vector2(building.x, building.z).distance_to(Vector2(x,z)) < 40):
					continue
			if(terrain.get_height_from_image(Vector3(x,0,z)) > SEAHEIGHT and float(rand.randf_range(0,1)) > CHANCEFORBUILDING):
				_place_building(Vector3(x,0,z), 0)


func _place_building(location, type):
	var building = building_preload.instance()
	var size = int(rand.randi() % (MAXBUILDINGHEIGHT - MINBUILDINGHEIGHT)) + MINBUILDINGHEIGHT
	location.y = terrain.get_height_from_image(location)
	building.transform.origin = location
	building.start(size, type)
	building_points.append(location)
	get_tree().root.get_node("Root").call_deferred("add_child",building)