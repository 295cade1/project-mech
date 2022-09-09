extends Control

onready var text_box = get_node("TextEdit")
onready var output_box = get_node("LineEdit")
onready var enemy_creator = get_node("../EnemyCreator")
onready var building_spawner = get_node("../BuildingSpawner")
onready var building_creator = get_node("../BuildingMultiMesh")
onready var slider = get_node("VSlider")
var alphabet = "fjnbFJNBrqAL123456789"

func _ready():
	building_creator.set_mesh_count(1)
	text_box.clear_colors()
	text_box.add_color_region("/","\n", Color.darkseagreen)
	for ch in "fjnbFJNB":
		text_box.add_keyword_color(ch, Color.mediumaquamarine)
	for ch in "rq":
		text_box.add_keyword_color(ch, Color.crimson)
	for ch in "AL":
		text_box.add_keyword_color(ch, Color.darkslateblue)

func _input(event):
	if(Input.is_key_pressed(KEY_F5)):
		_on_Button_pressed()


func _on_Button_pressed():
	var string = ""
	var comment = false
	var setting_offset = false
	var negative = false
	for i in text_box.text:
		if(comment): continue
		elif(i == "\n"):
			negative = false
			setting_offset = false
			comment = false
		elif(i == "("):
			setting_offset = true
		elif(i == ")"):
			setting_offset = false
		if(setting_offset):
			if(i == "-"):
				negative = true
			elif(i == ","):
				negative = false
			elif(i in "01234"):
				if(!negative):
					string += str(int(i) + 5)
				else:
					string += str(-int(i) + 5)
		elif(i == "/"):
			comment = true
		elif(i in alphabet):
			string += i

	output_box.text = string
	output_box.select_all()

	enemy_creator.create_kaiju(slider.value,string)
	building_creator.set_mesh_count(1)
	create_building()


func create_building():
	building_creator.create_building(building_spawner.global_transform, 4, 20)


	
