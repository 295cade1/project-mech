extends Node


onready var kaiju_manager = get_node("KaijuManager")
onready var building_manager = get_node("BuildingManager")
onready var terrain_manager = get_node("TerrainManager")



func _ready():
	terrain_manager.start()
	building_manager.start(terrain_manager.terrain)
	print(building_manager.building_points)
	terrain_manager.complete(building_manager.building_points)
	#kaiju_manager.initialize()

