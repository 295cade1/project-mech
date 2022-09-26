extends Node

const SEAHEIGHT = 35

const MINBUILDINGHEIGHT = 5
const MAXBUILDINGHEIGHT = 20

const CHANCEFORBUILDING = float(3.0/5.0)

var building_points = []

var building_multimesh
var terrain


var rand = RandomNumberGenerator.new()

func start(terrain_base):
	building_multimesh = get_child(0)
	building_multimesh.set_mesh_count(pow((1000 / 30),2) * CHANCEFORBUILDING)
	rand.randomize()
	terrain = terrain_base
	_create_building_grid()


func _create_building_grid():
	for x in range(-500,500,30):
		for z in range(-500,500,30):
			for building in building_points:
				if(Vector2(building.x, building.z).distance_to(Vector2(x,z)) < 30):
					continue
			if(terrain.get_height_from_image(Vector3(x,0,z)) > SEAHEIGHT
			and float(rand.randf_range(0,1)) > CHANCEFORBUILDING):
				_place_building(Vector3(x,0,z), 0)


func _place_building(location, type):
	location.x = location.x + rand.randf_range(-5,5)
	location.z = location.z + rand.randf_range(-5,5)

	var size = int(rand.randi() % (MAXBUILDINGHEIGHT - MINBUILDINGHEIGHT)) + MINBUILDINGHEIGHT
	location.y = terrain.get_height_from_image(location)
	var transform = Transform()
	transform.origin = location
	transform.basis = transform.basis.rotated(Vector3.UP, rand.randf_range(-PI, PI))
	
	var height = (randi() % (MAXBUILDINGHEIGHT - MINBUILDINGHEIGHT)) + MINBUILDINGHEIGHT
	var width = (randi() % (20 - 10)) + 10
	building_points.append(location)
	building_multimesh.create_building(transform, height, width)
	
