extends Spatial

var startingCoord
var targetCoord

var settings
var noise = 0.0

var hallWayScene

func findPath(a,b,settings):
#	print("find path!")
	if (!is_instance_valid(a.neighbouringTile) or a.neighbouringTile == null) or (!is_instance_valid(b.neighbouringTile) or b.neighbouringTile == null):
		return
	
	self.settings = settings
	
	startingCoord = TileHandler.translationToCoord(a.neighbouringTile.global_transform.origin)
	targetCoord = TileHandler.translationToCoord(b.neighbouringTile.global_transform.origin)
	
	var currentX = startingCoord.x
	var currentZ = startingCoord.z
#	Place tile at start and end
	call_deferred("placeTile",startingCoord,settings)
	call_deferred("placeTile",targetCoord,settings)
	
#	Move along X axis
	while currentX != targetCoord.x:
		if currentX < targetCoord.x: currentX += 1
		elif currentX > targetCoord.x: currentX -= 1
		call_deferred("placeTile",Vector3(currentX,startingCoord.y,currentZ),settings)
	
#	Move along Z axis
	while currentZ != targetCoord.z:
		if currentZ < targetCoord.z: currentZ += 1
		elif currentZ > targetCoord.z: currentZ -= 1
		call_deferred("placeTile",Vector3(currentX,startingCoord.y,currentZ),settings)
	
	a.connectedTo.append(b)
	b.connectedTo.append(a)
	a.connectDoor()
	b.connectDoor()
#	print("path found")

func placeTile(coord,settings):
#	print("place tile")
	var tile = hallWayScene.instance()
	tile.settings = settings
	tile.translation = coord*TileHandler.TILE_WIDTH
	GenerationHandler.currentScene.add_child(tile)


