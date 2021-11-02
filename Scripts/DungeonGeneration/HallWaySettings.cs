using Godot;
using System;

public class HallWaySettings : Node, ISettings
{
    [Export] int hallWaySeed = 0;
    [Export] float period = 0.1f;
    [Export] float noiseThreshold = 0.95f;

    [Export] public PackedScene hallWayScene;

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
        GenerationHandler.noise.Seed = hallWaySeed + GenerationHandler.generationSeed;
        GenerationHandler.noise.Period = period;
        lastGeneratedNoiseValue = (GenerationHandler.noise.GetNoise3d(translation.x,translation.y,translation.z) + 1)/2.0f;
        return lastGeneratedNoiseValue;
    }

    public int getRandomNumber(Vector3 translation, int mi, int ma) {
        GenerationHandler.randomNumberGenerator.Seed = Convert.ToUInt64(Godot.Mathf.RoundToInt(hallWaySeed + translation.Length()));
        return GenerationHandler.randomNumberGenerator.RandiRange(mi,ma);
    }
}
