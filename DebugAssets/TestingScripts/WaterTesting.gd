extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _process(delta):
	self.material_override.set_shader_param("player_pos", get_node("../Camera").global_transform.origin)	
