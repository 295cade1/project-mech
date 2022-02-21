extends Node

const SEAHEIGHT = 35

const MINBUILDINGHEIGHT = 5
const MAXBUILDINGHEIGHT = 50

const CHANCEFORBUILDING = float(3.0/5.0)

var building_points = []

var building_multimesh
var terrain


var rand = RandomNumberGenerator.new()

func start(terrain_base):
	building_multimesh = get_child(0).multimesh as MultiMesh
	building_multimesh.instance_count = pow((1000 / 15),2) * CHANCEFORBUILDING
	rand.randomize()
	terrain = terrain_base
	_create_building_grid()

func _create_building_grid():
	var visible_instances = 0
	for x in range(-500,500,15):
		for z in range(-500,500,15):
			for building in building_points:
				if(Vector2(building.x, building.z).distance_to(Vector2(x,z)) < 15):
					continue
			if(terrain.get_height_from_image(Vector3(x,0,z)) > SEAHEIGHT
			and float(rand.randf_range(0,1)) > CHANCEFORBUILDING
			and visible_instances < building_multimesh.instance_count):
				_place_building(Vector3(x,0,z), 0, visible_instances)
				visible_instances += 1
	building_multimesh.visible_instance_count = visible_instances


func _place_building(location, type, instance_num):
	var size = int(rand.randi() % (MAXBUILDINGHEIGHT - MINBUILDINGHEIGHT)) + MINBUILDINGHEIGHT
	location.y = terrain.get_height_from_image(location)
	var transform = Transform()
	transform.origin = location

	var height = (randi() % (MAXBUILDINGHEIGHT - MINBUILDINGHEIGHT)) + MINBUILDINGHEIGHT

	building_points.append(location)
	building_multimesh.set_instance_transform(instance_num, transform)
	building_multimesh.set_instance_color(instance_num, Color(0.0,(height * 3.0) + 0.1,0.0,0.0))
