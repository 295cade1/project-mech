extends Spatial

onready var aft_arm = get_node("AftArm") as MeshInstance
onready var elbow = get_node("Elbow") as Spatial
onready var fore_arm = get_node("ForeArm") as MeshInstance
export(NodePath) var targetPath
onready var target = get_node(targetPath) as Spatial
export(NodePath) var cameraPath
onready var cam = get_node(cameraPath) as Spatial

var look_dir = Vector3.FORWARD
const normal_arm_length = 10
const arm_width = 1
const rotation_accuracy = 512

export var x_direction = 1

export var method = 0

func _ready():
	method2(Vector3(1,1,1), Vector3(1,2,3))
	aft_arm.mesh.size = Vector3(arm_width,arm_width,normal_arm_length)
	fore_arm.mesh.size = Vector3(arm_width,arm_width,normal_arm_length)

func _physics_process(delta):
	var base_to_hand = self.global_transform.origin.direction_to(target.global_transform.origin)
	var elbow_offset_from_hand = (target.transform.basis.z * normal_arm_length) + (-target.global_transform.basis.x * x_direction)
	
	var distance_to_target = self.global_transform.origin.distance_to(target.global_transform.origin)

	var midpoint = (self.global_transform.origin + target.global_transform.origin) / 2

	var offset_direction = midpoint.direction_to(elbow_offset_from_hand + target.global_transform.origin)

	var elbow_offset
	if(distance_to_target/2>normal_arm_length):
		elbow_offset = Vector3(0,0,0)
	else:
		elbow_offset = sqrt(pow(normal_arm_length,2) - pow(distance_to_target/2,2)) * get_elbow_offset(base_to_hand, offset_direction)

	var elbow_position = midpoint + elbow_offset

	#(aft_arm.mesh as CubeMesh).size = Vector3(arm_width,arm_width,elbow_position.distance_to(self.global_transform.origin))
	#(fore_arm.mesh as CubeMesh).size = Vector3(arm_width,arm_width,elbow_position.distance_to(target.global_transform.origin))

	var fore_arm_position = (elbow_position + target.global_transform.origin) / 2

	var aft_arm_position = (elbow_position + self.global_transform.origin) / 2

	if(aft_arm_position != elbow_position):
		aft_arm.look_at_from_position(aft_arm_position,elbow_position,Vector3.UP)
	elif (!is_nan(aft_arm_position.x) && !is_nan(aft_arm_position.z)):
		aft_arm.global_transform.origin = aft_arm_position

	if(fore_arm_position != target.global_transform.origin):
		fore_arm.look_at_from_position(fore_arm_position,target.global_transform.origin,Vector3.UP)
	elif (!is_nan(fore_arm_position.x) && !is_nan(fore_arm_position.z)):
		fore_arm.global_transform.origin = fore_arm_position

	if (!is_nan(elbow_position.x) && !is_nan(elbow_position.z)):
		elbow.global_transform.origin = elbow_position
	
func get_elbow_offset(base_to_hand, target_dir):
	if(method == 1):
		return method1(base_to_hand, target_dir)
	if(method == 2):
		return method2(base_to_hand, target_dir)
	if(method == 3):
		return method3(target_dir, base_to_hand.rotated(base_to_hand.cross(Vector3.UP).normalized(), PI/2), base_to_hand)

func method1(base_to_hand, target_dir):
	return base_to_hand.cross(Vector3.UP).normalized()

func method2(base_to_hand, target_dir):
	return base_to_hand.rotated(base_to_hand.cross(target_dir).normalized(),  (PI/2)).normalized()

func method3(direction, cross_product, direction_to_base):
	var new_dir = cross_product
	if(direction_to_base == Vector3(0,0,0)):
		return new_dir
	var best_product = -1
	var best_rotation = 0
	for i in range(360/rotation_accuracy):
		new_dir = new_dir.rotated((direction_to_base.normalized()),deg2rad(rotation_accuracy))
		var product = new_dir.dot(direction)
		if(product > best_product):
			best_product = product
			best_rotation = i
		if(product > 0.99):
			return new_dir
	if(best_rotation == 0):
		return cross_product
	return cross_product.rotated((direction_to_base.normalized()),deg2rad(best_rotation*rotation_accuracy))
