extends Spatial


var height = 1;

const STOREY_HEIGHT = 0.6

onready var center_multimesh = (get_node("Middle").multimesh as MultiMesh)

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_y = 0;
	center_multimesh.instance_count = height
	for i in range(height):
		current_y += STOREY_HEIGHT
		var transform = Transform()
		transform.origin = Vector3(0,current_y,0)
		transform = transform.rotated(Vector3.UP, PI * (randi() % 4))
		center_multimesh.set_instance_transform(i,transform)
	$Roof.transform.origin = Vector3(0,(current_y + STOREY_HEIGHT + (STOREY_HEIGHT/2)) * 10, 0)

	$"CollisionDetection/CollisionShape".shape.extents = Vector3(10,((height + 3) * STOREY_HEIGHT) * 5, 10)
	$"CollisionDetection/CollisionShape".transform.origin = Vector3(0,((height) * STOREY_HEIGHT) * 5, 0)
		 
