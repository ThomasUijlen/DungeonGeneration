extends Spatial

#Every tile that exists in the game makes use of this script to define its behavior
#The exported variables can manually be changed for every tile right here in the editor

export(Array,PackedScene) var wallTypes
export(Array,PackedScene) var windowTypes
export(Array,PackedScene) var doorTypes

export(int,0,100, 1) var spawnChance = 100
export var priority = 0

func _ready():
	var tile = TileHandler.getTile(global_transform.origin)
	print(tile)
	if tile != null:
		if tile.overwriteOccupation(self):
			return
	
	queue_free()

func addWalls(frontWallType, backWallType, leftWallType, rightWallType):
	placeWall($Front, frontWallType)
	placeWall($Back, backWallType)
	placeWall($Left, leftWallType)
	placeWall($Right, rightWallType)

func placeWall(location, type):
	match(type):
		GlobalEnums.WALL_SETTINGS.NO_WALL:
			pass
		GlobalEnums.WALL_SETTINGS.WALL:
			pass
		GlobalEnums.WALL_SETTINGS.WINDOW:
			pass
		GlobalEnums.WALL_SETTINGS.DOOR:
			pass
		GlobalEnums.WALL_SETTINGS.RANDOM:
			pass

