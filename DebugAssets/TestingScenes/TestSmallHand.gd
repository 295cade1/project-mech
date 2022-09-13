extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		if movement_paused:
			self.transform.origin.x += event.speed.x * 0.0001
			self.transform.origin.z += event.speed.y * 0.0001
