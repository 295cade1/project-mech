extends MeshInstance

onready var target = get_tree().root.get_node("Root/Player")
var stop_moving = false

func _physics_process(delta):
	if(!stop_moving):
		if(Vector3.UP.cross(target.global_transform.origin - self.global_transform.origin) != Vector3()):
			look_at(target.global_transform.origin, Vector3.UP)
	
func explode():
	stop_moving = true
