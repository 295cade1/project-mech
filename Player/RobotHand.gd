extends Spatial

onready var anim_player = get_node("AnimationPlayer")
onready var anim_tree = get_node("AnimationTree")
onready var state_machine = anim_tree["parameters/playback"]

onready var ray = get_node("Palm/Middle/Middle001/RayCast")

var attached_object = null

enum {Punch,Idle}
var current_state = Idle

func punch():
	state_machine.travel("Punch")
	current_state = Punch
func idle():
	state_machine.travel("Idle")
	current_state = Idle

func _physics_process(_delta):
	if(current_state == Punch):
		if(ray.is_colliding()):
			#anim_player.stop(false)
			#anim_tree.active = (false)
			anim_player.playback_speed = 6
		else:
			#anim_tree.active = true
			anim_player.playback_speed = 1
			state_machine.travel("Punch")
	elif !anim_tree.active:
		#anim_tree.active = true
		anim_player.playback_speed = 1
		state_machine.travel("Idle")


