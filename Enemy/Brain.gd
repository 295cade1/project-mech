extends "res://Enemy/Limb.gd"


var feet_tickets = 1

var feet = 1

var arm_tickets = 1

var hands = 1

var movement_direction = Vector3(0,0,-10)

var target_location = Vector3(0,0,0)

var rand = RandomNumberGenerator.new()

var cam

var nav

var roar_player

var roar = preload("res://Sounds/Used/Roar/EvanRoar.wav")

var roar_timer = 0.0

var stop_dist = 0.0

var heart

func initialize(num_of_feet, base_hands, arm_length, heart_ref):
	cam = get_tree().root.get_node("Root/Player")
	feet_tickets = int(ceil(num_of_feet/2.0))
	arm_tickets = int(ceil(base_hands/3.0))
	stop_dist = arm_length * 0.8
	feet = num_of_feet
	hands = base_hands
	heart = heart_ref
	_setup_roar_player()


func _integrate_forces(state):
	._integrate_forces(state)
	target_location = cam.global_transform.origin
	movement_direction = Vector3(target_location.x,0,target_location.z) - Vector3(self.global_transform.origin.x,0,self.global_transform.origin.z)
	if(movement_direction.length() < stop_dist):
		movement_direction = Vector3(0,0,0)

		
	if(roar_timer >= 0):
		roar_timer -= state.get_step()
	if(roar_timer < 0.0):
		#roar_player.play()
		roar_timer = rand_range(20,50)

func request_ticket():
	return rand.randi_range(0,feet)==0

func request_arm_ticket():
	if(arm_tickets > 0 and rand.randi_range(0,hands) == 0):
		arm_tickets -= 1
		return true
	return false

func return_arm_ticket():
	arm_tickets += 1


func _setup_roar_player():
	var player = AudioStreamPlayer3D.new()
	player.bus = "MonsterSound"
	player.unit_size = 40
	player.unit_db = -4
	player.stream = roar
	player.attenuation_filter_cutoff_hz = 20500
	player.attenuation_filter_db = 0
	player.doppler_tracking = true
	player.attenuation_model = player.ATTENUATION_INVERSE_DISTANCE
	add_child(player)
	roar_player = player


func destroy_connection():
	if(destroyed) : return
	destroyed = true
	heart.destroy_connection()
	.destroy_connection()
