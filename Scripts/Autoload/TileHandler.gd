extends Node

#Responsible for all communication with tiles. Also keeps track of all loaded tiles.

var tileScene = load("res://Assets/DungeonParts/Main/Tile.tscn")

const TILE_WIDTH = 4
const PRE_LOAD_DISTANCE = 50
const LOAD_DISTANCE = 20

var loadedTiles = {}

func translationToCoord(translation):
	return (translation/TILE_WIDTH).floor()

func getTile(translation):
	var coord = translationToCoord(translation)
	if loadedTiles.keys().has(coord):
		return loadedTiles[coord]
	else:
		createTile(coord)
		return loadedTiles[coord]

func createTile(coord):
	var tile = tileScene.instance()
	loadedTiles[coord] = tile
	get_tree().current_scene.add_child(tile)
	tile.global_transform.origin = coord*TILE_WIDTH

func generateTiles():
	for tile in loadedTiles.values():
		tile.generate()

func loadTiles():
	pass

func refreshTiles():
	loadNewTiles()
	generateTiles()

func loadNewTiles():
	var coordsInRange = getCoordsWithinRange()
	
	var oldCoords = loadedTiles.keys()
	var unchangedCoords = []
	var newCoords = []
	
#	Sort tiles into correct lists
	for coord in coordsInRange:
		if loadedTiles.has(coord):
			unchangedCoords.append(coord)
		else:
			newCoords.append(coord)
		oldCoords.erase(coord)
	
#	Delete old tiles
	for coord in oldCoords:
		loadedTiles[coord].queue_free()
		loadedTiles.erase(coord)
	
#	Create new tiles
	for coord in newCoords:
		createTile(coord)

func getCoordsWithinRange():
	var playerCoord = translationToCoord(GenerationHandler.currentPlayerPos)
	
	var coords = []
	var preloadDistanceHalf = round(PRE_LOAD_DISTANCE/2)
	for x in range(PRE_LOAD_DISTANCE):
		for z in range(PRE_LOAD_DISTANCE):
			coords.append(playerCoord+Vector3(x-preloadDistanceHalf,0,z-preloadDistanceHalf))
	
	return coords
