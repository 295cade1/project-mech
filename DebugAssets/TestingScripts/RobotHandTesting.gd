extends Spatial




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if(Input.is_action_just_pressed("ui_accept")):
		$RobotHand.punch()
	if(Input.is_action_just_released("ui_accept")):
		$RobotHand.idle()
