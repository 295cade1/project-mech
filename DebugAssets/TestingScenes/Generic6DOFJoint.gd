extends Generic6DOFJoint


func _physics_process(delta):
	var target = get_node("../Target")
	var hand = get_node("../Hand")

	set("linear_motor_y/target_velocity",-(target.global_transform.origin.y - hand.global_transform.origin.y))
	set("linear_motor_x/target_velocity",-(target.global_transform.origin.x - hand.global_transform.origin.x))
	set("linear_motor_z/target_velocity",-(target.global_transform.origin.z - hand.global_transform.origin.z))

	#set("angular_motor_y/target_velocity", -hand.angular_velocity.y)
	print(hand.angular_velocity.y)
	
