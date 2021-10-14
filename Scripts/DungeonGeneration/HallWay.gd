extends Spatial

var startingCoord
var targetCoord

var checkedCoords = []
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
	startingCoord = TileHandler.translationToCoord(a.neighbouringTile.global_transform.origin)
	targetCoord = TileHandler.translationToCoord(b.neighbouringTile.global_transform.origin)
	print(startingCoord)
	print(targetCoord)
	
	var startCoord = {"coord": startingCoord, "distanceToTarget": startingCoord.distance_to(targetCoord), "stepsFromStart": 0}
	startCoord["score"] = startCoord["distanceToTarget"] + startCoord["stepsFromStart"]
	availableCoords.append(startCoord)
	
	while !pathFound and availableCoords.size() > 0 and availableCoords.size() < 50:
		explore()
	print(pathFound)
	
	foundPath = []
	availableCoords = []

func explore():
	var coordToExplore = getLowestScoreCoord()
#	print("----------------------------")
#	print(coordToExplore["coord"])
#	print(targetCoord)
#	print(checkedCoords.has(coordToExplore["coord"]))
	if coordToExplore["coord"] == targetCoord:
		pathFound = true
		collectPath(coordToExplore)
		buildPath()
	else:
		availableCoords.erase(coordToExplore)
		exploreAroundCoord(coordToExplore)

func collectPath(endCoord):
	var currentCoord = endCoord
	print("collectPath")
	while true:
#		print("---")
#		print(currentCoord)
#		print(startingCoord)
		
		foundPath.append(currentCoord)
		
		if currentCoord["coord"] == startingCoord:
			break
		
		currentCoord = currentCoord["previousCoord"]

func buildPath():
	print(foundPath)
	for coord in foundPath:
		print("tile!")
		call_deferred("placeTile",coord)
#		call_deferred("placeTile",coord)

func placeTile(coord):
	var tile = hallWayScene.instance()
	tile.translation = coord["coord"]
	print(tile.translation)
	GenerationHandler.currentScene.add_child(tile)

func exploreAroundCoord(coord):
	addCoordToAvailableList(coord, coord["coord"] + Vector3(-1,0,0))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(1,0,0))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(0,0,1))
	addCoordToAvailableList(coord, coord["coord"] + Vector3(0,0,-1))

func addCoordToAvailableList(origin, coordToExplore):
	var tile = TileHandler.getTile(coordToExplore)
	if tile == null or (tile.currentOccupation != null and tile.currentOccupation.partOfRoom):
		return
	if checkedCoords.has(coordToExplore):
		return
	
	checkedCoords.append(coordToExplore)
	var newCoord = {"previousCoord": origin, "coord": coordToExplore, "distanceToTarget": coordToExplore.distance_to(targetCoord)*10, "stepsFromStart": origin["stepsFromStart"] + 1}
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


