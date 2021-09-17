extends ARVRController


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(NodePath) var big_hand_path


func _ready():
    connect("button_pressed", get_node(big_hand_path), "button_pressed")
    connect("button_release", get_node(big_hand_path), "button_released")
