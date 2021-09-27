extends "res://Scripts/DungeonGeneration/Wall.gd"

func _ready():
	call_deferred("registerPlacedDoor")

func registerPlacedDoor():
	TileHandler.doorsWaitingForPlacement -= 1
	
	if hasFreeSpace():
		TileHandler.doorsWaitingForConnection.append(self)

func hasFreeSpace():
	var neighbourPositionHelper = Spatial.new()
	add_child(neighbourPositionHelper)
	neighbourPositionHelper.translation.z -= TileHandler.TILE_WIDTH
	
	var neighbouringTile = TileHandler.getTile(neighbourPositionHelper.global_transform.origin)
	neighbourPositionHelper.queue_free()
	
	return neighbouringTile.currentOccupation == null or !neighbouringTile.currentOccupation.accessible

func _exit_tree():
	if TileHandler.doorsWaitingForConnection.has(self):
		TileHandler.doorsWaitingForConnection.erase(self)
