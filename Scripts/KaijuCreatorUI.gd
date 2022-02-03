extends Control

onready var text_box = get_node("TextEdit")
onready var output_box = get_node("LineEdit")
onready var enemy_creator = get_node("../Enemy")
onready var building_spawner = get_node("../BuildingSpawner")
var building = preload("res://Building/Building.tscn")
var alphabet = "fjnbFJNBrqAL123456789"

func _ready():
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
	enemy_creator.clear()
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

	enemy_creator.create_kaiju(1,string)

	building_spawner.get_child(0).queue_free()
	var new_building = building.instance()
	new_building.size = int(rand_range(1,10))
	building_spawner.add_child(new_building)
	


	
