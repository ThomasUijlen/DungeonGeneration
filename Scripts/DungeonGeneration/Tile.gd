extends Spatial

#Used during generation. Keeps track of basic information like its coordinates
#and what is occupying this tile.

var currentState = GlobalEnums.TILE_STATES.CREATED

var coords = Vector3.ZERO

var currentBiome = null
var biomePriority = -1

var currentOccupation = null
var occupationPriority = -1

var fillState = GlobalEnums.TILE_FILL_STATES.SOLID

#Generation --------------------------------------------------
#Assigns biomes and places rooms
func generate():
	if currentState != GlobalEnums.TILE_STATES.CREATED:
		return
	currentState = GlobalEnums.TILE_STATES.GENERATED
	
	generateBiome()
	generateRooms()

func finalize():
	if currentState != GlobalEnums.TILE_STATES.GENERATED:
		return
	
	if currentOccupation != null:
		currentState = GlobalEnums.TILE_STATES.FINALIZED
		currentOccupation.finalize()

func generateBiome():
	for biome in GenerationHandler.dungeonPreset.biomes:
		if biome.isActiveOnTile(translation) or currentBiome == null:
			overwriteCurrentBiome(biome)

func overwriteCurrentBiome(biome):
	if biome.priority > biomePriority:
		biomePriority = biome.priority
		currentBiome = biome

func generateRooms():
	for roomSettings in GenerationHandler.dungeonPreset.rooms[currentBiome]:
		if roomSettings.isActiveOnTile(translation):
			TileHandler.roomsWaitingForPlacement += 1
			call_deferred("createRoom",roomSettings,roomSettings.lastGeneratedNoiseValue)
			return

func createRoom(roomSettings,noiseValue):
	var room = roomSettings.roomScene.instance()
	room.settings = roomSettings
	room.translation = translation
	room.rotation_degrees.y = 90*roomSettings.getRandomNumber(translation,0,4)
	GenerationHandler.currentScene.call_deferred("add_child",room)

func overwriteOccupation(occupation):
	if occupation.priority > occupationPriority:
		if currentOccupation != null:
			currentOccupation.call_deferred("queue_free")
		
		occupationPriority = occupation.priority
		currentOccupation = occupation
		fillState = currentOccupation.fillType
		return true
	
	return false

func _exit_tree():
	if currentOccupation != null:
		currentOccupation.call_deferred("queue_free")
