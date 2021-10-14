extends "res://Scripts/DungeonGeneration/Wall.gd"

func _ready():
	call_deferred("registerPlacedDoor")

func registerPlacedDoor():
	if hasFreeSpace():
		TileHandler.doorsPlaced.append(self)

var neighbouringTile
var connectedTo = []

func hasFreeSpace():
	var neighbourPositionHelper = Spatial.new()
	add_child(neighbourPositionHelper)
	neighbourPositionHelper.translation.z += TileHandler.TILE_WIDTH
	
	neighbouringTile = TileHandler.getTile(neighbourPositionHelper.global_transform.origin)
	neighbourPositionHelper.queue_free()
	
	return neighbouringTile.currentOccupation == null or !neighbouringTile.currentOccupation.accessible

func _exit_tree():
	if TileHandler.doorsPlaced.has(self):
		TileHandler.doorsPlaced.erase(self)
