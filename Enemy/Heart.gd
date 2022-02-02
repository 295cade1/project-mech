extends "res://Enemy/Limb.gd"


var foot_offset = Vector3(0,0,0)
var feet:Array = []
var limbs:Array = []

var brain
const SPEED = 0.4
var MAXFORCE = 20
var UPFORCE = 50
const VELOCITY_LIMIT = 1

func initialize(feet_base, brain_base, limbs_base):
	self.feet = feet_base
	foot_offset = get_foot_offset()
	self.axis_lock_angular_x = true
	self.axis_lock_angular_z = true
	brain = brain_base
	limbs = limbs_base
	UPFORCE = UPFORCE * mass
	MAXFORCE = MAXFORCE * mass


func _integrate_forces(state):
	if(can_move()):	
		var brain_movement_dir = self.global_transform.origin.direction_to(get_desired_position())
		var distance_to_desired_pos = self.global_transform.origin.distance_to(get_desired_position())
		var target_velocity = brain_movement_dir*(distance_to_desired_pos)*SPEED
		var velocity_difference = target_velocity - state.linear_velocity
		state.add_central_force(Vector3(velocity_difference.x/(velocity_difference.length()/MAXFORCE),max(velocity_difference.y/(velocity_difference.length()/UPFORCE),-0),velocity_difference.z/(velocity_difference.length()/MAXFORCE)))

		var current_loc = Vector2(self.global_transform.origin.x,self.global_transform.origin.z)
		var target_loc = Vector2(brain.target_location.x,brain.target_location.z)
		var target_dir = (target_loc-current_loc).normalized()
		var current_dir = -Vector2(self.global_transform.basis.x.x,self.global_transform.basis.x.z)
		var dot_product = target_dir.dot(current_dir)

		var torque = dot_product*1

		state.angular_velocity = (Vector3(0,torque,0))


func can_move():
	var num_of_feet_floored = 0
	for foot in feet:
		if(foot.is_on_floor && !foot.destroyed):
			num_of_feet_floored += 1
	return num_of_feet_floored>=(feet.size()/2)

func get_feet_center():
	var foot_center = Vector3(0,0,0)
	for foot in feet:
		if(!foot.destroyed):
			foot_center+=foot.global_transform.origin
	return foot_center/len(feet)

func get_desired_position():
	return get_feet_center() + foot_offset + (brain.movement_direction.normalized() * (foot_offset.y/4))

func get_foot_offset():
	return (self.global_transform.origin - get_feet_center()) + Vector3(0,0,0)
		
		
		
		
