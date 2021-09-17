extends Node

onready var terrain = get_node("..")
const building_offset = 5

onready var floorMultiMesh : MultiMesh = get_node("Floors").multimesh as MultiMesh
onready var wallMultiMesh : MultiMesh = get_node("Walls").multimesh as MultiMesh
onready var wallAltMultiMesh : MultiMesh = get_node("WallsAlt").multimesh as MultiMesh
onready var baseMultiMesh : MultiMesh = get_node("Base").multimesh as MultiMesh

onready var floor_phys_base : Node = Node.new()
onready var wall_phys_base : Node = Node.new()
onready var wall_alt_phys_base : Node = Node.new()

var wall_scene = preload("res://Building/WallRigidbody.tscn")
var wall_alt_scene = preload("res://Building/WallAltRigidbody.tscn")
var floor_scene = preload("res://Building/FloorRigidbody.tscn")

var building_scene = preload("res://Building/BuildingRigidbody.tscn")
var base_scene = preload("res://Building/BaseStaticbody.tscn")

var floor_list : Array = []
var wall_list : Array = []
var wall_alt_list : Array = []
var base_list : Array = []

var floor_stops : Array = [0] #stops hold the index of the last part of a building + 1
var wall_stops : Array = [0]
var wall_alt_stops : Array = [0]
var base_stops : Array = [0]

var building_rbodies : Array = [] #holds the rigidbodies that detect building damage

var wall_rbodies : Array = [] #hold the rigidbodies for the building pieces
var wall_alt_rbodies : Array = []
var floor_rbodies : Array = []

var wall_destroyed : Array = []
var wall_alt_destroyed : Array = []
var floor_destroyed : Array = []

const STORYHEIGHT = 9
const WIDTH = 10

# Called when the node enters the scene tree for the first time.
func _start_placing():
	add_child(floor_phys_base)
	add_child(wall_phys_base)
	add_child(wall_alt_phys_base)
	_place_building(Vector2(0,0),1)
	_place_building(Vector2(100,0),2)
	_place_building(Vector2(150,0),3)
	_place_building(Vector2(50,0),4)
	_finalize()


func _place_building(pos : Vector2, floors : int):
	var height = terrain.get_height_from_image(Vector3(pos.x, 0 , pos.y))
	var building_position = Vector3(pos.x, height + building_offset, pos.y)
	_create_building(building_position, floors)
	_place_stops()
	_create_building_rbody(building_position, floors)
	_create_base_staticbody(building_position)

func _create_building_rbody(building_position : Vector3, floors : int):
	var rbody = building_scene.instance()
	rbody.transform.origin = building_position
	rbody.transform.origin.y += (floors*STORYHEIGHT)/2.0

	var shape = BoxShape.new()
	shape.extents = Vector3(11,floors * (STORYHEIGHT/2.0), 11)

	rbody.get_child(0).shape = shape

	building_rbodies.append(rbody)
	add_child(rbody)

func _create_base_staticbody(building_position : Vector3):
	var body = base_scene.instance()
	body.transform.origin = building_position + Vector3(0,-10,0)
	add_child(body) 

func _place_stops():
	floor_stops.append(floor_list.size())
	wall_stops.append(wall_list.size())
	wall_alt_stops.append(wall_alt_list.size())
	base_stops.append(base_list.size())

func _create_building(position, floors):
	_create_base(position)
	for i in range(0,floors):
		_create_floor(position, i)
		_create_walls(position, i)
	
func _create_base(position):
	var transform = Transform()
	transform.origin = position + Vector3(0,-10,0)
	base_list.append(transform)

func _create_floor(base_position, story):
	var transform = Transform()
	transform.origin = Vector3(0,((story+1)*STORYHEIGHT) - 2,0) + base_position
	floor_list.append(transform)

func _create_walls(base_position, story):
	var transform = Transform()
	transform.origin = Vector3(0,4.25 + (story*STORYHEIGHT),-WIDTH-0.5)
	wall_list.append(Transform(transform.basis,transform.origin + base_position))
	transform = transform.rotated(Vector3.UP,PI/2)
	wall_alt_list.append(Transform(transform.basis,transform.origin + base_position))
	transform = transform.rotated(Vector3.UP,PI/2)
	wall_list.append(Transform(transform.basis,transform.origin + base_position))
	transform = transform.rotated(Vector3.UP,PI/2)
	wall_alt_list.append(Transform(transform.basis,transform.origin + base_position))

#Actually place the multi-meshes
func _finalize():
	_place_multi_meshes(floor_list,floorMultiMesh)
	_create_rigidbodies(floor_list, floor_rbodies, floor_destroyed, floor_scene)
	_place_multi_meshes(wall_list,wallMultiMesh)
	_create_rigidbodies(wall_list, wall_rbodies, wall_destroyed, wall_scene)
	_place_multi_meshes(wall_alt_list,wallAltMultiMesh)
	_create_rigidbodies(wall_alt_list, wall_alt_rbodies, wall_alt_destroyed, wall_alt_scene)
	_place_multi_meshes(base_list, baseMultiMesh)

func _place_multi_meshes(transform_list : Array, multimesh : MultiMesh):
	multimesh.instance_count = transform_list.size()
	for i in range(transform_list.size()):
		var transform = transform_list[i]
		transform.origin = transform.origin * 2
		multimesh.set_instance_transform(i,transform)

func _create_rigidbodies(transform_list : Array, rbody_list : Array, destroyed_list : Array, rigidbody : PackedScene):
	for i in range(transform_list.size()):
		var rbody = rigidbody.instance()
		rbody.transform = transform_list[i]
		rbody_list.append(rbody)
		destroyed_list.append(false)	

#Destroying the buildings
func _destroy_building(num : int):
	_destroy(floor_phys_base, floor_destroyed, floor_rbodies, floor_stops, num)
	_destroy(wall_phys_base, wall_destroyed, wall_rbodies, wall_stops, num)
	_destroy(wall_alt_phys_base, wall_alt_destroyed, wall_alt_rbodies, wall_alt_stops, num)
	_destroy_building_rbody(num)

func _destroy_building_rbody(num : int):
	building_rbodies[num].queue_free()

func _destroy(phys_base : Node,destroy_list : Array, rbody_list : Array, stops : Array, building_num : int):
	var from = stops[building_num]
	var to = stops[building_num+1]
	for i in range(from,to):
		destroy_list[i] = true
		phys_base.add_child(rbody_list[i])
		
func _physics_process(_delta):
	_move_meshes_to_rbodies(wallMultiMesh, wall_rbodies, wall_destroyed)
	_move_meshes_to_rbodies(wallAltMultiMesh, wall_alt_rbodies, wall_alt_destroyed)
	_move_meshes_to_rbodies(floorMultiMesh, floor_rbodies, floor_destroyed)
	_check_for_destruction()

func _move_meshes_to_rbodies(multimesh : MultiMesh, rbodies : Array, destroyed : Array):
	for i in range(destroyed.size()):
		if(destroyed[i]):
			var transform = rbodies[i].transform
			transform.origin = transform.origin * 2
			multimesh.set_instance_transform(i,transform)

func _check_for_destruction():
	for i in range(building_rbodies.size()):
			if(is_instance_valid(building_rbodies[i])):
				if(building_rbodies[i].broken):
					_destroy_building(i)

		

