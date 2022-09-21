extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _integrate_forces(state):
	var extra_movement_vector = get_child(0).player_movement_vector
	var max_force = 3000
	if(extra_movement_vector!=Vector3(0,0,0)):
		var target_velocity = extra_movement_vector
		var velocity_difference = target_velocity - self.linear_velocity
		state.add_central_force(velocity_difference.normalized() * min(velocity_difference.length(),1) * max_force)