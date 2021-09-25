extends Spatial

#Used during generation. Keeps track of basic information like its coordinates
#and what is occupying this tile.

var currentState = GlobalEnums.TILE_STATES.CREATED

var coords = Vector3.ZERO

var currentBiome = null
var biomePriority = -1

var currentOccupation = null
var occupationPriority = -1

var distanceToPlayer = 0.0

#Generation --------------------------------------------------
#Assigns biomes and places rooms
func generate():
	if currentState != GlobalEnums.TILE_STATES.CREATED:
		return
	currentState = GlobalEnums.TILE_STATES.GENERATED
	
	generateBiome()
	generateRooms()



func generateBiome():
	for biome in GenerationHandler.dungeonPreset.biomes:
		if biome.isActiveOnTile(global_transform.origin):
			overwriteCurrentBiome(biome)

func overwriteCurrentBiome(biome):
	if biome.priority > biomePriority:
		biomePriority = biome.priority
		currentBiome = biome

func generateRooms():
	for room in GenerationHandler.rooms[currentBiome]:
		pass

func overwriteOccupation(occupation):
	if occupation.priority > occupationPriority:
		if currentOccupation != null:
			currentOccupation.queue_free()
		
		occupationPriority = occupation.priority
		currentOccupation = occupation
		return true
	
	return false
