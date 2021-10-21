extends Spatial

export var priority = 0
var tile
var needsDeletion = false

func _ready():
	call_deferred("registerPlacedWall")
	call_deferred("checkForDeletion")

func checkForDeletion():
	if needsDeletion:
		get_parent().remove_child(self)

func registerPlacedWall():
	TileHandler.wallsWaitingForPlacement -= 1

func checkPlacement(translation):
	if TileHandler.canOverwriteWall(translation,priority):
		TileHandler.wallList[translation] = self
		return true
	return false

func _exit_tree():
	if TileHandler.wallList.has(translation):
		if TileHandler.wallList[translation] == self:
			TileHandler.wallList.erase(translation)
