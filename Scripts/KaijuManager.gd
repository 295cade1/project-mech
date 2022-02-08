extends Node

var kaiju_preload = preload("res://Enemy/Enemy.tscn")
var kaiju_data_folder = "res://GameData/KaijuData/"

var terrain 
var spawn_timer = 10
var size = 0.7 

var rand

var enemy = null


func start(terrain_base):
	rand = RandomNumberGenerator.new()
	rand.randomize()
	terrain = terrain_base

func _spawn_kaiju():
	enemy = kaiju_preload.instance()
	var x = 0
	var y = 1000
	var z = 0
	while(y > 30):
		if(int(rand.randi_range(0,1)) == 0):
			z = float(rand.randf_range(-500,500))
			x = 400
		else:
			x = float(rand.randf_range(-500,500))
			z = 400
		y = terrain.get_height_from_image(Vector3(x,0,z))
	enemy.transform.origin = Vector3(x,y + 50,z)
	print("Spawned")
	get_tree().root.get_node("Root").add_child(enemy)
	enemy.create_kaiju(size, _get_kaiju_code())
	
func _get_kaiju_code():
	var file = _get_kaiju_file()
	var f = File.new()
	f.open(file, File.READ)
	var line_index = int(rand.randi_range(0,100))
	var kaiju_code = ""
	for i in range(line_index):
		kaiju_code = f.get_line()
		if(f.eof_reached()):
			f.seek(0)
	f.close()
	print(kaiju_code)
	return kaiju_code

func _get_kaiju_file():
	var dir = Directory.new()
	dir.open(kaiju_data_folder)
	dir.list_dir_begin(true, true)
	var files = []
	while(true):
		var file = dir.get_next()
		if(file == ""):
			break
		else:
			if(!file.ends_with(".import")):
				files.append(file)
	dir.list_dir_end()
	var file_index = int(rand.randi()%files.size())

	return kaiju_data_folder + files[file_index]

func _process(delta):
	if(!is_instance_valid(enemy)):
		spawn_timer -= delta
		if(spawn_timer < 0):
			_spawn_kaiju()
			size += 0.1
			spawn_timer = 10
