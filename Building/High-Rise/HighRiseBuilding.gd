extends Spatial

const STOREY_HEIGHT = 0.6

onready var center_multimesh

# Called when the node enters the scene tree for the first time.
func start(height):
	center_multimesh = (get_node("Middle").multimesh as MultiMesh)
	var new_mesh = MultiMesh.new()
	new_mesh.mesh = center_multimesh.mesh
	new_mesh.transform_format = MultiMesh.TRANSFORM_3D
	new_mesh.instance_count = height
	center_multimesh = new_mesh
	get_node("Middle").multimesh = center_multimesh
	
	var current_y = 0;
	for i in range(height):
		current_y += STOREY_HEIGHT
		var transform = Transform()
		transform.origin = Vector3(0,current_y,0)
		transform = transform.rotated(Vector3.UP, PI * (randi() % 4))
		center_multimesh.set_instance_transform(i,transform)
	$Roof.transform.origin = Vector3(0,(current_y + STOREY_HEIGHT + (STOREY_HEIGHT/2)) * 10, 0)
	$"CollisionDetection/CollisionShape".shape = BoxShape.new()
	$"CollisionDetection/CollisionShape".shape.extents = Vector3(10,((height + 3) * STOREY_HEIGHT) * 5, 10)
	$"CollisionDetection/CollisionShape".transform.origin = Vector3(0,((height) * STOREY_HEIGHT) * 5, 0)
		 
