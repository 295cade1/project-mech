extends AudioStreamPlayer3D





func _input(event):
	if(Input.is_action_just_pressed("ui_accept")):
		_start_play()
	if(Input.is_action_just_released("ui_accept")):
		_end_play()

func _start_play():
	pitch_scale = 1.5
	play()

func _end_play():
	stop()
	play(3.34*2)
