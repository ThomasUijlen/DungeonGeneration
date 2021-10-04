extends Spatial

export var entranceAmount = 1

var tiles = []
var settings
var ID = 0
var noise = 0.0

func _ready():
	call_deferred("registerPlacedRoom")

func registerPlacedRoom():
	TileHandler.roomsWaitingForPlacement -= 1
