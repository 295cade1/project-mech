extends Node


onready var base_player = (get_node("../Base/AudioPlayer") as AudioStreamPlayer3D)
onready var elbow_player = (get_node("../Elbow/AudioPlayer") as AudioStreamPlayer3D)

onready var base = (get_node("../Base") as MeshInstance)
onready var elbow = (get_node("../Elbow") as MeshInstance)
onready var fore_arm = (get_node("../ForeArm") as MeshInstance)
var previous_base_elbow_dir = Vector3(0,1,0)
var previous_elbow_target_dir = Vector3(0,1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#base_player.play(base_player.global_transform.origin.y/base_player.stream.get_length())
	#elbow_player.play(elbow_player.global_transform.origin.y/elbow_player.stream.get_length())
	
func _physics_process(delta):
	var base_elbow_dir = elbow.transform.origin - base.transform.origin
	base_player.pitch_scale = clamp(lerp(base_player.pitch_scale ,base_elbow_dir.angle_to(previous_base_elbow_dir) * 400, delta),0.3,10)
	previous_base_elbow_dir = base_elbow_dir

	var elbow_target_dir = fore_arm.transform.origin - elbow.transform.origin
	elbow_player.pitch_scale = clamp(lerp(elbow_player.pitch_scale ,elbow_target_dir.angle_to(previous_elbow_target_dir) * 400, delta),0.3,10)
	previous_elbow_target_dir = elbow_target_dir
	
