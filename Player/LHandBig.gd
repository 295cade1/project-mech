extends RigidBody

const MAXARMSPEED = 50
const MAXFORCE = 24000
const MAXMISMATCH = 15

onready var camera = (get_node("../ARVROrigin/ARVRCamera") as ARVRCamera)
onready var player_origin = (get_node("../ARVROrigin") as ARVROrigin)
onready var player = get_node("..")

export(NodePath) var target_hand_path
onready var target_hand = get_node(target_hand_path)

var movement_pressed = false
var is_colliding_with_ground = false
var player_movement_vector = Vector3(0,0,0)
var position_locked = false
var previous_player_velocity = Vector3(0,0,0)

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
	var desired_position = get_desired_hand_pos()
	
	var big_hand_pos =  self.transform.origin
	var target_direction = big_hand_pos.direction_to(desired_position)
	var distance = big_hand_pos.distance_to(desired_position)
	var mismatch = clamp(distance/MAXMISMATCH,0,MAXMISMATCH)

	var target_velocity = target_direction*lerp(0,MAXARMSPEED,mismatch)

	if(is_colliding_with_ground and target_velocity.y < 0 or position_locked):
		lock(true)
		self.player_movement_vector = -target_velocity
		if(movement_pressed):
			position_locked = true
		else:
			position_locked = false
	else:
		player_movement_vector = Vector3(0,0,0)
		lock(false)
		state.linear_velocity = state.linear_velocity - player.linear_velocity
		previous_player_velocity = player.linear_velocity
		var velocity_difference = target_velocity-state.linear_velocity
		state.add_central_force(velocity_difference/(velocity_difference.length()/MAXFORCE))
		var target_rotation = target_hand.transform.basis
		state.transform.basis = target_rotation
		state.angular_velocity = Vector3(0,0,0)
		state.linear_velocity = state.linear_velocity + player.linear_velocity


func lock(is_locked):
	if(is_locked && !self.axis_lock_angular_y):
		play_thud()
	self.axis_lock_linear_z =  is_locked
	self.axis_lock_linear_y =  is_locked
	self.axis_lock_linear_x =  is_locked
	self.axis_lock_angular_z = is_locked
	self.axis_lock_angular_y = is_locked
	self.axis_lock_angular_x = is_locked
	

func play_thud():
	(get_node("ThudPlayer") as AudioStreamPlayer3D).play()


func button_pressed(index):
	match index:
		1:
			pass
		2: 
			movement_pressed = true
			get_node("RobotHand").punch()	
			hand_collision_punch(true)	

func button_released(index):
	match index:
		1:
			pass
		2: 
			movement_pressed = false
			get_node("RobotHand").idle()
			hand_collision_punch(false)	


func hand_collision_punch(val):
	get_node("ClosedHandShape").disabled = !val
	get_node("OpenHandShape1").disabled = val
	get_node("OpenHandShape2").disabled = val
	get_node("OpenHandShape3").disabled = val
	get_node("OpenHandShape4").disabled = val

func _on_body_shape_entered(body_id, body, body_shape, local_shape):
	if(body.is_in_group("Ground")):
		is_colliding_with_ground = true

func _on_body_shape_exited(body_id, body, body_shape, local_shape):
	if(body.is_in_group("Ground")):
		is_colliding_with_ground = false


	
