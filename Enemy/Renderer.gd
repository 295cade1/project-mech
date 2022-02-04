extends MultiMeshInstance

onready var children
var tinged = []

const tinge_time = 5

var rendering = false

# Called when the node enters the scene tree for the first time.
func initialize():
	children = get_node("..").limbs
	multimesh.instance_count = children.size()
	tinged.resize(children.size())
	rendering = true

func clear():
	rendering = false


func _process(delta):
	if(!rendering): return
	for i in range(children.size()):
		var position = Transform()
		position = children[i].transform
		multimesh.set_instance_transform(i, position)
		var direction
		if(i==0):
			direction = Vector3(0,10000,0)
		else:
			
			direction = position.basis.xform_inv(get_parent_limb(i).transform.origin - children[i].transform.origin)

		multimesh.set_instance_custom_data(i, Color(direction.x,direction.y,direction.z,children[i].get_child(0).shape.radius))

		var texture_index = 0
		if(!children[0].destroyed):	
			if(i==get_node("..").brain_index):
				texture_index = 1
			elif(i == 0):
				texture_index = 2

		var size = 1
		if(get_parent_limb(i)!=null):
			size = get_parent_limb(i).get_child(0).shape.radius

		if(tinged[i] == null):
			tinged[i] = 0
		var tinge = tinged[i]
		if(tinged[i]>0):
			tinged[i]-=delta
		if(tinged[i]<0):
			tinged[i] = 0

		multimesh.set_instance_color(i, Color(tinge,texture_index,i*3.15133,size))
		

func get_parent_limb(i):
	return children[i].parent_limb

func damage_tinge(limb):
	var i = children.find(limb)
	if(i != 0):
		tinged[i] = tinge_time


