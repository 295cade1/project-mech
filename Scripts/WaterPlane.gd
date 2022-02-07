extends MeshInstance

onready var water_particles = load("res://Assets/Environment/Water/WaterSploosh.tscn")
var particle_array = []
export(int) var max_particles = 5
var current_particle = 0

onready var player = get_node("../Player");

func _process(delta):
	self.material_override.set_shader_param("player_pos", player.global_transform.origin)	


func _ready():
	for i in range(5):
		particle_array.append(water_particles.instance())
		add_child(particle_array[i])

func _on_Area_body_shape_entered(_body_id, body, _body_shape, _local_shape):
	if(body is RigidBody):
		if(body.linear_velocity.length() * body.weight > 100):
			var vel = max(body.linear_velocity.length()/1.5,4)
			var weight = pow(body.weight,1.0/4.0)

			var particle = get_particle()

			particle.transform.origin = Vector3(body.global_transform.origin.x,0,body.global_transform.origin.z)
			particle.initial_velocity = vel
			particle.scale_amount = weight
			particle.amount = min(weight * 8,16)
			particle.emission_sphere_radius = weight/4
			particle.emitting = true
			particle.lifetime = (vel/particle.gravity.length()) * 2
			particle.mesh.material.albedo_texture.current_frame = 0
			particle.mesh.material.albedo_texture.fps = particle.lifetime*3
			

func get_particle():
	var return_particle = particle_array[current_particle]
	current_particle += 1
	current_particle = current_particle % max_particles
	return return_particle
