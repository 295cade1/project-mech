extends Spatial

enum BuildingType {HighRise, PowerTower}
export(BuildingType) var type = BuildingType.HighRise
export(int) var size = 2

var HighRiseLocation = preload("res://Building/High-Rise/HighRiseBuilding.tscn")
var PowerTowerLocation = preload("res://Building/PowerTower/PowerTower.tscn")

var building_model
var max_force = size * 10000
var damage_point = 5000

var move_time = 0
var max_move_time = 0
var move_start:Transform
var move_target:Transform

var invincibility_time = 0

func _ready():
	match(type):
		BuildingType.HighRise:
			building_model = HighRiseLocation.instance()
			building_model.height = size
		BuildingType.PowerTower:
			building_model = PowerTowerLocation.instance()	
	add_child(building_model)
	match(type):
		BuildingType.HighRise:
			$DamagedParticles.emission_box_extents = building_model.get_node("CollisionDetection/CollisionShape").shape.extents
			$DamagedParticles.transform.origin = building_model.get_node("CollisionDetection/CollisionShape").transform.origin
		BuildingType.PowerTower:
			pass
			
func _physics_process(delta):
	damage_detection(delta)
	movement(delta)

func damage_detection(delta):
	if(max_force < 0):
		return
	if(invincibility_time > 0):
		invincibility_time -= delta
		return
	
	var objects = building_model.get_node("CollisionDetection").get_colliding_bodies()

	var total_impulse = Vector3(0,0,0)
	for object in objects:
		if(object is RigidBody):
			if(object.is_in_group("Player")):
				continue
			total_impulse += object.linear_velocity*pow(object.mass,1.0/3.0)
	total_impulse = total_impulse
	var total_force = total_impulse.length()/delta

	if(total_force>max_force):
		max_force -= total_force
		destroy()
	elif(total_force>damage_point):
		max_force -= total_force
		damaged(total_impulse)
		invincibility_time = 2

func movement(delta):
	if(move_time > 0):
		move_time -= (delta * (randf() - 0.1)) * 2
		
		building_model.transform = move_start.interpolate_with(move_target, 1 - (move_time/max_move_time))

func move_building(time:float, location:Transform):
	max_move_time = time
	move_time = time
	move_start = building_model.transform
	move_target = location

func destroy():
	var target_loc = Transform()
	if(type == BuildingType.HighRise):
		var max_height = building_model.get_node("CollisionDetection/CollisionShape").shape.extents.y + building_model.get_node("CollisionDetection/CollisionShape").transform.origin.y
		var min_height = max_height / 2
		var drop_height = min_height + (randf() * min_height)
		target_loc.origin = building_model.transform.origin + Vector3(0,-drop_height,0)
	target_loc = target_loc.rotated(Vector3((randf() * 2) - 1,(randf() * 2) - 1,(randf() * 2) - 1).normalized(), ((randf() * 2) - 1) / 2)

	move_building(4, target_loc)

	$DamagedParticles.restart()
	$DamagedParticles.amount = 50 * size
	$DamagedParticles.lifetime = 5
	$DamagedParticles.emitting = true

func damaged(impulse):

	var xz_impulse = Vector3(impulse.x, 0, impulse.z)

	var rotation_vector = xz_impulse.rotated(Vector3.UP, PI/2).normalized()

	move_building(0.5,
	 building_model.transform.rotated(rotation_vector, -min(abs(impulse.length() / 3600), 0.2))
	)
	$DamagedParticles.amount = impulse.length() / 4
	$DamagedParticles.restart()
