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
		if biome.isActiveOnTile(global_transform.origin) or currentBiome == null:
			overwriteCurrentBiome(biome)

func overwriteCurrentBiome(biome):
	if biome.priority > biomePriority:
		biomePriority = biome.priority
		currentBiome = biome

func generateRooms():
	for roomSettings in GenerationHandler.dungeonPreset.rooms[currentBiome]:
		if roomSettings.isActiveOnTile(global_transform.origin):
			call_deferred("createRoom",roomSettings)

func createRoom(roomSettings):
	var room = roomSettings.roomScene.instance()
	room.roomSettings = roomSettings
	room.translation = translation
	GenerationHandler.currentScene.add_child(room)

func overwriteOccupation(occupation):
	if occupation.priority > occupationPriority:
		if currentOccupation != null:
			currentOccupation.call_deferred("queue_free")
		
		occupationPriority = occupation.priority
		currentOccupation = occupation
		return true
	
	return false

func _exit_tree():
	if currentOccupation != null:
		currentOccupation.call_deferred("queue_free")
