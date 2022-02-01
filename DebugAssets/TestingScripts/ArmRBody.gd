extends RigidBody


export(NodePath) var start_point_path
export(NodePath) var end_point_path
onready var start_point = get_node(start_point_path) as Spatial
onready var end_point = get_node(end_point_path) as Spatial

onready var length = end_point.transform.origin.x - start_point.transform.origin.x

onready var prev_start_pos = start_point.global_transform.origin
onready var prev_end_pos = end_point.global_transform.origin


export(NodePath) var prev_linked_point_path
var prev_linked_point

export(NodePath) var next_linked_point_path
var next_linked_point

func _ready():
	
	if(next_linked_point_path != null):
		next_linked_point = get_node(next_linked_point_path) as Spatial
	if(prev_linked_point_path != null):
		prev_linked_point = get_node(prev_linked_point_path) as Spatial



func _integrate_forces(state):
	state.linear_velocity = state.linear_velocity.normalized() * clamp(state.linear_velocity.length(),0,10)
	state.angular_velocity = state.angular_velocity.normalized() * clamp(state.angular_velocity.length(),0,10)
	if(prev_linked_point != null):
		var start_offset = start_point.global_transform.origin - global_transform.origin
		var start_target_dir = prev_linked_point.global_transform.origin - start_point.global_transform.origin
		var start_velocity = (start_point.global_transform.origin - prev_start_pos) / state.step

		state.apply_impulse(start_offset, _calculate_additional_force(start_target_dir, start_velocity))
		

		prev_start_pos = start_point.global_transform.origin

		var current_basis = start_point.global_transform.basis
		var target_basis = prev_linked_point.global_transform.basis

		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.z, target_basis.z, current_basis.y) * 10,3) * current_basis.y * mass * 20)
		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.y, target_basis.y, current_basis.z) * 10,3) * current_basis.z * mass * 20)
		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.z, target_basis.z, current_basis.x) * 10,3) * current_basis.x * mass * 20)


	if(next_linked_point != null):
		var end_offset =  end_point.global_transform.origin - global_transform.origin
		var end_target_dir = next_linked_point.global_transform.origin - end_point.global_transform.origin
		var end_velocity = (end_point.global_transform.origin - prev_end_pos) / state.step

		state.apply_impulse(end_offset, _calculate_additional_force(end_target_dir, end_velocity))

		prev_end_pos = end_point.global_transform.origin

		var current_basis = end_point.global_transform.basis
		var target_basis = next_linked_point.global_transform.basis

		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.z, target_basis.z, current_basis.y) * 10,3) * current_basis.y * mass * 20)
		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.y, target_basis.y, current_basis.z) * 10,3) * current_basis.z * mass * 20)
		state.apply_torque_impulse(pow(_get_angle_to_from_axis(current_basis.z, target_basis.z, current_basis.x) * 10,3) * current_basis.x * mass * 20)

	

func _get_angle_to_from_axis(dir1 : Vector3, dir2 : Vector3, axis : Vector3):
	#Align the directions to the axis
	dir1 = axis.cross(-axis.cross(dir1))
	dir2 = axis.cross(-axis.cross(dir2))
	#Get the angle between the two directions
	return dir1.signed_angle_to(dir2, axis) 
	
	
	
	
	

func _calculate_additional_force(target_dir, current_velocity):
	target_dir = target_dir - current_velocity
	var distance = target_dir.length()
	var direction = target_dir.normalized()

	return (distance * mass/3) * direction


	


	

	
