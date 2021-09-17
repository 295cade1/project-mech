extends Spatial

var joints : Array
var endEffector : RigidBody
var target : Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in self.get_children():
		if(child is Generic6DOFJoint):
			joints.append(child);
	endEffector = get_node("EndEffector")
	target = get_node("../Target") as Spatial
	


func _physics_process(delta):
	for j in range(len(joints)-1):
		var joint = joints[j]
		var joint_position = joint.global_transform.origin

		#Compute Ve, Vt, Vr, a, b, c, theta using (1)(2)
		#Vt
		var vector_target = target.global_transform.origin - joint_position 
		#Ve
		var vector_end = endEffector.global_transform.origin - joint_position
		#Vr
		var vector_rotation = (vector_end.normalized()).cross(vector_target.normalized())
		#Theta
		var theta = acos((vector_end.normalized()).dot((vector_target.normalized())))
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
			var Wi = deg2rad(360)
			if(Bt > Wi):
				angle_b -= deg2rad(10)
			else:
				angle_b += deg2rad(10)
			var Bi = theta - angle_b
			joint_rotate(joint, Bi, vector_rotation)

		
	
	
func joint_rotate(joint : Generic6DOFJoint, angle, axis):
	joint.set("angular_motor_z/target_velocity", angle*axis.z*100)
	joint.set("angular_motor_y/target_velocity", angle*axis.y*100)
	joint.set("angular_motor_x/target_velocity", angle*axis.x*100)
