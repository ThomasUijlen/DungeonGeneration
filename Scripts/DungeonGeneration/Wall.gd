extends Spatial

export var priority = 0

func _ready():
	call_deferred("registerPlacedWall")

func registerPlacedWall():
	TileHandler.wallsWaitingForPlacement -= 1

func checkPlacement(translation):
	if TileHandler.canOverwriteWall(translation,priority):
		TileHandler.wallList[translation] = self
		return true
	return false

func _exit_tree():
	if TileHandler.wallList.has(global_transform.origin):
		if TileHandler.wallList[global_transform.origin] == self:
			TileHandler.wallList.erase(global_transform.origin)
