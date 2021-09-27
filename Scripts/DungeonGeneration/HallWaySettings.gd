extends Node

#Contains all settings for a hallway. Settings can be changed from the editor.
#Also allows for easy access to noise generation by adjusting the parameters when requesting a noise value

export var hallWaySeed = 0
export var period = 0.1
export var noiseThreshold = 0.95

export(PackedScene) var hallWayScene

var lastGeneratedNoiseValue = 0.0

func getRandomNumber(translation,mi,ma):
	GenerationHandler.randomNumberGenerator.seed = hallWaySeed + translation.length()
	return GenerationHandler.randomNumberGenerator.randi_range(mi,ma)
