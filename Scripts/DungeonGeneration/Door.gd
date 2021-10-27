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
	neighbourPositionHelper.translation.z += TileHandler.TILE_WIDTH*0.8
	
	neighbouringTile = TileHandler.getTile(neighbourPositionHelper.global_transform.origin)
	neighbourPositionHelper.call_deferred("queue_free")
	
	if neighbouringTile != null and !is_instance_valid(neighbouringTile):
		return false
	
	if neighbouringTile.currentOccupation != null and neighbouringTile.currentOccupation != null and neighbouringTile.currentOccupation.accessible:
		connectDoor()
	
	return neighbouringTile.currentOccupation == null or !neighbouringTile.currentOccupation.accessible

func _exit_tree():
	if TileHandler.doorsPlaced.has(self):
		TileHandler.doorsPlaced.erase(self)

func connectDoor():
	if has_node("Arch_Door"):
		remove_child($Arch_Door)
