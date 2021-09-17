extends Spatial

var bullet = preload("res://DebugAssets/TestingScripts/Shot.tscn")

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var shot = bullet.instance()
		shot.transform = self.global_transform
		shot.linear_velocity = self.global_transform.basis.z * -100
		get_tree().root.add_child(shot)
