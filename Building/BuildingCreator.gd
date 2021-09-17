extends Spatial


onready var floorMultiMesh : MultiMesh = get_node("Floors").multimesh as MultiMesh
onready var wallsMultiMesh : MultiMesh = get_node("Walls").multimesh as MultiMesh
onready var wallsAltMultiMesh : MultiMesh = get_node("WallsAlt").multimesh as MultiMesh

const STORYHEIGHT = 18
const WIDTH = 20
var floors = 3

func _set_floors(floors):
	self.floors = floors

func _ready():
	floorMultiMesh.instance_count = floors
	wallsMultiMesh.instance_count = floors * 2
	wallsAltMultiMesh.instance_count = floors * 2
	for i in range(0,floors):
		_createFloor(i)
		_createWalls(i)
	
func _createFloor(story):
	var transform = Transform()
	transform.origin = Vector3(0,story*STORYHEIGHT,0)
	floorMultiMesh.set_instance_transform(0, transform)

func _createWalls(story):
	var transform = Transform()
	transform.origin = Vector3(0,8.5 + (story*STORYHEIGHT),-WIDTH-1)
	wallsMultiMesh.set_instance_transform(story * 2,transform)
	transform = transform.rotated(Vector3.UP,PI/2)
	wallsAltMultiMesh.set_instance_transform((story * 2), transform)
	transform = transform.rotated(Vector3.UP,PI/2)
	wallsMultiMesh.set_instance_transform((story * 2) + 1, transform)
	transform = transform.rotated(Vector3.UP,PI/2)
	wallsAltMultiMesh.set_instance_transform((story * 2) + 1, transform)
