extends Spatial

enum joint_type {FIXED, NORMAL, NONE, JOINT}
enum limb_type {ROOT, CHILD}

const DEBUG = false

var limbs:Array = []
var feet:Array = []
var hands:Array = []
var legs:Array = []
var arms:Array = []

var brain_index

const UNITMASS = 1

var foot_size = 3
var body_size = 2
var heart_size = 5 
var brain_size = 4
var hand_size = 3
var regular_size = 1.5
var straight_size = 1.5
var joint_size = 2

var size = 0

onready var globalMaterial = load("res://Enemy/materials/Skin.tres")
onready var heartMaterial = load("res://Enemy/materials/Heart.tres")
onready var brainMaterial = load("res://Enemy/materials/Brain.tres")

onready var footScript = load("res://Enemy/Foot.gd")
onready var brainScript = load("res://Enemy/Brain.gd")
onready var heartScript = load("res://Enemy/Heart.gd")
onready var limbScript = load("res://Enemy/Limb.gd")
onready var handScript = load("res://Enemy/Hand.gd")



# Called when the node enters the scene tree for the first time.
func _ready():
	create_kaiju(1, "RB1565@1565l31445l31645a35465a35665")

func create_kaiju(size, string : String):
	# R - Root
	# F - Create 1 fixed node (parent node offset, pos offset)
	# N - Create 1 normal node (parent node offset, pos offset)
	# J - Create 1 joint node (parent node offset, pos offset)
	# B - Create 1 body node (parent node offset, pos offset)
	# @ - Create 1 brain node (parent node offset, pos offset)
	# a - Create an arm (parent node offset, length, joints, pos offset)
	# l - Create a leg (parent node offset, length, joints, pos offset)
	# S - Create a "Spine" chain of body nodes (parent node offset, length, pos offset)
	var node_num = 0
	var nodes = []

	for i in range(0, string.length()):
		match(string[i]):
			"R":
				nodes.append(create_root_node())
				node_num += 1
			"F":
				var base_index = nodes[node_num - int(string[i + 1])]
				var pos_offset = Vector3(float(string[i + 2]) - 5, float(string[i + 3]) - 5, float(string[i + 4]) - 5)
				nodes.append(create_straight_node(base_index, pos_offset))
				node_num += 1
			"N":
				var base_index = nodes[node_num - int(string[i + 1])]
				var pos_offset = Vector3(float(string[i + 2]) - 5, float(string[i + 3]) - 5, float(string[i + 4]) - 5)
				nodes.append(create_limb_node(base_index, pos_offset))
				node_num += 1
			"J":
				var base_index = nodes[node_num - int(string[i + 1])]
				var pos_offset = Vector3(float(string[i + 2]) - 5, float(string[i + 3]) - 5, float(string[i + 4]) - 5)
				nodes.append(create_joint_node(base_index, pos_offset))
				node_num += 1
			"B":
				var base_index = nodes[node_num - int(string[i + 1])]
				var pos_offset = Vector3(float(string[i + 2]) - 5, float(string[i + 3]) - 5, float(string[i + 4]) - 5)
				nodes.append(create_body_node(base_index, pos_offset))
				node_num += 1
			"@":
				var base_index = nodes[node_num - int(string[i + 1])]
				var pos_offset = Vector3(float(string[i + 2]) - 5, float(string[i + 3]) - 5, float(string[i + 4]) - 5)
				nodes.append(create_brain_node(base_index, pos_offset))
				node_num += 1
			"a":
				var base_index = nodes[node_num - int(string[i + 1])]
				var length = int(string[i + 2])
				var pos_offset = Vector3(float(string[i + 3]) - 5, float(string[i + 4]) - 5, float(string[i + 5]) - 5)
				create_arm(base_index, pos_offset, length)
			"l":
				var base_index = nodes[node_num - int(string[i + 1])]
				var length = int(string[i + 2])
				var pos_offset = Vector3(float(string[i + 3]) - 5, float(string[i + 4]) - 5, float(string[i + 5]) - 5)
				create_leg(base_index, pos_offset, length)
			"S":
				var base_index = nodes[node_num - int(string[i + 1])]
				var length = int(string[i + 2])
				var pos_offset = Vector3(float(string[i + 3]) - 5, float(string[i + 4]) - 5, float(string[i + 5]) - 5)
				nodes.append(create_straight_chain(base_index, pos_offset, length))
				node_num += 1

	finalize()



func finalize():
	set_limb_new_script(limbs[brain_index],brainScript)
	limbs[brain_index].initialize(len(feet))
	for f in range(len(feet)):
		set_limb_new_script(limbs[feet[f]],footScript)
		limbs[feet[f]].initialize(feet[f],legs[f],limbs[brain_index],limbs[0])
	set_limb_new_script(limbs[0],heartScript)

	var newFeet = []
	for foot in feet:
		newFeet.append(limbs[foot])
	limbs[0].initialize(newFeet,limbs[brain_index], limbs)

	for h in range(len(hands)):
		set_limb_new_script(limbs[hands[h]],handScript)
		limbs[hands[h]].initialize(limbs[brain_index], limbs[legs[h]])

	get_child(0).initialize()

#High Level Functions
func create_arm(parent_index:int, offset, amount:int):
	arms.append(parent_index)
	var last_index = create_limb_chain(parent_index,offset,amount-1)
	return create_hand_node(last_index)

func create_leg(parent_index:int, offset, amount:int):
	legs.append(parent_index)
	var last_index = create_segmented_section(parent_index,offset,amount-1,2)
	return create_foot_node(last_index)

func create_segmented_section(parent_index:int, offset, amount_per_segment:int, segments:int):
	var last_index = parent_index
	for _i in range(segments):
		last_index = create_joint_node(last_index,offset)
		last_index = create_straight_chain(last_index,offset,int(amount_per_segment/segments)-1)
	return last_index

func create_straight_chain(parent_index:int, offset, amount:int):
	var last_id_val = create_straight_node(parent_index,offset)
	for _i in range(0,amount-1):
		last_id_val = create_straight_node(last_id_val,offset)
	return last_id_val

func create_body_chain(parent_index:int, offset, amount:int):
	var last_id_val = create_body_node(parent_index,offset)
	for _i in range(0,amount-1):
		last_id_val = create_body_node(last_id_val,offset)
	return last_id_val

func create_limb_chain(parent_index:int, offset, amount:int):
	var last_id_val = create_body_node(parent_index,offset)
	for _i in range(0,amount-1):
		last_id_val = create_limb_node(last_id_val,offset)
	return last_id_val

func create_root_node():
	return create_limb(limb_type.ROOT,joint_type.NONE, heart_size, heartMaterial)

func create_limb_node(parent_index:int, offset):
	return create_limb(limb_type.CHILD,joint_type.NORMAL,regular_size,globalMaterial,parent_index,offset)

func create_joint_node(parent_index:int, offset):
	return create_limb(limb_type.CHILD,joint_type.JOINT,joint_size,globalMaterial,parent_index,offset)

func create_straight_node(parent_index:int, offset):
	return create_limb(limb_type.CHILD,joint_type.FIXED,straight_size,globalMaterial,parent_index,offset)

func create_body_node(parent_index:int, offset):
	return create_limb(limb_type.CHILD,joint_type.FIXED,body_size,globalMaterial,parent_index,offset)

func create_brain_node(parent_index:int, offset):
	brain_index = create_limb(limb_type.CHILD,joint_type.FIXED,brain_size,brainMaterial,parent_index,offset)
	return brain_index

func create_foot_node(parent_index:int):
	var foot = create_limb(limb_type.CHILD,joint_type.NORMAL,foot_size,globalMaterial,parent_index,Vector3(0,-1,0))
	feet.append(foot)
	return foot

func create_hand_node(parent_index:int):
	var hand = create_limb(limb_type.CHILD,joint_type.NORMAL,hand_size,globalMaterial,parent_index,Vector3(0,1,0))
	hands.append(hand)
	return hand

#Mid level function accumulator
func create_limb(l_type:int, j_type:int, radius:float, mat:Material, parent_index:int = -1, offset:Vector3 = Vector3(0,0,0)):
	var limb_index = len(limbs)
	var newLimb
	match l_type:
		limb_type.ROOT:
			newLimb = create_root_limb(limb_index, radius, mat)
			add_child(newLimb)
			newLimb.set_script(limbScript)
		limb_type.CHILD:
			var parent_limb = limbs[parent_index]
			newLimb = create_child_limb(limb_index, radius, mat, parent_limb, offset)
			add_child(newLimb)
			newLimb.set_script(limbScript)
			var new_joint = create_joint(limb_index,j_type, newLimb, parent_limb)
			add_child(new_joint)
			newLimb.setup_limb_info(parent_limb, new_joint)
			limbs[parent_index].call("add_child_limb",newLimb)
	newLimb.name = generate_name(limb_index,parent_index,l_type,j_type)
	limbs.append(newLimb)
	return limb_index

#Mid Level Functions

#Generates a name for a limb based on info
func generate_name(_limb_index:int, parent_index:int, l_type:int, j_type:int):
	return str(parent_index) + "_" + str(l_type) + "_" + str(j_type)

#Creates a limb without a parent
func create_root_limb(_limb_index:int, radius:float, mat:Material):
	var limb = create_base_limb(Vector3(0,0,0), radius, mat)
	return limb

#Creates a limb that is physics jointed to another node *parent_limb* at the direction *baseOffset*
func create_child_limb(_limb_index:int, radius:float, mat:Material, parent_limb, baseOffset:Vector3):
	var parent_radius = parent_limb.get_child(0).shape.radius
	var offset = baseOffset.normalized() * (radius+parent_radius)
	var position = parent_limb.transform.origin + offset

	var limb = create_base_limb(position, radius, mat)

	if(is_limb_location_clear(radius+parent_radius,position,parent_limb)):
		assert(false,"tried to place limb in an already placed location")
		return
	return limb

#Checks if the new node would collide with another node
func is_limb_location_clear(radius,position,parent_limb):
	#var r_squared = radius
	var collides = false
	for limb in limbs:
		if(limb == parent_limb):
			continue
		if(limb.transform.origin.distance_squared_to(position)<radius):
			print("distance" + str(limb.transform.origin.distance_to(position)))
			print("radius" + str(radius))
			collides = true
	return collides

func create_joint(_limb_index,j_type, new_limb:RigidBody, parent_limb:RigidBody):
	var swing_span
	var twist_span
	match j_type:
		joint_type.NORMAL:
			swing_span = 60
			twist_span = 180
		joint_type.JOINT:
			swing_span = 60
			twist_span = 180
		joint_type.FIXED:
			swing_span = 0
			twist_span = 0
		joint_type.NONE:
			print_debug("ERROR: joint type none on a new joint")
	var parent_location = parent_limb.transform.origin
	var new_limb_location = new_limb.transform.origin
	var parent_radius = parent_limb.get_child(0).shape.radius
	var new_limb_direction = new_limb_location - parent_location
	new_limb_direction = new_limb_direction.normalized()
	#Gets the position at the edge of the parent's sphere going towards the new limb
	var position = parent_location + new_limb_direction*parent_radius 

	var joint:ConeTwistJoint = create_cone_twist_joint(swing_span,twist_span, position, new_limb_direction)

	joint.set_node_a(parent_limb.get_path())
	joint.set_node_b(new_limb.get_path())

	return joint

#Low level Functions
func create_cone_twist_joint(swing_span:float, twist_span:float, position:Vector3, direction:Vector3):
	direction = direction.normalized() #Ensure the direction is normalized

	var joint = ConeTwistJoint.new()
	joint.swing_span = swing_span
	joint.twist_span = twist_span
	joint.transform.origin = position

	var current_rotation = joint.transform.basis.x
	var rotation_axis = get_rotation_axis(current_rotation,direction)
	if(rotation_axis!=null):
		var rotation_amount = get_rotation_amount(current_rotation,direction)
		joint.rotate(rotation_axis,rotation_amount)
	return joint

func get_rotation_axis(current_rotation, target_rotation):
	if(current_rotation!=target_rotation):
		return current_rotation.cross(target_rotation).normalized()
	return null # Returns null if we are already rotated the same direction

func get_rotation_amount(current_rotation:Vector3,target_rotation:Vector3):
	return current_rotation.angle_to(target_rotation)


#Generates the rigidbody w/ child collider and CSG Sphere nodes
func create_base_limb(position, radius:float, mat:Material):
	var limb = create_rigidbody(radius, position)
	var collider = create_collider(radius)
	limb.add_child(collider)
	if(DEBUG):
		limb.add_child(create_debug_sphere(radius, mat))
	return limb

#Generates a rigidbody and sets it's position to *position*
func create_rigidbody(radius, position:Vector3):
	var new_body = RigidBody.new()
	new_body.transform.origin = position
	new_body.mass = (4/3) * PI * pow(radius,3) * UNITMASS
	#Allows the enemy to collide with the player
	new_body.set_collision_layer_bit(1,true)
	new_body.set_collision_mask_bit(1,true)
	return new_body

#Generates a sphere collider with radius *radius*
func create_collider(radius):
	var collider = CollisionShape.new()
	var shape = SphereShape.new()
	shape.radius = radius
	collider.shape = shape
	return collider

#Generates a CSG sphere for debugging with radius *radius* and material *mat*
func create_debug_sphere(radius, mat):
	var sphere = CSGSphere.new()
	sphere.radius = radius
	sphere.material = mat
	return sphere

func set_limb_new_script(limb, script : Script):
	var parent_limb = limb.parent_limb
	var parent_joint = limb.parent_joint
	var children_limbs = limb.children_limbs
	limb.set_script(script)
	limb.parent_limb = parent_limb
	limb.parent_joint = parent_joint
	limb.children_limbs = children_limbs
	

