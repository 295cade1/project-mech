extends "res://Enemy/Limb.gd"


var feet_tickets = 1

var feet = 0

var movement_direction = Vector3(0,0,-10)

var target_location = Vector3(0,0,0)

var rand = RandomNumberGenerator.new()

var cam

var nav

var roar_player

var roar = preload("res://Sounds/Used/Roar/EvanRoar.wav")

var roar_timer = 0.0

var stop_dist = 0.0

func initialize(num_of_feet, arm_length):
	cam = get_tree().root.get_node("Root/Player")
	feet_tickets = num_of_feet/2
	stop_dist = arm_length * 0.9
	feet = num_of_feet
	_setup_roar_player()


func _integrate_forces(state):
	._integrate_forces(state)
	target_location = cam.global_transform.origin
	movement_direction = Vector3(target_location.x,0,target_location.z) - Vector3(self.global_transform.origin.x,0,self.global_transform.origin.z)
	if(movement_direction.length() < stop_dist):
		print("stopping")
		movement_direction = Vector3(0,0,0)

		
	if(roar_timer >= 0):
		roar_timer -= state.get_step()
	if(roar_timer < 0.0):
		#roar_player.play()
		roar_timer = rand_range(20,50)
func request_ticket():
	return rand.randi_range(0,feet)==0


	


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
