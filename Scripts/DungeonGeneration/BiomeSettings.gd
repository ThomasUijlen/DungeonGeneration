extends Node

#Contains all settings for a biome. Settings can be changed from the editor.
#Also allows for easy access to noise generation by adjusting the parameters when requesting a noise value

export var biomeSeed = 0
export var period = 0.1
export var noiseThreshold = 0.5
export var priority = 0

var lastGeneratedNoiseValue = 0.0

func isActiveOnTile(translation):
	return getNoise(translation) > noiseThreshold

func getNoise(translation):
	GenerationHandler.noise.seed = biomeSeed + GenerationHandler.generationSeed
	GenerationHandler.noise.period = period
	lastGeneratedNoiseValue = (GenerationHandler.noise.get_noise_3d(translation.x,translation.y,translation.z) + 1)/2.0
	return lastGeneratedNoiseValue
