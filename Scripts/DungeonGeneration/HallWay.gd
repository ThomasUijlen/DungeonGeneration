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

func findPath(a,b,settings):
	print("find path!")
	if a.neighbouringTile == null or b.neighbouringTile == null:
		return
	
	self.settings = settings
	pathFound = false
	
	startingCoord = TileHandler.translationToCoord(a.neighbouringTile.global_transform.origin)
	targetCoord = TileHandler.translationToCoord(b.neighbouringTile.global_transform.origin)
	a.connectedTo.append(b)
	b.connectedTo.append(a)
	
	var startCoord = {"coord": startingCoord, "distanceToTarget": startingCoord.distance_to(targetCoord), "stepsFromStart": 0}
	startCoord["score"] = startCoord["distanceToTarget"] + startCoord["stepsFromStart"]
	availableCoords.append(startCoord)
	
	var tries = 0
	while !pathFound and availableCoords.size() > 0 and availableCoords.size() < 50 and tries < 50:
		print("find path")
		tries += 1
		explore()
	
	if pathFound:
		a.connectDoor()
		b.connectDoor()
	
	foundPath = []
	availableCoords = []
	print("path found")

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
#		print(currentCoord)
		foundPath.append(currentCoord)
		
		if currentCoord["coord"] == startingCoord:
			break
		
		currentCoord = currentCoord["previousCoord"]

func buildPath():
	for coord in foundPath:
		call_deferred("placeTile",coord,settings)

func placeTile(coord,settings):
	print("place tile")
	var tile = hallWayScene.instance()
	tile.settings = settings
	tile.translation = coord["coord"]*TileHandler.TILE_WIDTH
	GenerationHandler.currentScene.add_child(tile)
	print("tile placed")

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


