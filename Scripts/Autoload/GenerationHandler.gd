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

var currentScene

func _ready():
	GlobalVariables.addObserver(self)
	currentScene = get_tree().current_scene

func generateDungeon(dungeonToGenerate, generationSeed):
	dungeonPreset = dungeonToGenerate
	dungeonPreset.prepare()
	
	self.generationSeed = generationSeed
	startThread()
	activateThread()



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
		print("thead run")
		TileHandler.refreshTiles()
		call_deferred("checkForThreadRerun")

func checkForThreadRerun():
	if TileHandler.roomsWaitingForPlacement > 0 or TileHandler.wallsWaitingForPlacement > 0:
		print("thread rerun")
		semaphore.post()

#Wait for thread to finish when exiting the application to properly dispose of it
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		threadActive = false
		generationThread.wait_to_finish()

func playerMoved():
	activateThread()
