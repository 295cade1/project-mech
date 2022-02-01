extends Spatial


onready var shoulderXJoint = get_node("ShoulderXJoint") as Generic6DOFJoint
onready var shoulderZJoint = get_node("ShoulderZJoint") as Generic6DOFJoint
onready var elbowZJoint = get_node("ElbowZJoint") as Generic6DOFJoint

onready var elbowRef = get_node("UpperArmMesh/ElbowPos") as Spatial
onready var wristRef = get_node("LowerArmMesh/WristPos") as Spatial
onready var shoulderRef = get_node("ShoulderMesh/ShoulderPos") as Spatial

export(NodePath) var targetPath
onready var target = get_node(targetPath) as Spatial

export(int) var upperArmLength = 5
export(int) var lowerArmLength = 5

export(float) var speed = 3



func _physics_process(delta):
	_arm_movement()
	_hand_movement()
	print(_distance_to_target())

func _distance_to_target():
	return _get_wrist_target().distance_to(wristRef.global_transform.origin)

func _arm_movement():
	var elbowTrans = elbowRef.global_transform
	var wristTrans = wristRef.global_transform
	var shoulderTrans = shoulderRef.global_transform

	var shoulder_movement_angle = -_get_angle_to_from_axis(shoulderTrans.basis.y, shoulderTrans.origin.direction_to(_get_wrist_target()),shoulderTrans.basis.x)

	shoulderXJoint.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY,
	_calculate_arm_speed(shoulder_movement_angle))
	
	var dist = shoulderTrans.origin.distance_to(_get_wrist_target())
	var theta = acos((pow(dist,2) + pow(lowerArmLength,2) - pow(upperArmLength,2)) / (2 * dist * lowerArmLength))
	var shoulder_z_movement_angle = -_get_angle_to_from_axis(
		elbowTrans.basis.x.rotated(shoulderTrans.basis.z,theta),
		shoulderTrans.origin.direction_to(_get_wrist_target()),
		shoulderTrans.basis.z
	)

	
	shoulderZJoint.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY,
	_calculate_arm_speed(shoulder_z_movement_angle)
	)

	var elbow_z_movement_angle = -_get_angle_to_from_axis(
		wristTrans.basis.x,
		elbowTrans.origin.direction_to(_get_wrist_target()),
		elbowTrans.basis.z
	)

	elbowZJoint.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY,
	_calculate_arm_speed(elbow_z_movement_angle)
	)

func _calculate_arm_speed(movement_angle):
	return clamp(movement_angle,-0.5,0.5) * speed
	
func _hand_movement():
	pass


func _get_angle_to_from_axis(dir1 : Vector3, dir2 : Vector3, axis : Vector3):
	#Align the directions to the axis
	dir1 = axis.cross(-axis.cross(dir1))
	dir2 = axis.cross(-axis.cross(dir2))
	#Get the angle between the two directions
	return dir1.signed_angle_to(dir2, axis) 

func _get_wrist_target():
	return target.global_transform.origin



