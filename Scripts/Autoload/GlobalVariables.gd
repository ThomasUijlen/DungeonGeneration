extends Node

var previousPlayerTranslation = Vector3(0,0,0)
var playerTranslation = Vector3(0,0,0)
var movedObservers = []

func _physics_process(delta):
	if playerTranslation.distance_to(previousPlayerTranslation) > 5:
		previousPlayerTranslation = playerTranslation
		updateObservers()

func updateObservers():
	for observer in movedObservers:
		observer.call("playerMoved")

func addObserver(observer):
	movedObservers.append(observer)

func removeObserver(observer):
	movedObservers.erase(observer)
