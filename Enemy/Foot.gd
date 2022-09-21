extends "res://Enemy/Limb.gd"


enum {STOPPED, UP, MOVING, DOWN, FALLING}

var target_position = Vector3(0,0,0)

var start_position = Vector3(0,0,0)
var end_position = Vector3(0,0,0)

var heart
var heart_offset

var movement_state = FALLING

var brain
var lengthOfLeg

var STOPPEDFORCE = 1000
var DOWNFORCE = 200
var UPFORCE = 100
var MOVEFORCE = 100


var is_on_floor

var time = 0





# Called when the node enters the scene tree for the first time.
func initialize(index, leg_base_index,baseBrain, baseHeart):
	self.axis_lock_angular_x = true
	self.axis_lock_angular_z = true
	self.brain = baseBrain
	self.contact_monitor = true
	self.contacts_reported = 20
	heart = baseHeart
	set_falling_position()
	lengthOfLeg = get_leg_length(index,leg_base_index)
	heart_offset = get_heart_offset()

	max_force = max_force * 3
	breaking_point = breaking_point * 3

	self.physics_material_override = load("res://Enemy/Foot.tres")

func get_leg_length(index, leg_base):
	var limbs = get_node("..").limbs
	return self.global_transform.origin.distance_to(limbs[leg_base].global_transform.origin)

func get_heart_offset():
	return self.global_transform.origin - heart.global_transform.origin

func _integrate_forces(state):
	._integrate_forces(state)
	if(time >= 0):
		time -= state.get_step()
	if(destroyed):
		return
	var objects = []
	for j in range(state.get_contact_count()):
		var object = state.get_contact_collider_object(j)
		if(objects.find(object) == -1):
			objects.append(object)
	is_on_floor = false
	for obj in objects:
		if(!obj.is_in_group("Enemy")):
			is_on_floor = true
	


	var force = 0
	match movement_state:
		STOPPED:
			force = STOPPEDFORCE
			if(need_to_move() and is_free_ticket() and time < 0):
				time = 1
				take_ticket()
				init_start_position()
				init_end_position()
				set_up_position()
				movement_state = UP
			if(!is_on_floor):
				movement_state = FALLING
		FALLING:
			set_falling_position()
			if(is_on_floor):
				set_stopped_position()
				movement_state = STOPPED
		UP:
			force = UPFORCE
			if(time < 0):
				movement_state = MOVING
				set_move_position()
				time = 1.5
		MOVING:
			force = MOVEFORCE
			if(time < 0):
				movement_state = DOWN
				set_down_position()
				time = 3
		DOWN:
			force = DOWNFORCE
			if(time < 0 || is_on_floor):
				set_stopped_position()
				movement_state = STOPPED
				return_ticket()
				time = 4

	if(force == 0):
		return
	var target_direction = self.global_transform.origin.direction_to(target_position)
	var target_distance = self.global_transform.origin.distance_squared_to(target_position)
	var target_velocity = (target_direction*(target_distance/4))*2
	var current_velocity = state.linear_velocity
	var velocity_difference = target_velocity-current_velocity
	state.add_central_force(velocity_difference/(velocity_difference.length()/(force * mass)))
				
func need_to_move():
	return brain.movement_direction.length() > lengthOfLeg

func is_free_ticket():
	return brain.feet_tickets>0 and brain.request_ticket()

func take_ticket():
	brain.feet_tickets-=1
func return_ticket():
	brain.feet_tickets+=1

func set_up_position():
	target_position = heart.global_transform.origin
	#print(self.name + "UP")

func set_move_position():
	target_position = lerp(start_position, end_position, 0.75) + Vector3(0,(lengthOfLeg/2),0)
	#print(self.name + "MOVE")

func set_down_position():
	target_position = end_position + Vector3(0,-10,0)
	#print(self.name + "DOWN")

func set_falling_position():
	target_position = self.global_transform.origin + Vector3(0,-1000,0)

func set_stopped_position():
	target_position = self.global_transform.origin
	#print(self.name + "STOP")
	
func init_start_position():
	start_position = self.global_transform.origin

func init_end_position():
	end_position = _raycast_down(heart.global_transform.origin + Vector3(0,(lengthOfLeg),0) + heart_offset.rotated(Vector3.UP,deg2rad(heart.rotation_degrees.y)) + brain.movement_direction.normalized()*(lengthOfLeg))

func _raycast_down(position) -> Vector3:
	return _raycast_hit_position(_raycast(position, position + Vector3(0,-100,0)))

func _raycast_did_hit(raycastResult:Dictionary):
	return raycastResult.size() > 0

func _raycast_hit_position(raycastResult:Dictionary):
	if(_raycast_did_hit(raycastResult)):
		return raycastResult.get("position")
	else:
		print("Failed raycast to find foot position")
		return Vector3(0,0,0)

func _raycast(from:Vector3, to:Vector3) -> Dictionary:
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(from, to, [self])
