extends Generic6DOFJoint


func _physics_process(delta):
	var target = get_node("../Target")
	var hand = get_node("../Hand")

	set("linear_motor_y/target_velocity",-(target.transform.origin.y - hand.transform.origin.y))
	set("linear_motor_x/target_velocity",-(target.transform.origin.x - hand.transform.origin.x))
	set("linear_motor_z/target_velocity",-(target.transform.origin.z - hand.transform.origin.z))
