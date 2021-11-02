using Godot;
using System;

public class BiomeSettings : Node, ISettings
{
    [Export] int biomeSeed = 0;
    [Export] float period = 0.1f;
    [Export] float noiseThreshold = 0.5f;
    [Export] public float priority = 0;

    float lastGeneratedNoiseValue = 0.0f;

    GenerationHandler GenerationHandler;

    public void setGenerationHandler(GenerationHandler generationHandler) {
        GenerationHandler = generationHandler;
    }

    public bool isActiveOnTile(Vector3 translation) {
        return getNoise(translation) > noiseThreshold;
    }

    public float getLastNoiseValue() {
        return lastGeneratedNoiseValue;
    }

    public float getNoise(Vector3 translation) {
        if(translation.x == 0 && translation.z == 0) {
            lastGeneratedNoiseValue = 1;
            return lastGeneratedNoiseValue;
        }
        
        GenerationHandler.noise.Seed = biomeSeed + GenerationHandler.generationSeed;
        GenerationHandler.noise.Period = period;
        lastGeneratedNoiseValue = (GenerationHandler.noise.GetNoise3d(translation.x,translation.y,translation.z) + 1)/2.0f;
        return lastGeneratedNoiseValue;
    }

    public int getRandomNumber(Vector3 translation, int mi, int ma) {
        GenerationHandler.randomNumberGenerator.Seed = Convert.ToUInt64(Godot.Mathf.RoundToInt(biomeSeed + translation.Length()));
        return GenerationHandler.randomNumberGenerator.RandiRange(mi,ma);
    }
}
