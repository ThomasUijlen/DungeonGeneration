extends Node

#Responsible for all communication with tiles. Also keeps track of all loaded tiles.

var tileScene = load("res://Assets/DungeonParts/Main/Tile.tscn")

const TILE_WIDTH = 4
const CREATE_DISTANCE = 70
const GENERATION_DISTANCE = 50
const FINALIZE_DISTANCE = 20

var loadedTiles = {}

var rooms = []
var entrances = []

func translationToCoord(translation):
	return (translation/TILE_WIDTH).round()

func getTile(translation):
	var coord = translationToCoord(translation)
	if loadedTiles.keys().has(coord):
		return loadedTiles[coord]
	return null
#	else:
#		createTile(coord)
#		return loadedTiles[coord]

func createTile(coord):
	var tile = tileScene.instance()
	loadedTiles[coord] = tile
	GenerationHandler.currentScene.add_child(tile)
	tile.translation = coord*TILE_WIDTH

func generateTiles():
	var preloadCoords = getCoordsWithinRange(GENERATION_DISTANCE)
	
	for coord in preloadCoords:
		loadedTiles[coord].generate()
	
	var finalizeCoords = getCoordsWithinRange(FINALIZE_DISTANCE)
	for coord in finalizeCoords:
		loadedTiles[coord].finalize()

func loadTiles():
	pass

func refreshTiles():
	loadNewTiles()
	generateTiles()

func loadNewTiles():
	var coordsInRange = getCoordsWithinRange(CREATE_DISTANCE)
	
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
		loadedTiles[coord].call_deferred("queue_free")
		loadedTiles.erase(coord)
	
#	Create new tiles
	for coord in newCoords:
		createTile(coord)

func getCoordsWithinRange(loadRange):
	var playerCoord = translationToCoord(GlobalVariables.playerTranslation)
	playerCoord.y = 0
	
	var coords = []
	var preloadDistanceHalf = round(loadRange/2)
	for x in range(loadRange):
		for z in range(loadRange):
			coords.append(playerCoord+Vector3(x-preloadDistanceHalf,0,z-preloadDistanceHalf))
	
	return coords
