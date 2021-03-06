extends Spatial

#Every tile that exists in the game makes use of this script to define its behavior
#The exported variables can manually be changed for every tile right here in the editor

export(GlobalEnums.TILE_FILL_STATES) var fillType
export(Array,PackedScene) var wallTypes
export(Array,PackedScene) var windowTypes
export var windowSpawnChance = 100
export(Array,PackedScene) var doorTypes
export var doorSpawnChance = 100

export(int,0,100, 1) var spawnChance = 100

export var accessible = true
export var priority = 1

export var partOfRoom = true

var tile

var finalized = false

func _ready():
	if spawnChance < 100 and get_parent().settings.getRandomNumber(global_transform.origin*10,0,100) < spawnChance:
		call_deferred("queue_free")
		return
	
	priority += get_parent().noise
	
	var tile = TileHandler.getTile(global_transform.origin)
	if tile != null:
		if tile.overwriteOccupation(self):
			self.tile = tile
			return
	
	call_deferred("queue_free")


func finalize():
	if finalized:
		return
	finalized = true
	placeWall($Front)
	placeWall($Back)
	placeWall($Left)
	placeWall($Right)

func placeWall(side):
	$WallPlacementHelper.translation = side.translation*1.1
	var neighbouringTile = TileHandler.getTile($WallPlacementHelper.global_transform.origin)
	var wallType = chooseWall(neighbouringTile,side)
	
	if wallType != null:
		createWall(side,wallType)

func createWall(side,wallType):
	var wall = wallType.instance()
	if wall.checkPlacement(side.global_transform.origin):
		TileHandler.wallsWaitingForPlacement += 1
		wall.tile = tile
		side.call_deferred("add_child",wall)

func chooseWall(neighbouringTile,side):
	if neighbouringTile.currentOccupation != null and (tile.currentOccupation.get_parent().type == "hallway" and neighbouringTile.currentOccupation.get_parent().type == "hallway"):
		return null
	if neighbouringTile.currentOccupation != null and neighbouringTile.currentOccupation.get_parent() == tile.currentOccupation.get_parent():
		return null
	
	
	if doorTypes.size() > 0:
		if get_parent().settings.getRandomNumber(side.global_transform.origin,0,100) < doorSpawnChance:
			return doorTypes[get_parent().settings.getRandomNumber(side.global_transform.origin*10,0,doorTypes.size()-1)]
	
	if windowTypes.size() > 0 and neighbouringTile.fillState == GlobalEnums.TILE_FILL_STATES.HOLLOW:
		if get_parent().settings.getRandomNumber(side.global_transform.origin,0,100) < windowSpawnChance:
			return windowTypes[get_parent().settings.getRandomNumber(side.global_transform.origin*10,0,windowTypes.size()-1)]
	
	return wallTypes[get_parent().settings.getRandomNumber(side.global_transform.origin*10,0,wallTypes.size()-1)]

