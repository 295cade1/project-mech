extends RigidBody

var max_force = 1600
var parent_limb : RigidBody
var children_limbs : Array
var parent_joint : ConeTwistJoint
var destroyed = false
var breaking_point = 50

var sqrt_mass = pow(self.mass,1.0/3.0)

var destroy_time = 10

func setup_limb_info(base_parent_limb, base_parent_joint):
	parent_limb = base_parent_limb
	parent_joint = base_parent_joint
	self.contact_monitor = true
	self.contacts_reported = 10
	self.can_sleep = false
	sqrt_mass = pow(self.mass,1.0/3.0)
	self.add_to_group("Enemy")


func add_child_limb(child_limb):
	children_limbs.append(child_limb)


func _integrate_forces(state):
	if(destroyed):
		destroy_time -= state.step
	if(destroy_time <= 0):
		self.transform.origin =  lerp(self.transform.origin, Vector3(0,-100,0),min(abs(destroy_time/10),1))
	if(destroyed): return
	var objects = self.get_colliding_bodies()
	var objects_detected = []

	var total_impulse = 0
	for object in objects:
		if(object is RigidBody and !objects_detected.has(object)):
			var additional_impulse = abs(((object.linear_velocity*pow(object.mass,1.0/3.0)) - (self.linear_velocity*sqrt_mass)).length())
			total_impulse += additional_impulse
			if(object.is_in_group("Building")):
				object.get_node("..").damage(additional_impulse, object)
		else:
			total_impulse += (self.linear_velocity*sqrt_mass).length()
		objects_detected.append(object)

	total_impulse = total_impulse/sqrt_mass
		
	if(total_impulse>max_force):
		destroy_connection()
	elif(total_impulse>breaking_point):
		damage(total_impulse)
	
func destroy_connection():
	if(destroyed):
		return
	for c in children_limbs:
		c.destroy_connection()
	destroyed = true
	parent_joint.queue_free()
	stop_processing()


func stop_processing():
	contact_monitor = false
	destroyed = true
	contact_monitor = false
	contacts_reported = 3
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false

func damage(amount):
	max_force-=amount
	get_node("../Renderer").damage_tinge(self)
	if(max_force<=0):
		destroy_connection()
