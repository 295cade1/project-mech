extends MultiMeshInstance

var buildings = []

const BREAKPOINT = 100



func set_mesh_count(amount):
	multimesh.instance_count = amount
	multimesh.visible_instance_count = 0

func create_building(transform : Transform, height : int, width : int):
	if(multimesh.visible_instance_count >= multimesh.instance_count):
		print("Tried to create too many buildings")
		return 
	multimesh.visible_instance_count += 1
	var building = Building.new()
	building.init(multimesh.visible_instance_count - 1, transform, height, width, multimesh, self)
	buildings.append(building)

func damage(amount, building_rigidbody):
	if(amount < BREAKPOINT): return
	for building in buildings:
		if(building.rigidbody == building_rigidbody):
			building.damage(amount)
			return

func _physics_process(delta):
	for building in buildings:
		building.update(delta)
	
class Building:
	var instance_num : int
	var health : float 
	var transform : Transform
	var base_transform : Transform
	var height : int
	var width : int
	var rigidbody : RigidBody

	var target_transform : Transform

	var timer = -4
	
	var destroyed = false

	var multimesh : MultiMesh

	func init(_instance_num : int, _transform : Transform, _height : int, _width : int, _multimesh : MultiMesh, parent_ref):
		instance_num = _instance_num
		health = (_height * 50) + 500

		height = _height
		width = _width

		multimesh = _multimesh
		multimesh.set_instance_custom_data(instance_num, Color(width,(_height * 6.0) + 0.1,width,0.0))
		base_transform = _transform
		_create_rigidbody(parent_ref)
		_update_transform(_transform)
		_update_rigidbody()
		

	func update(delta):
		if(timer < -1): return
		if(destroyed):
			timer -=  delta / 2.0
		timer -= delta
		if(timer > 0):
			if(destroyed):
				_update_transform(base_transform.interpolate_with(target_transform, 1 - timer))
			else:
				_update_transform(target_transform.interpolate_with(base_transform,  (1 - timer))) 
		elif(destroyed):
			_update_rigidbody()

	func _update_transform(_transform : Transform):
		transform = _transform
		multimesh.set_instance_transform(instance_num, _transform)
		multimesh.reset_instance_physics_interpolation(instance_num)

	func _update_rigidbody():
		rigidbody.transform = transform
		rigidbody.transform.origin += Vector3(0,height * 3, 0)

	func _damage_anim(amount):
		timer = 1
		target_transform = base_transform
		target_transform.basis = transform.basis.rotated(Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1)).normalized(), rand_range(-0.001,0.001) * amount)

	func damage(amount):
		if(timer > 0): return
		if(destroyed): return
		health -= amount
		
		if(health < 0):
			destroy()
		else:
			_damage_anim(amount)

	func destroy():
		print("destroyed")
		timer = 1
		target_transform = base_transform
		target_transform.origin = target_transform.origin + Vector3(0,(-height * 6)/1.8,0)
		target_transform.basis = transform.basis.rotated(Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1)).normalized(), rand_range(-0.001,0.001) * 200)
		destroyed = true
	
	func _create_rigidbody(parent_ref):
		rigidbody = RigidBody.new()
		var collision_shape = CollisionShape.new()
		collision_shape.shape = BoxShape.new()
		collision_shape.shape.extents = Vector3(width / 2.0,height * 3.0,width / 2.0)
		rigidbody.add_child(collision_shape)
		rigidbody.add_to_group("Building")
		rigidbody.mode = RigidBody.MODE_STATIC
		rigidbody.mass = 10000
		parent_ref.add_child(rigidbody)
		


	
