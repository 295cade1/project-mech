extends MeshInstance

onready var target = get_tree().root.get_node("Root/Player")

func _physics_process(delta):
	if(Vector3.UP.cross(target.global_transform.origin - self.global_transform.origin) != Vector3()):
		look_at(target.global_transform.origin, Vector3.UP)
	
