extends RigidBody

var max_force = 1600
var parent_limb : RigidBody
var children_limbs : Array
var parent_joint : ConeTwistJoint
var destroyed = false
var breaking_point = 50

var sqrt_mass = pow(self.mass,1.0/3.0)

func setup_limb_info(base_parent_limb, base_parent_joint):
	parent_limb = base_parent_limb
	parent_joint = base_parent_joint
	self.contact_monitor = true
	self.contacts_reported = 10
	sqrt_mass = pow(self.mass,1.0/3.0)
	self.add_to_group("Enemy")


func add_child_limb(child_limb):
	children_limbs.append(child_limb)



func _integrate_forces(state):
	if(destroyed):
		return
	var objects = []
	for j in range(state.get_contact_count()):
		var object = state.get_contact_collider_object(j)
		if(objects.find(object) == -1):
			objects.append(object)

	var total_impulse = 0
	for object in objects:
		if(object is RigidBody):
			total_impulse += abs(((object.linear_velocity*pow(object.mass,1.0/3.0)) - (self.linear_velocity*sqrt_mass)).length())
		else:
			total_impulse += (self.linear_velocity*sqrt_mass).length()
	total_impulse = total_impulse/sqrt_mass
		
	if(total_impulse>max_force):
		destroy_connection()
	elif(total_impulse>breaking_point):
		damage(total_impulse)
	
func destroy_connection():
	if(destroyed):
		return
	for c in children_limbs:
		c.stop_processing()
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
	for c in children_limbs:
		c.stop_processing()
	set_process(false)
	set_physics_process(false)

func damage(amount):
	max_force-=amount
	get_node("../Renderer").damage_tinge(self)
	if(max_force<=0):
		destroy_connection()
