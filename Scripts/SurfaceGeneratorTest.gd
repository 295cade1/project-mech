extends ImmediateGeometry

const SPHEREDIVISIONS = 8
const SUCCDISTANCE = 2
const SPHERESIZE = 1
const XPATTERN = [0,1,0,0,1,1]
const YPATTERN = [0,1,1,0,0,1]

onready var render_spheres = get_children()
onready var sphere_division_angle = deg2rad(360.0/SPHEREDIVISIONS)
onready var verts_per_sphere = 6*SPHEREDIVISIONS*SPHEREDIVISIONS

var vertex_list = []

var render = false



func _ready():
	populate_vertex_list()
	render = true

func _process(delta):
	if(render):
		clear()
		begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(len(render_spheres)):
			var sphere = render_spheres[i]
			var sphere_pos = sphere.transform.origin
			var prev_sphere_pos
			if(i>=0):
				prev_sphere_pos = render_spheres[i-1].transform.origin
			else:
				prev_sphere_pos = render_spheres[i].transform.origin

			for vert_index in range(verts_per_sphere):

				var pos = get_pos_from_index(vert_index)
				var sphere_vert = pos+sphere_pos

				var prev_sphere_vert = (get_pos_from_index((verts_per_sphere-1)-vert_index))+prev_sphere_pos
				var lerp_weight = SUCCDISTANCE - sphere_vert.distance_to(prev_sphere_vert)
				lerp_weight = clamp(lerp_weight,0,1)

				var real_vert = lerp(sphere_vert,prev_sphere_vert,lerp_weight)

				set_normal(pos)
				add_vertex(real_vert)
	end()




func get_pos_from_index(i):
	return vertex_list[i]



func populate_vertex_list():
	for mx in range(SPHEREDIVISIONS):
				for my in range(SPHEREDIVISIONS):
					for p in range(0,6):
						var x = XPATTERN[p] + mx
						var y = YPATTERN[p] + my
						vertex_list.append(generate_rotated_pos(x,y))

						

func generate_rotated_pos(stepsAround, stepsDown):
	var new_pos = Vector3(0,1,0)
	new_pos = new_pos.rotated(Vector3.RIGHT,stepsDown*sphere_division_angle)
	new_pos = new_pos.rotated(Vector3.UP,stepsAround*sphere_division_angle)
	return new_pos*SPHERESIZE
