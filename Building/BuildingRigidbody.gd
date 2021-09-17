extends RigidBody

var sqrt_mass = pow(self.mass,1.0/3.0)
var breaking_point = 50
var max_force = 2000
var broken = false

func _integrate_forces(state):
	var objects = []
	for j in range(state.get_contact_count()):
		var object = state.get_contact_collider_object(j)
		if(objects.find(object) == -1):
			if(!object.is_in_group("Player")):
				objects.append(object)

	var total_impulse = 0
	for object in objects:
		if(object is RigidBody):
			total_impulse += (object.linear_velocity*pow(object.mass,1.0/3.0)).length()
	total_impulse = total_impulse/sqrt_mass
		
	if(total_impulse>max_force):
		broken = true
	elif(total_impulse>breaking_point):
		max_force-=total_impulse
