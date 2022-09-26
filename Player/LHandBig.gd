extends RigidBody

onready var camera = (get_node("../ARVROrigin/ARVRCamera") as ARVRCamera)
onready var player_origin = (get_node("../ARVROrigin") as ARVROrigin)
onready var player = get_node("..")
onready var raycast = (get_node("RayCast") as RayCast)

export(NodePath) var target_hand_path
onready var target_hand = get_node(target_hand_path)

onready var joint = get_node("Joint")

var player_movement_vector = Vector3(0,0,0)

var position_locked = false
var pinjoint = null
var connected_object = null

var played_thud = false

var old_location = Vector3(0,0,0)
var expected_movement = Vector3(0,0,0)

func _ready():
	self.set_as_toplevel(true)

func _integrate_forces(state):
	move_hand(state)

func get_desired_hand_pos():
	var desired_position = Vector3(0,0,0)
	desired_position = target_hand.transform.origin - (camera.transform.origin*1)
	desired_position = desired_position*35
	desired_position = desired_position + player.transform.origin + player_origin.transform.origin
	return desired_position

func move_hand(state):

	joint._update_joint(get_desired_hand_pos(), target_hand.rotation_degrees)

	##PLAYER MOVEMENT#

	## SOUND FX ##
	#if(min_phys_length < 0.25):
	#	if(!played_thud):
	#	play_thud()
	#		played_thud = true
	#else:
	#	if(min_phys_length == 1):
	#		played_thud = false
	

func try_lock():
	if(raycast.is_colliding()):
		pinjoint = PinJoint.new()
		pinjoint.global_transform.origin = self.global_transform.origin
		pinjoint.set("nodes/node_b", self.get_path())
		if(raycast.get_collider() is RigidBody and raycast.get_collider().mode == 0):
			pinjoint.set("nodes/node_a", raycast.get_collider().get_path())
			pinjoint.global_transform.origin = raycast.get_collider().global_transform.origin
		get_tree().root.add_child(pinjoint)
		position_locked = true
		connected_object = raycast.get_collider()
		change_hand_collision(2)
	else:
		change_hand_collision(1)

	

func unlock():
	position_locked = false
	change_hand_collision(0)
	if(pinjoint != null):
		pinjoint.queue_free()
		pinjoint = null


func play_thud():
	pass
	#(get_node("ThudPlayer") as AudioStreamPlayer3D).play()

func button_pressed(index):
	match index:
		1:
			pass
		2: 
			get_node("RobotHand").punch()	
			try_lock()

func button_released(index):
	match index:
		1:
			pass
		2: 
			get_node("RobotHand").idle()
			unlock()


func change_hand_collision(val):
	get_node("ClosedHandShape").disabled = (val == 1)
	get_node("OpenHandShape1").disabled = (val == 0)
	get_node("OpenHandShape2").disabled = (val == 0)
	get_node("OpenHandShape3").disabled = (val == 0)
	get_node("OpenHandShape4").disabled = (val == 0)
	get_node("GrabbedHandShape").disabled = (val == 2)

	
func _get_angle_to_from_axis(dir1 : Vector3, dir2 : Vector3, axis : Vector3):
	axis = axis.normalized()
	dir1 = dir1.normalized()
	dir2 = dir2.normalized()
	#Align the directions to the axis
	dir1 = axis.cross(-axis.cross(dir1))
	dir2 = axis.cross(-axis.cross(dir2))
	#Get the angle between the two directions
	return dir1.signed_angle_to(dir2, axis) 
