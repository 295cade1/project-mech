extends Spatial

var terrain_mesh

#Size of the terrain in units
export(int) var size = 10
#Amount of squares per unit
export(float) var resolution = 1
#Max Height
export(float) var max_height = 60
#Source Image
export(Texture) var source_texture
var source_image

const BUILDINGSIZE = 20


export(Material) var ground_material

export(Color) var sand_color
export(Color) var grass_color
export(Color) var concrete_color


func start(map_texture):
	source_texture = map_texture 
	source_image = source_texture.get_data()
	source_image.lock()

func complete(building_points):
	terrain_mesh = MeshInstance.new()
	self.add_child(terrain_mesh)
	setup_basic_plane()
	update_terrain_from_image(building_points)
	get_child(0).get_child(0).add_to_group("Ground")
	get_child(0).get_child(0).set_collision_layer_bit( 1, true )
	get_child(0).get_child(0).set_collision_mask_bit( 1, true )

func setup_basic_plane():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size,size)
	plane_mesh.subdivide_depth = size*resolution
	plane_mesh.subdivide_width = size*resolution
	terrain_mesh.mesh = plane_mesh
	terrain_mesh.set_surface_material(0, ground_material)
	

func update_terrain_from_image(building_points):
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,terrain_mesh.mesh.surface_get_arrays(0))
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var building_index = _is_near_building(vertex, building_points)
		if(building_index != -1):
			vertex.y = building_points[building_index].y
			mdt.set_vertex_color(i,concrete_color)
		else:
			vertex.y = get_height_from_image(vertex)
			if(vertex.y < 30):
				mdt.set_vertex_color(i,sand_color)
			else:
				mdt.set_vertex_color(i,grass_color)
		mdt.set_vertex(i, vertex)
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	mesh.regen_normalmaps()
	terrain_mesh.mesh = mesh
	terrain_mesh.create_trimesh_collision()

#finds the nearest building to a point inside BUILDINGSIZE - returns the index to the building in building_points, or returns -1 if not found
func _is_near_building(location, building_points):
	location.y = 0
	var b_size = BUILDINGSIZE * BUILDINGSIZE
	var current_closest = -1
	for building_index in range(len(building_points)):
		var building = building_points[building_index]
		building.y = 0
		if(building.distance_squared_to(location) < b_size):
			if(current_closest == -1): current_closest = building_index
			elif(building_points[current_closest].distance_squared_to(location) > building.distance_squared_to(location)): current_closest = building_index
	return current_closest



func set_terrain_height_in_area(location, height, size, color = Color(1,1,1, 0.5)):
	assert(false, "This is bad, and shouldn't be used, pass building_points into update_terrain_from_image instead")
	size = size * size
	var mesh = terrain_mesh.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var dist = Vector2(vertex.x,vertex.z).distance_squared_to(Vector2(location.x, location.z))
		if(dist < size):
			vertex.y = height
			if(color.a != 1):
				if(vertex.y < 30):
					mdt.set_vertex_color(i,sand_color)
				else:
					mdt.set_vertex_color(i,grass_color)
			else:
				mdt.set_vertex_color(i,color)
		
			

		mdt.set_vertex(i, vertex)
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	mesh.regen_normalmaps()
	self.get_child(0).get_child(0).queue_free()
	terrain_mesh.create_trimesh_collision()

	
	 
	

func get_height_from_image(point : Vector3):
	var point_2d = Vector2(point.x, point.z)
	point_2d = point_2d/size
	point_2d += Vector2(0.5, 0.5)
	point_2d = point_2d * source_image.get_size()
	point_2d = Vector2(clamp(point_2d.x,0,source_image.get_width()-1), clamp(point_2d.y,0,source_image.get_height()-1))
	return source_image.get_pixelv(point_2d).r * max_height



