extends Node

#Responsible for all communication with tiles. Also keeps track of all loaded tiles.

const TILE_WIDTH = 4
const CREATE_DISTANCE = 40
const GENERATION_DISTANCE = 30
const FINALIZE_DISTANCE = 20

var loadedTiles = {}

var roomsWaitingForPlacement = 0
var roomsPlaced = []
var wallsWaitingForPlacement = 0
var doorsPlaced = []
var hallWaysWaitingForConnection = 0
#var hallWaysPlaced = []
var wallList = {}

func translationToCoord(translation):
	return (translation/TILE_WIDTH).round()

func getTile(translation):
	var coord = translationToCoord(translation)
	if loadedTiles.keys().has(coord):
		return loadedTiles[coord]
	return null

func createTile(coord):
	var tile = GlobalPackedScenes.tileScene.instance()
	loadedTiles[coord] = tile
	GenerationHandler.currentScene.call_deferred("add_child",tile)
	tile.translation = coord*TILE_WIDTH

func generateTiles():
	var preloadCoords = getCoordsWithinRange(GENERATION_DISTANCE)
	
	for coord in preloadCoords:
		loadedTiles[coord].generate()
	
	var finalizeCoords = getCoordsWithinRange(FINALIZE_DISTANCE)
	for coord in finalizeCoords:
		loadedTiles[coord].finalize()

func connectDoors():
	if wallsWaitingForPlacement > 0:
		return
	
	for door in doorsPlaced:
		for possibleConnection in doorsPlaced:
			if door != possibleConnection and !door.connectedTo.has(possibleConnection) and door.global_transform.origin.distance_to(possibleConnection.global_transform.origin) < 10:
				connectWithHallway(door,possibleConnection)

func connectWithHallway(a,b):
	var hallWaySetting = null
	for hallWaySettings in GenerationHandler.dungeonPreset.hallways[a.tile.currentBiome]:
		if hallWaySettings.isActiveOnTile(a.global_transform.origin) or hallWaySetting == null:
			hallWaySetting = hallWaySettings
	
	var hallWay = GlobalPackedScenes.hallWayScene.instance()
	hallWay.hallWayScene = hallWaySetting.hallWayScene
	hallWay.call_deferred("findPath",a,b,hallWaySetting)

func refreshTiles():
	loadNewTiles()
	generateTiles()
#	print("connect hallways")
	connectDoors()
#	print("done connecting")

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

func canOverwriteWall(translation,priority,wall):
	translation = translation.round()
	translation = refineCoord(translation)
	
	if !wallList.has(translation):
		TileHandler.wallList[translation] = wall
		return true
	
	if wallList[translation].priority <= priority:
		if wallList[translation].get_parent() != null:
			wallList[translation].get_parent().call_deferred("remove_child",wallList[translation])
		else:
			wallList[translation].needsDeletion = true
		
		TileHandler.wallList[translation] = wall
		return true
	else:
		return false

#This function might look weird, but I ran into a very odd issue and this is the easiest way to solve it.
#When rounding Vector (-0.001,1,1) it will return (-0,1,1)
#When rounding Vector (0.001,1,1) it will return (0,1,1)
#Those two coordinates are EXACTLY the same, but because one 0 is seen as a negative number comparing them will return false
#This breaks wall placement so this function fixes those issues, couldnt think of a better solution even though this one is quite sloppy :(
func refineCoord(coord):
	if coord.x == -0:
		coord.x = 0
	if coord.y == -0:
		coord.y = 0
	if coord.z == -0:
		coord.z = 0
	return coord
