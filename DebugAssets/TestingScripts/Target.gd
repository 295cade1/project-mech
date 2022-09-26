extends Position3D

var time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time+=delta
	#self.global_transform.origin = Vector3(sin(time/3),sin(time/8),sin(time/5))*10
	#self.rotate_x(deg2rad(3*delta))
	#self.rotate_y(deg2rad(8*delta))
	#self.rotate_z(deg2rad(5*delta))
