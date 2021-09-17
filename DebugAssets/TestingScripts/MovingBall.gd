extends Position3D

var time = 0


func _process(delta):
	time+=delta
	self.transform.origin.y = sin(time)
