extends Spatial

onready var camera = get_node("../ARVROrigin/ARVRCamera") as Spatial

func _physics_process(delta):
	self.rotation.y = camera.rotation.y