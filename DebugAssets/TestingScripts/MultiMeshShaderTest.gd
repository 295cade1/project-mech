extends MultiMeshInstance

onready var children = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	multimesh.instance_count = len(children)

func _process(delta):
	for i in len(children):
		multimesh.set_instance_transform(i, children[i].transform)
		var direction = children[i-1].transform.origin - children[i].transform.origin
		multimesh.set_instance_custom_data(i, Color(direction.x,direction.y,direction.z,0))
		

