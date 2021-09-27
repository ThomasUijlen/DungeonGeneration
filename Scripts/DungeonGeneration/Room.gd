extends Spatial

var settings
var noise = 0.0

func _ready():
	call_deferred("registerPlacedRoom")

func registerPlacedRoom():
	TileHandler.roomsWaitingForPlacement -= 1
