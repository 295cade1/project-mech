extends Spatial

export (NodePath) var handPath
onready var hand = get_node(handPath)

onready var joint = get_node("Generic6DOFJoint")

export (float) var translational_force = 100.0
export (float) var rotational_force = 100.0

func _ready():
	set_as_toplevel(true)

	joint.set("linear_motor_x/force_limit", translational_force)
	joint.set("linear_motor_y/force_limit", translational_force)
	joint.set("linear_motor_z/force_limit", translational_force)

	joint.set("angular_motor_x/force_limit", rotational_force)
	joint.set("angular_motor_y/force_limit", rotational_force)
	joint.set("angular_motor_z/force_limit", rotational_force)


func _update_joint(target_location : Vector3, target_rotation : Vector3):

	var target_diff = (target_location - hand.global_transform.origin).length()
	var target_dir = (target_location - hand.global_transform.origin).normalized()

	var target_vel = target_dir * min(pow(target_diff / 10 ,2),1) * translational_force / 100

	joint.set("linear_motor_x/target_velocity",-target_vel.x)
	joint.set("linear_motor_y/target_velocity",-target_vel.y)
	joint.set("linear_motor_z/target_velocity",-target_vel.z)

