extends MeshInstance

const SPHEREDIVISIONS = 8
const SUCCDISTANCE = 4
const SPHERESIZE = 1
const XPATTERN = [0,1,0,0,1,1]
const YPATTERN = [0,1,1,0,0,1]

onready var render_spheres = []
onready var sphere_division_angle = deg2rad(360.0/SPHEREDIVISIONS)

func initialize():
	render_spheres = get_node("..").get_children()
	render_spheres.remove(0)


func _process(delta):
	if(len(render_spheres) == 0 ):
		return
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(len(render_spheres)):
		var sphere = render_spheres[i]
		var sphere_pos = sphere.transform.origin
		var prev_sphere_pos
		if(i>=0):
			prev_sphere_pos = render_spheres[i-1].transform.origin
		else:
			prev_sphere_pos = render_spheres[i].transform.origin

		for mx in range(SPHEREDIVISIONS):
			for my in range(SPHEREDIVISIONS):
				for p in range(0,6):
					var x = XPATTERN[p] + mx
					var y = YPATTERN[p] + my

					st.add_uv(Vector2(float(x)/SPHEREDIVISIONS, float(y)/SPHEREDIVISIONS))

					var sphere_vert = get_rotated_pos(x,y)+sphere_pos

					var prev_sphere_vert = (get_rotated_pos(SPHEREDIVISIONS-x,y)*0.9)+prev_sphere_pos
					var lerp_weight = SUCCDISTANCE - sphere_vert.distance_to(prev_sphere_vert)
					lerp_weight = clamp(lerp_weight,0,1)

					var real_vert = lerp(sphere_vert,prev_sphere_vert,lerp_weight)

					st.add_vertex(real_vert)

	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()

	mesh
	

func get_rotated_pos(stepsAround, stepsDown):
	var new_pos = Vector3(0,1,0)
	new_pos = new_pos.rotated(Vector3.RIGHT,stepsDown*sphere_division_angle)
	new_pos = new_pos.rotated(Vector3.UP,stepsAround*sphere_division_angle)
	return new_pos*SPHERESIZE






