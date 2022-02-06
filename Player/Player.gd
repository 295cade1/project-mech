extends RigidBody
var perform_runtime_config = false

onready var small_hand_left =  (get_node("ARVROrigin/LeftController") as ARVRController)
onready var small_hand_right = (get_node("ARVROrigin/RightController") as ARVRController)
onready var camera = (get_node("ARVROrigin/ARVRCamera") as ARVRCamera)
onready var big_hand_left =  get_node("LeftHandBig")
onready var big_hand_right = get_node("RightHandBig")
onready var cockpit_glass = (get_node("./Cockpit/Bubble").get_surface_material(1) as Material)

var health = 3

const player_inv_time = 3.5
var timer = 0.0

onready var cbrt_mass = pow(self.mass,1.0/3.0)

const BREAKINGPOINT = 50

func _ready():
	var interface
	if(OS.get_name() == "Android"):
		interface = ARVRServer.find_interface("OVRMobile")
	else: 
		interface = ARVRServer.find_interface("OpenVR")
	if interface:
		
		if interface.initialize():
			get_viewport().arvr = true
			OS.vsync_enabled = false
			Engine.target_fps = 90


func _process(_delta):
	_runtime_config()
	_update_cockpit_opacity()

func _update_cockpit_opacity():
	var opacity = (float(health) * (1.0/3.0) ) * ( 1.0 - ( timer / float(player_inv_time) ) )
	cockpit_glass.set_shader_param("opacity", opacity)

func _runtime_config():
	if not perform_runtime_config:
		if(OS.get_name() == "Android"):
			var ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns").new()
			var ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns").new()
			ovr_init_config.set_render_target_size_multiplier(1)
			ovr_performance.set_foveation_level(4)
			ovr_performance.set_clock_levels(1, 1)
			ovr_performance.set_extra_latency_mode(1)
		perform_runtime_config = true

#Deals with player movement
func _integrate_forces(state):
	if(timer >= 0):
		timer -= state.get_step()
	_player_movement(state)
	_damage_detection(state)

func _player_movement(state):
	var extra_movement_vector = big_hand_right.player_movement_vector + big_hand_left.player_movement_vector
	var max_force = 0
	if(big_hand_left.player_movement_vector!=Vector3(0,0,0)):
		max_force += 3000
	if(big_hand_right.player_movement_vector!=Vector3(0,0,0)):
		max_force += 3000
	if(extra_movement_vector!=Vector3(0,0,0)):
		var target_velocity = extra_movement_vector
		var velocity_difference = target_velocity - self.linear_velocity
		state.add_central_force(velocity_difference.normalized() * min(velocity_difference.length(),1) * max_force)

#Deals with player damaging
func _damage_detection(state):
	var objects = []
	for j in range(state.get_contact_count()):
		var object = state.get_contact_collider_object(j)
		if(objects.find(object) == -1):
			if(object.is_in_group("Enemy")):
				objects.append(object)

	var total_impulse = 0
	for object in objects:
		var additional_impulse = 0
		if(object is RigidBody):
			additional_impulse += abs(((object.linear_velocity*pow(object.mass,1.0/3.0)) - (self.linear_velocity*cbrt_mass)).length())
		else:
			additional_impulse += (self.linear_velocity*cbrt_mass).length()
		if(object.is_in_group("DamageNode")):
			additional_impulse = additional_impulse * 10
		total_impulse += additional_impulse

	total_impulse = total_impulse/cbrt_mass
	
		
	if(total_impulse > 5):
		print("Player Damage Impulse: " + str(total_impulse))
	if(total_impulse>BREAKINGPOINT):
		_damage()


func _damage():
	if(timer < 0):
		health -= 1
		timer = player_inv_time
		$DamagePlayer.play()
		print("Damage")
