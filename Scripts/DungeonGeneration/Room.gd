extends Spatial

var settings
var noise = 0.0
var type = "room"

func _ready():
	call_deferred("registerPlacedRoom")

func registerPlacedRoom():
	TileHandler.roomsWaitingForPlacement -= 1
