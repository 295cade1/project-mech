extends "res://Enemy/Limb.gd"

enum {IDLE, WINDUP, ATTACK, TIRED}
var state : int = IDLE

var MAXFORCE = 200
const WINDUPTIME = 5
const ATTACKTIME = 2
const TIREDTIME = 10

var time = 0

var brain
var arm_root

var arm_length
var hand_base_offset

var target_location = Vector3(INF,INF,INF)


func initialize(base_brain, base_arm_root):
	brain = base_brain
	arm_root = base_arm_root
	arm_length = self.global_transform.origin.distance_to(arm_root.global_transform.origin)
	hand_base_offset = self.global_transform.origin - base_arm_root.global_transform.origin
	self.can_sleep = false
	self.add_to_group("DamageNode")
	MAXFORCE = MAXFORCE * mass
	max_force = max_force * 3
	breaking_point = breaking_point * 3
	


func _integrate_forces(phys_state):
	if(destroyed):
		return
	._integrate_forces(phys_state)
	#if(state != 0):
	#	print("state: " + str(state))
	#	print("Timer: " + str(time))
	if(time >= 0):
		time -= phys_state.get_step()
	var force = 0
	match state:
		IDLE:
			if(_target_in_range()):
				_switch_to_windup()
		WINDUP:
			force = 40
			if(time < 0):
				_switch_to_attack()
		ATTACK:
			force = 200
			target_location = brain.target_location
			if(time < 0):
				_switch_to_tired()
		TIRED:
			if(time < 0):
				_switch_to_idle()
	move_towards_location(target_location, force, phys_state)
	
func move_towards_location(target_position, force, phys_state):
	if(target_location == Vector3(INF,INF,INF)):
		return
	if(force == 0):
		return
	var target_direction = self.global_transform.origin.direction_to(target_position)
	var target_distance = self.global_transform.origin.distance_squared_to(target_position)
	var target_velocity = (target_direction*(target_distance/4)) * 10
	var current_velocity = phys_state.linear_velocity
	var velocity_difference = target_velocity-current_velocity
	phys_state.add_central_force(velocity_difference/(velocity_difference.length()/(force * mass)))

func _target_in_range() -> bool:
	return brain.target_location.distance_to(arm_root.global_transform.origin) < min(arm_length,40)

func _switch_to_windup():
	state = WINDUP
	time = WINDUPTIME
	target_location = _get_windup_location()

func _switch_to_attack():
	state = ATTACK
	time = ATTACKTIME
	target_location = brain.target_location

func _switch_to_tired():
	state = TIRED
	time = TIREDTIME
	target_location = Vector3(INF,INF,INF)

func _switch_to_idle():
	state = IDLE

func _get_windup_location() -> Vector3:
	var offset_vector = self.global_transform.origin - brain.target_location
	var base_vector = arm_root.global_transform.origin + hand_base_offset
	return offset_vector + base_vector
	

