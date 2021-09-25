extends Node

#Used to design and put together a dungeon preset
#Allows you to create biomes and assign which rooms and hallways to use

#Used by the generator to recieve parts and generation contraints/rules

var biomes = []
var rooms = {}
var hallways = {}

export(PackedScene) var defaultTile

func _ready():
	collectDungeonParts()

func collectDungeonParts():
	collectBiomes()
	collectRooms()
	collectHallways()

func collectBiomes():
	biomes = get_children()

func collectRooms():
	for biome in biomes:
		if biome.has_node("Rooms"):
			rooms[biome] = biome.get_node("Rooms").get_children()

func collectHallways():
	for biome in biomes:
		if biome.has_node("Hallways"):
			hallways[biome] = biome.get_node("Hallways").get_children()
