extends Node

#Keeps track of the player and makes sure the dungeon gets generated
#All generation is done within a thread to prevent lag spickes or stuttering

var dungeonPreset

var generationThread
var threadActive = false
var semaphore = Semaphore.new()

var randomNumberGenerator = RandomNumberGenerator.new()
var noise = OpenSimplexNoise.new()
var generationSeed = 0

func generateDungeon(dungeonToGenerate, generationSeed):
	dungeonPreset = dungeonToGenerate
	self.generationSeed = generationSeed
	startThread()



#Thread logic --------------------------------------------------------------------------
func startThread():
	threadActive = true
	generationThread = Thread.new()
	generationThread.start(self,"threadFunction","data",Thread.PRIORITY_HIGH)

func activateThread():
	semaphore.post()

func threadFunction(data):
	while threadActive:
		semaphore.wait()
		

#Wait for thread to finish when exiting the application to properly dispose of it
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		threadActive = false
		generationThread.wait_to_finish()



#Generation logic ----------------------------------------------------------------------
func getCoords



#Player movement detection -------------------------------------------------------------
#Whenever the player moves more then 1 tile, it triggers the thread to generate more tiles
var lastPlayerPos = null
var currentPlayerPos = null
func _physics_process(delta):
	if playerMoved():
		activateThread()

func playerMoved():
	if currentPlayerPos != null and (lastPlayerPos == null or lastPlayerPos.distance_to(currentPlayerPos) > TileHandler.TILE_SIZE):
		lastPlayerPos = currentPlayerPos
		return true
	return false
