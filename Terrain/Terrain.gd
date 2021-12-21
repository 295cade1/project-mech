extends Spatial

onready var terrain_mesh = MeshInstance.new()

#Size of the terrain in units
export(int) var size = 10
#Amount of squares per unit
export(float) var resolution = 1
#Max Height
export(float) var max_height = 60
#Source Image
export(Texture) var source_texture
var source_image

export(Material) var ground_material

export(Color) var sand_color
export(Color) var grass_color


func _ready():
	source_image = source_texture.get_data()
	source_image.lock()

	self.add_child(terrain_mesh)
	setup_basic_plane()
	update_terrain_from_image()
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
	

func update_terrain_from_image():
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,terrain_mesh.mesh.surface_get_arrays(0))
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = get_height_from_image(vertex)
		mdt.set_vertex(i, vertex)
		if(vertex.y < 30):
			mdt.set_vertex_color(i,sand_color)
		else:
			mdt.set_vertex_color(i,grass_color)
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	mesh.regen_normalmaps()
	terrain_mesh.mesh = mesh
	terrain_mesh.create_trimesh_collision()
	
	 
	

func get_height_from_image(point : Vector3):
	var point_2d = Vector2(point.x, point.z)
	point_2d = point_2d/size
	point_2d += Vector2(0.5, 0.5)
	point_2d = point_2d * source_image.get_size()
	point_2d = Vector2(clamp(point_2d.x,0,source_image.get_width()-1), clamp(point_2d.y,0,source_image.get_height()-1))
	return source_image.get_pixelv(point_2d).r * max_height



