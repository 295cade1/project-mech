extends Spatial

var joints : Array
var endEffector
var target : Spatial

func _ready():
	var child = get_child(0)
	joints.append(child)
	while (child.get_child_count()>0 && !child.get_child(0) is MeshInstance):
		child = child.get_child(0) as Spatial
		joints.append(child)
	endEffector = joints[joints.size()-1]
	target = get_node("../Target") as Spatial
	


func _process(delta):
	var distance_from_target = endEffector.global_transform.origin.distance_to(target.global_transform.origin)
	var runs = 0
	while distance_from_target > 0.5 && runs < 100:
		runs+=1
		for j in range(joints.size()-2):
			var joint = joints[j]
			var joint_position = joint.global_transform.origin

			#Compute Ve, Vt, Vr, a, b, c, theta using (1)(2)
			#Vt
			var vector_target = (target.global_transform.origin - joint_position)
			#Ve
			var vector_end = (endEffector.global_transform.origin - joint_position)
			#Vr
			var vte = vector_target.cross(vector_end)

			var denom = sqrt(pow(vte.x,2) + pow(vte.y,2)+ pow(vte.z,2))

			var vector_rotation = vte / denom

			#Theta
			var theta = acos(vector_end.normalized().dot(vector_target.normalized()))
			#A
			var a = (joints[j+1].global_transform.origin - joint_position).length()
			#B
			var b = (endEffector.global_transform.origin - joints[j+1].global_transform.origin).length()
			#C
			var c =  (target.global_transform.origin - joint_position).length()

			#if c > a + b then
			if(c > a + b):
				#Ji rotate theta, axis Vr
				joint_rotate(joint, theta, vector_rotation)
				continue
			#if c < |a - b| then 	
			if(c < abs(a - b)):
				#Ji rotate -theta, axis Vr
				joint_rotate(joint,-theta,vector_rotation)
				continue
			#if a2 + b2 - c2 > 0
			if(pow(a , 2) + pow(b , 2) - pow(c , 2) > 0):
				#compute angle_b, Bt using (3)(5)
				var angle_b = acos( (pow(a , 2) + pow(c , 2) - pow(b , 2) ) / (2 * a * c) )
				var angle_c = acos( (pow(a , 2) + pow(b , 2) - pow(c , 2) ) / (2 * a * b) )
				var Bt = theta - angle_c
				#if Bt > Wi, then angle b = angle b - 10degrees else angle b = angle b + 10degrees
				var Wi = deg2rad(90)
				if(Bt > Wi):
					angle_b -= deg2rad(10)
				else:
					angle_b += deg2rad(10)
				var Bi = theta - angle_b
				joint_rotate(joint, Bi, vector_rotation)
		distance_from_target = endEffector.global_transform.origin.distance_to(target.global_transform.origin)
	print(runs)


func joint_rotate(joint, angle, axis):
	if is_nan(angle) || is_nan(axis.x):
		return
	joint.rotate((axis),angle)
