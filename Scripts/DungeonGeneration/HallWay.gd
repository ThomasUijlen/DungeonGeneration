extends Spatial

var startingCoord
var targetCoord

var availableCoords = []
#{"previous": coord, "distanceToTarget": 0, "stepsFromStart": 0, "score": 0}

var pathFound = false

var foundPath = []

var settings
var noise = 0.0

var hallWayScene

func findPath(a,b):
	print("findPath")
	pathFound = false
	startingCoord = TileHandler.translationToCoord(a.global_transform.origin)
	targetCoord = TileHandler.translationToCoord(b.global_transform.origin)
	
	var startCoord = {"coord": startingCoord, "distanceToTarget": startingCoord.distance_to(targetCoord), "stepsFromStart": 0}
	startCoord["score"] = startCoord["distanceToTarget"] + startCoord["stepsFromStart"]
	availableCoords.append(startCoord)
	
	while !pathFound and availableCoords.size() > 0 and availableCoords.size() < 100:
		print("find!")
		print(pathFound)
		print(availableCoords.size())
		explore()
	print("found!")
	
	if pathFound:
		buildPath()
	
	foundPath = []
	availableCoords = []

func explore():
	var coordToExplore = getLowestScoreCoord()
	
	if coordToExplore["coord"] == targetCoord:
		pathFound = true
		collectPath(coordToExplore)
		buildPath()
	else:
		availableCoords.erase(coordToExplore)
		exploreAroundCoord(coordToExplore)

func collectPath(endCoord):
	var currentCoord = endCoord
	while true:
		pathFound.append(currentCoord["previousCoord"])
		currentCoord = currentCoord["previousCoord"]
		
		if currentCoord == startingCoord:
			break

func buildPath():
	for coord in foundPath:
		placeTile(coord)
#		call_deferred("placeTile",coord)

func placeTile(coord):
	var tile = hallWayScene.instance()
	tile.translation = coord["coord"]
	tile.partOfRoom = false
	GenerationHandler.currentScene.add_child(tile)

func exploreAroundCoord(coord):
	addCoordToAvailableList(coord, coord["coord"] + Vector3(-TileHandler.TILE_WIDTH,0,0))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(TileHandler.TILE_WIDTH,0,0))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(0,0,TileHandler.TILE_WIDTH))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(0,0,-TileHandler.TILE_WIDTH))

func addCoordToAvailableList(origin, coordToExplore):
	var tile = TileHandler.getTile(coordToExplore)
	if tile == null or (tile.currentOccupation != null and tile.currentOccupation.partOfRoom):
		return
	
	var newCoord = {"previousCoord": origin, "coord": coordToExplore, "distanceToTarget": coordToExplore.distance_to(targetCoord), "stepsFromStart": origin["stepsFromStart"] + 1}
	newCoord["score"] = newCoord["distanceToTarget"] + newCoord["stepsFromStart"]
	availableCoords.append(newCoord)

func getLowestScoreCoord():
	var lowestScoreCoord = null
	var currentScore = 0
	
	for coord in availableCoords:
		if lowestScoreCoord == null or coord["score"] < currentScore:
			currentScore = coord["score"]
			lowestScoreCoord = coord
	
	return lowestScoreCoord


